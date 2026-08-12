# MediConsult Code Documentation

This document explains how the Flutter code works at the class and data-flow level. It assumes the reader already has the dependency and setup context from `TECHNICAL_DOCS.md`.

## Core
**Location:** `lib/core/`

### What it does
`lib/core` contains the shared infrastructure every feature depends on: routing, dependency injection, networking, storage/cache facades, error handling, theming, and cross-cutting services such as Firebase, analytics, connectivity, updates, and notifications. The code follows a repeated pattern: UI widgets call Cubits, Cubits call repositories, repositories call Retrofit API services, and results are wrapped in `ApiResult`/Freezed states.

### Key classes

#### AppRouter
**File:** `lib/core/routing/app_router.dart`

`AppRouter` owns all GoRouter routes and wires screens to their required Cubits. It also decides the initial route from the global `isLoggedInUser` flag.

`lib/core/routing/app_router.dart`
```dart
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: isLoggedInUser ? '/home' : '/login',
    redirect: (context, state) {
      if (state.uri.path == '/choose') {
        return isLoggedInUser ? '/home' : '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/signup',
```

This snippet shows the top-level navigation decision: authenticated users start at `/home`, unauthenticated users start at `/login`, and `/choose` redirects to one of those two paths.

`lib/core/routing/app_router.dart`
```dart
      GoRoute(
        path: '/approval-request',
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => sl<FamilyMembersCubit>()),
              BlocProvider(create: (context) => sl<ApprovalRequestCubit>()),
            ],
            child: const ApprovalRequestScreen(),
          );
        },
      ),
```

Feature routes often inject multiple Cubits at the screen boundary. Here the approval form needs family-member data and approval submission state.

#### Service locator
**File:** `lib/core/di/service_locator.dart`

`setupServiceLocator()` builds the app graph. It creates Dio clients, registers Retrofit services, registers repositories, and registers Cubit factories.

`lib/core/di/service_locator.dart`
```dart
  sl.registerLazySingleton<LoginApiService>(() => LoginApiService(loginDio));
  sl.registerLazySingleton<RegisterApiService>(() => RegisterApiService(dio));
  sl.registerLazySingleton<ResetPasswordApiService>(
    () => ResetPasswordApiService(dio),
  );
  sl.registerLazySingleton<HomeApiService>(() => HomeApiService(dio));
  sl.registerLazySingleton<ECardApiService>(() => ECardApiService(dio));
  sl.registerLazySingleton<ProvidersApiService>(() => ProvidersApiService(dio));
```

Services are lazy singletons, so each Retrofit wrapper is created once when requested. Login uses `loginDio`; regular app services use the token-aware `dio`.

`lib/core/di/service_locator.dart`
```dart
  sl.registerLazySingleton<HomeRepository>(() => HomeRepository(sl()));
  sl.registerLazySingleton<ECardRepository>(
    () => ECardRepository(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<FamilyMemberRepository>(
    () => FamilyMemberRepository(sl()),
  );
  sl.registerLazySingleton<ApprovalRequestRepository>(
    () => ApprovalRequestRepository(sl()),
  );
```

Repositories depend on services and are also lazy singletons. `ECardRepository` has a richer dependency list because it uses API, local data source, and cache-owner resolution.

`lib/core/di/service_locator.dart`
```dart
  sl.registerFactory<LoginCubit>(() => LoginCubit(sl()));
  sl.registerFactory<SignupCubit>(() => SignupCubit(sl()));
  sl.registerFactory<SendOtpCubit>(() => SendOtpCubit(sl()));
  sl.registerFactory<ResetPasswordCubit>(() => ResetPasswordCubit(sl()));
  sl.registerFactory<ResendOtpCubit>(() => ResendOtpCubit(sl()));
  sl.registerFactory<VerifyOtpCubit>(() => VerifyOtpCubit(sl()));
  sl.registerFactory<HomeCubit>(() => HomeCubit(sl()));
```

Cubits are factories rather than singletons, so route creation gets fresh state holders.

#### DioFactory
**File:** `lib/core/network/dio_factory.dart`

`DioFactory` creates three HTTP clients: the main authenticated client, a login client without a token, and a separate Medicard client without MCI auth headers.

`lib/core/network/dio_factory.dart`
```dart
  static Future<Dio> getDio() async {
    if (_dio != null) return _dio!;

    const timeout = Duration(seconds: 15);
    _dio = Dio()
      ..options.connectTimeout = timeout
      ..options.receiveTimeout = timeout;

    await _addHeaders();
    _addInterceptors();
    return _dio!;
  }
```

The main Dio instance is memoized and configured once. It gets headers before interceptors are attached.

`lib/core/network/dio_factory.dart`
```dart
  static Future<void> _addHeaders() async {
    final token = await SharedPrefHelper.getSecuredString(
      SharedPrefKeys.userToken,
    );
    _dio?.options.headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
```

The bearer token comes from secure/shared preferences and is attached to every main API call.

`lib/core/network/dio_factory.dart`
```dart
    // Only Accept header â€” no Authorization token
    dio.options.headers = {'Accept': 'application/json'};

    // Error mapping
    dio.interceptors.add(ErrorMappingInterceptor());

    // Retry interceptor
    dio.interceptors.add(RetryInterceptor(
      connectivityService: ConnectivityService.instance,
      maxRetries: 2,
```

Medicard traffic intentionally omits `Authorization`. [INFERRED] This prevents leaking the main app token to an external API host.

#### CacheService
**File:** `lib/core/cache/cache_service.dart`

`CacheService` is a facade over feature-specific cache services. It keeps call sites stable while delegating to smaller caches such as home, family, approvals, notifications, network, support, profile, terms, and refunds.

`lib/core/cache/cache_service.dart`
```dart
class CacheService {
  // ==================== Home Cache ====================
  
  /// Cache home data
  static Future<void> cacheHomeData(HomeResponse data) async {
    return HomeCacheService.cacheHomeData(data);
  }

  /// Get cached home data
  static Future<HomeResponse?> getCachedHomeData() async {
    return HomeCacheService.getCachedHomeData();
  }
```

The facade method names are feature-oriented. Cubits call these static helpers rather than importing each underlying cache service directly.

### Data flow
Representative app startup flow: `main.dart` initializes Firebase/EasyLocalization/connectivity/push notifications -> calls `setupServiceLocator()` -> checks token and onboarding flags with `SharedPrefHelper` -> runs `MediConsultApp` -> `MaterialApp.router` uses `AppRouter.router` -> initial location is `/home` or `/login`.

Representative feature flow: screen route creates Cubit from `sl<TCubit>()` -> UI calls a Cubit method -> Cubit calls repository -> repository calls Retrofit service -> Dio sends request with interceptors -> repository maps success/failure into `ApiResult` -> Cubit emits Freezed state -> UI rebuilds via `BlocBuilder`/`BlocListener`.

### Edge cases / notable logic

- The main authenticated Dio instance is memoized. After login, `DioFactory.setTokenIntoHeaderAfterLogin()` updates `_dio` if it already exists.
- `RetryInterceptor` and `ErrorMappingInterceptor` are attached to HTTP clients; feature repositories generally call `ErrorHandler.handle(error)` when exceptions escape.
- Cache-first Cubits commonly emit cached data immediately and call `unawaited(_fetchAndCacheData(lang))` for background refresh.

---

## Approval Request
**Location:** `lib/features/approval_request`

### What it does
This feature handles pre-approval creation and approval history. The request screen gathers a family member, provider, optional notes, and required attachments; the history screen loads paginated approval records with filters and cached first-page data.

### Key classes

#### ApprovalRequestScreen
**File:** `lib/features/approval_request/presentation/approval_request_screen.dart`

Owns the form state, validates required fields, scrolls to invalid sections, saves recent providers, and calls the submission Cubit.

`lib/features/approval_request/presentation/approval_request_screen.dart`
```dart
    if (_attachments.isEmpty) {
      _showError('approval_request.validation.attachment_required'.tr());
      await FormValidationService.scrollToField(
        scrollController: _scrollController,
        fieldKey: _attachKey,
      );
      return;
    }

    // Save provider to recent list
    if (_selectedProvider != null) {
      await _recentProvidersService.addRecentProvider(
```

The form does not submit unless attachments are present. It scrolls the user to the failing field and then stores the selected provider in the recent-provider service.

`lib/features/approval_request/presentation/approval_request_screen.dart`
```dart
    context.read<ApprovalRequestCubit>().createApprovalRequest(
      lang: context.locale.languageCode,
      memberId: _selectedFamilyMember!.memberId,
      providerId: _selectedProvider!.id,
      notes: _noteController.text.isNotEmpty ? _noteController.text : null,
      attachmentPaths: _attachments,
    );
```

Once validation passes, the screen forwards only normalized data to the Cubit: language, selected IDs, nullable notes, and local attachment paths.

#### ApprovalRequestCubit
**File:** `lib/features/approval_request/presentation/cubit/approval_request_cubit.dart`

Coordinates one create request and emits loading/success/failed states.

`lib/features/approval_request/presentation/cubit/approval_request_cubit.dart`
```dart
  Future<void> createApprovalRequest({
    required String lang,
    required int memberId,
    required int providerId,
    String? notes,
    required List<String> attachmentPaths,
  }) async {
    emit(const ApprovalRequestState.loading());

    final result = await _repository.createApprovalRequest(
      lang: lang,
```

The Cubit is deliberately thin: emit loading, delegate to repository, then map `ApiResult` to UI states.

#### ApprovalRequestRepository
**File:** `lib/features/approval_request/repository/approval_request_repository.dart`

Converts local file paths to `MultipartFile` objects and calls the Retrofit service.

`lib/features/approval_request/repository/approval_request_repository.dart`
```dart
      // Convert file paths to MultipartFile
      final List<MultipartFile> attachments = [];
      for (String path in attachmentPaths) {
        final file = await MultipartFile.fromFile(path);
        attachments.add(file);
      }

      final response = await _apiService.createApprovalRequest(
        lang,
        memberId,
```

The repository owns multipart conversion, keeping the UI and Cubit free from Dio-specific upload details.

#### ApprovalsCubit
**File:** `lib/features/approval_request/presentation/cubit/approvals_cubit.dart`

Loads approval history with status/search/member filters, pagination, and cache-first behavior for the unfiltered first page.

`lib/features/approval_request/presentation/cubit/approvals_cubit.dart`
```dart
    if (_page == 1 && !forceRefresh && _key == null && _memberId == null) {
      final cachedData = await CacheService.getCachedApprovalsData(_status);
      if (cachedData != null && cachedData.data != null) {
        final data = cachedData.data!;
        _items.clear();
        _items.addAll(data.approvals);
        emit(ApprovalsState.loaded(
          approvals: _items,
```

Cache is used only for the first unfiltered page. Search and member-specific filters bypass persistent cache to avoid showing the wrong result set.

### Data flow
User taps submit -> `_submitApprovalRequest()` validates fields -> `ApprovalRequestCubit.createApprovalRequest()` -> `ApprovalRequestRepository.createApprovalRequest()` -> `ApprovalRequestApiService.createApprovalRequest()` -> `POST {lang}/Approval/Create` multipart -> `ApprovalRequestResponse` -> Cubit emits `ApprovalRequestState.success(response.data!)` -> UI listener shows success/reset behavior.

History flow: `ApprovalHistoryScreen` calls `ApprovalsCubit.load()` -> cache may emit `ApprovalsState.loaded` immediately -> `_fetchAndCacheData()` calls `ApprovalsRepository.getApprovals()` -> Retrofit hits `GET {lang}/Approval/GetApprovals` or `GetApprovalsByMember` -> Cubit merges records into `_items` and emits `loaded`.

### Edge cases / notable logic

- Approval notes are limited to 300 characters.
- Attachments are required.
- First page is cached by status only when no search key and no member filter are active.
- Failures are recorded in Crashlytics with member ID, provider ID, and language.

---

## Auth
**Location:** `lib/features/auth`

### What it does
Auth contains login, signup, forgot-password OTP, OTP verification, reset password, and account-verification UI. It persists the backend token/member ID, updates Crashlytics user context, and sends the Firebase token after login/signup.

### Key classes

#### LoginCubit
**File:** `lib/features/auth/login/presentation/logic/login_cubit.dart`

Builds the login request, calls the login repository, stores credentials on success, and logs auth failures to Crashlytics.

`lib/features/auth/login/presentation/logic/login_cubit.dart`
```dart
      response.when(
        success: (response) async {
          await saveUserToken(
            response.data!.token,
            memberId: response.data!.memberId,
          );

          // ØªØ¹ÙŠÙŠÙ† Ù…Ø¹Ø±Ù Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… ÙÙŠ Crashlytics (memberId)
          final memberId = response.data!.memberId.toString();
```

The success branch persists the token/member ID before emitting success, so subsequent authenticated routes can use the saved session.

#### LoginRepository
**File:** `lib/features/auth/login/repository/login_repository.dart`

Wraps the Retrofit call and normalizes backend success/failure into `ApiResult`.

`lib/features/auth/login/repository/login_repository.dart`
```dart
    try {
      final response = await _apiService.login(lang, request);

      if (response.success == true && response.data != null) {
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(response.message);
      }
    } catch (error) {
```

The repository treats a missing `data` object as failure even if the HTTP call itself succeeds.

#### SignupCubit
**File:** `lib/features/auth/signup/presentation/logic/signup_cubit.dart`

Validates whether national ID or passport is provided, normalizes the registration request, then stores the returned session data.

`lib/features/auth/signup/presentation/logic/signup_cubit.dart`
```dart
      final hasNationalId = nationalId != null && nationalId.isNotEmpty;
      final hasPassport = passportNumber != null && passportNumber.isNotEmpty;

      if (!hasNationalId && !hasPassport) {
        emit(
          const SignupState.failed(
            error: 'ÙŠØ¬Ø¨ Ø¥Ø¯Ø®Ø§Ù„ Ø¥Ù…Ø§ Ø§Ù„Ø±Ù‚Ù… Ø§Ù„Ù‚ÙˆÙ…ÙŠ Ø£Ùˆ Ø±Ù‚Ù… Ø¬ÙˆØ§Ø² Ø§Ù„Ø³ÙØ±',
          ),
        );
```

Signup requires at least one identity document. The Arabic string is present in source with encoding corruption.

#### SendOtpCubit
**File:** `lib/features/auth/login/presentation/logic/reset_password/cubit/send_otp_cubit.dart`

Starts the forgot-password flow by sending a mobile number to the backend.

`lib/features/auth/login/presentation/logic/reset_password/cubit/send_otp_cubit.dart`
```dart
  Future<void> sendOtp(String phoneNumber, String lang) async {
    emit(const SendOtpState.loading());
    final request = OtpRequestModel(mobileNumber: phoneNumber);
    final result =
        await resetPasswordRepository.sendOtp(request, lang);
    result.when(
      success: (data) {
        emit(SendOtpState.success(data));
```

The Cubit mirrors the common app pattern: construct request model -> repository call -> emit success/failure state.

### Data flow
Login flow: user submits login form -> `LoginCubit.login(cardNo, password, lang)` -> `LoginRepository.login()` -> `LoginApiService.login()` -> `POST {lang}/Auth/Login` -> returned token/member ID saved by `saveUserToken()` -> Crashlytics user context is set -> `FirebaseTokenService.instance.sendTokenToBackend(lang)` is fired -> `LoginState.success` drives navigation.

Password reset flow: forgot password screen -> `SendOtpCubit.sendOtp()` -> `ResetPasswordRepository.sendOtp()` -> `POST {lang}/ForgetPassword/SendOtp` -> OTP screen uses `VerifyOtpCubit` and `ResendOtpCubit` -> reset screen uses `ResetPasswordCubit`.

### Edge cases / notable logic

- Signup prefers national ID when both national ID and passport are provided.
- Login uses `DioFactory.getDioForLogin()`, which does not send an existing bearer token.
- `lib/features/auth/signup/presentation/otp_screen.dart` contains a commented TODO for OTP verification logic.

---

## Chat
**Location:** `lib/features/chat`

### What it does
Chat is a local UI-only support chat implementation. It stores messages in widget state and simulates agent responses after a delay; no repository or API service exists for this feature.

### Key classes

#### ChatScreen
**File:** `lib/features/chat/presentation/screens/chat_screen.dart`

Owns an in-memory `List<ChatMessage>` and appends both user and simulated agent messages.

`lib/features/chat/presentation/screens/chat_screen.dart`
```dart
  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
```

Blank messages are ignored. Valid messages are appended locally with a timestamp and `isUser: true`.

`lib/features/chat/presentation/screens/chat_screen.dart`
```dart
  void _simulateAgentResponse(String userMessage) {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: _getAgentResponse(userMessage),
            isUser: false,
            timestamp: DateTime.now(),
          ));
```

The simulated response waits one second and guards `mounted` before mutating state.

#### ChatInput
**File:** `lib/features/chat/presentation/widgets/chat_input.dart`

Tracks whether the input has text to switch between send and microphone behavior.

`lib/features/chat/presentation/widgets/chat_input.dart`
```dart
            onTap: () {
              if (_hasText) {
                widget.onSendMessage(widget.controller.text);
              } else {
                // TODO: Implement voice recording functionality
                print('Start voice recording...');
              }
            },
```

Voice recording is not implemented. The microphone branch only logs to console.

### Data flow
User types message -> `ChatInput` updates `_hasText` from the controller -> user taps send -> `widget.onSendMessage(widget.controller.text)` -> `ChatScreen._sendMessage()` appends user message -> `_simulateAgentResponse()` appends an agent message after one second -> `_buildMessagesList()` rebuilds from `_messages`.

### Edge cases / notable logic

- No backend, persistence, Cubit, repository, or service exists.
- The simulated response logic uses keyword checks in `_getAgentResponse()`.
- Voice recording is explicitly TODO.

---

## Chronic Medicines
**Location:** `lib/features/chronic_medicines`

### What it does
This feature has a UI for chronic medicine selection, family member selection, upcoming lab reminders, and lab result upload. It currently does not call a repository/API; save behavior is local UI validation only.

### Key classes

#### ChronicMedicinesScreen
**File:** `lib/features/chronic_medicines/screens/chronic_medicines_screen.dart`

Composes the chronic medicines form and validates that lab uploads are complete before save.

`lib/features/chronic_medicines/screens/chronic_medicines_screen.dart`
```dart
  Future<void> _onSave() async {
    final isComplete = _labKey.currentState?.isComplete ?? false;
    if (!isComplete && mounted) {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (context) => const ActionRequiredDialog(),
      );
      return;
```

The save button delegates completeness to the `LabResultsUploadState`. Missing uploads open an action-required dialog.

#### LabResultsUpload
**File:** `lib/features/chronic_medicines/widgets/lab_results_upload.dart`

Manages two required lab images and exposes `isComplete` to the parent screen through a `GlobalKey`.

`lib/features/chronic_medicines/widgets/lab_results_upload.dart`
```dart
class LabResultsUploadState extends State<LabResultsUpload> {
  ImageProvider? _bloodSugarImage;
  ImageProvider? _kidneyImage;
  VoidCallback? _rebuildDialog;

  bool get isComplete => _bloodSugarImage != null && _kidneyImage != null;


  Future<void> _showPickOptions({required bool forBlood}) async {
```

Completion is purely local: both the blood sugar and kidney images must be present.

`lib/features/chronic_medicines/widgets/lab_results_upload.dart`
```dart
    final result = await shared_sheet.showUploadPickerSheet(context);

    if (!mounted) return;
    if (result == null) return;
    setState(() {
      if (forBlood) {
        _bloodSugarImage = result.image;
      } else {
        _kidneyImage = result.image;
```

The shared upload picker returns an `UploadSelection`; the widget stores only an `ImageProvider`, not a file path for backend upload.

### Data flow
User opens chronic medicines -> route provides `FamilyMembersCubit` for the member selector -> user taps lab upload -> `LabResultsUpload._showUploadDialog()` -> `showUploadPickerSheet(context)` -> image preview state updates -> user taps save -> `ChronicMedicinesScreen._onSave()` checks `_labKey.currentState?.isComplete` -> shows dialog or local snackbar.

### Edge cases / notable logic

- Home quick access currently opens `ComingSoonDialog` for chronic medicines instead of navigating to `/chronic-medicines`.
- `// UI only for now` appears in `_onSave()`.
- Uploaded lab images are stored as `ImageProvider` previews, so no backend submission path exists yet.

---

## Entry
**Location:** `lib/features/entry`

### What it does
This folder exists but contains no Dart source files in the inspected codebase. There are no classes, screens, Cubits, repositories, or services to document.

### Key classes
No significant classes found.

### Data flow
No data flow found.

### Edge cases / notable logic
Treat this folder as a placeholder unless future source files are added.

---

## E-Card
**Location:** `lib/features/e_card`

### What it does
The e-card feature fetches, caches, and displays a member insurance card. It has notably more lifecycle logic than most screens: cache-owner resolution, offline fallback, image cache warming, connectivity-triggered refresh, and forced landscape display.

### Key classes

#### ECardCubit
**File:** `lib/features/e_card/presentation/cubit/e_card_cubit.dart`

Controls e-card loading, cached display, offline fallback, and refresh-on-connectivity.

`lib/features/e_card/presentation/cubit/e_card_cubit.dart`
```dart
  Future<void> load({required String lang, bool forceRefresh = false}) async {
    if (_isLoading) return;

    if (_useSeedData) {
      emit(const ECardLoaded(_seedData));
      return;
    }

    final currentState = state;
    final previousData = _previousData(currentState);
```

The Cubit prevents overlapping loads and supports a compile-time seed-data mode via `bool.fromEnvironment('ECARD_SEED')`.

`lib/features/e_card/presentation/cubit/e_card_cubit.dart`
```dart
        if (validFallback != null && validFallback.isValid()) {
          _emitCachedData(
            validFallback,
            isRefreshing: false,
            isOffline: true,
            noticeMessage: _nextOfflineNotice(),
          );
          return;
        }
```

If the fresh API fetch fails but a valid cache entry exists, the Cubit emits cached data with offline metadata instead of failing the screen.

#### ECardRepository
**File:** `lib/features/e_card/repository/e_card_repository.dart`

Reads/writes e-card data by owner key, validates cache expiry, fetches fresh data, and preloads card images.

`lib/features/e_card/repository/e_card_repository.dart`
```dart
    if (entry.isValid()) {
      return ECardCacheLookup(
        ownerKey: ownerKey,
        validEntry: entry,
        hadExpiredEntry: false,
      );
    }

    await _localDataSource.delete(ownerKey);
```

Expired cache entries are deleted before the repository reports `hadExpiredEntry: true`.

`lib/features/e_card/repository/e_card_repository.dart`
```dart
      final response = await _apiService.getECard(lang);
      final data = response.data;
      if (response.success && data != null && data.hasMeaningfulData) {
        await _localDataSource.save(effectiveOwnerKey, data);
        _warmImageCache(data);
        return ApiResult.success(data);
      }
```

The repository only caches data when the response is successful and `ECardData.hasMeaningfulData` is true.

#### ECardScreen
**File:** `lib/features/e_card/presentation/screens/e_card_screen.dart`

Forces landscape while the card is open and returns to portrait before popping the route.

`lib/features/e_card/presentation/screens/e_card_screen.dart`
```dart
  Future<void> _setLandscapeOrientation() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _setNativeOrientation('landscape');
      return;
    }

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
```

iOS uses a method channel for orientation; other platforms use `SystemChrome`.

### Data flow
User taps e-card in bottom navigation -> `HomeScreen._openECardRoute()` -> GoRouter route `/e-card` creates `ECardCubit()..load(lang: 'ar')` -> `ECardCubit.load()` reads cache through `ECardRepository.readCache()` -> `ECardRepository.fetchFreshECard()` calls `ECardApiService.getECard()` -> `GET {lang}/Ecard/Get` -> repository saves valid data -> Cubit emits `ECardLoaded` -> `ECardScreen` renders `MembershipCardWidget`.

### Edge cases / notable logic

- The route hardcodes `lang: 'ar'` in `app_router.dart`.
- Offline cache notices are emitted only once via `_offlineNoticeEmitted`.
- Connectivity refresh is debounced by 450 ms when an offline cached card is visible.
- The screen waits for portrait metrics before popping to avoid visual orientation glitches.

---

## Family Members
**Location:** `lib/features/family_members`

### What it does
Loads and displays family members for the current language. It uses both repository-level cache and Cubit-level cache-first behavior, with forced refresh when language changes.

### Key classes

#### FamilyMembersCubit
**File:** `lib/features/family_members/presentation/cubit/family_members_cubit.dart`

Loads cached family members, emits them immediately, and refreshes in the background.

`lib/features/family_members/presentation/cubit/family_members_cubit.dart`
```dart
      if (!forceRefresh) {
        final cachedData = await CacheService.getCachedFamilyData(lang);
        if (cachedData != null) {
          emit(FamilyMembersState.loaded(cachedData));
          
          // Background refresh if needed
          unawaited(_fetchAndCacheData(lang));
          return;
```

This is the standard cache-first pattern used across the app.

#### FamilyMemberRepository
**File:** `lib/features/family_members/repository/family_member_repo.dart`

Calls the family member service and maps Dio exceptions through app-level failure types.

`lib/features/family_members/repository/family_member_repo.dart`
```dart
    } on DioException catch (e) {
      // Convert DioException to AppFailure
      final failure = mapDioException(e);
      final errorMessage = AppErrorHandler.messageFromFailure(failure);
      return ApiResult.failure(errorMessage);
    } catch (error) {
      // Handle other errors (parsing errors, etc.)
      final errorMessage = AppErrorHandler.getUserFriendlyMessage(error.toString());
```

Unlike simpler repositories, this one explicitly maps `DioException` into `AppFailure` before creating a user-friendly error message.

#### FamilyMembersScreen
**File:** `lib/features/family_members/presentation/family_members_screen.dart`

Reloads data when the locale changes and renders shimmer, error, empty, or list states.

`lib/features/family_members/presentation/family_members_screen.dart`
```dart
      if (isLanguageChange) {
        // Clear cache and reload with new language
        context.read<FamilyMembersCubit>().clearCache();
      }
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Always force refresh to ensure data matches current language
```

The screen avoids stale-language data by clearing cache and forcing a refresh after locale changes.

### Data flow
User opens family members -> `FamilyMembersScreen.didChangeDependencies()` determines language -> `FamilyMembersCubit.getFamilyMembers(lang, forceRefresh: true)` -> `FamilyMemberRepository.getFamilyMembers()` -> `FamilyMemberApiService.getFamilyMembers()` -> `GET {lang}/FamilyMember/GetFamilyMembers` -> response cached in `FamilyCacheService` -> Cubit emits `FamilyMembersState.loaded` -> screen renders member cards.

### Edge cases / notable logic

- Language changes clear family cache.
- Empty family lists use `EmptyListWidget` with refresh.
- Repository has duplicate cache access separate from Cubit cache access.

---

## Home
**Location:** `lib/features/home`

### What it does
Home loads member dashboard data and drives top-level navigation to network, approval request, profile, and e-card. It also updates notification badge counts from home API/cache data.

### Key classes

#### HomeCubit
**File:** `lib/features/home/presentation/cubit/cubit/home_cubit.dart`

Loads home info with cache-first/background-refresh behavior and updates global notification badge state.

`lib/features/home/presentation/cubit/cubit/home_cubit.dart`
```dart
        final cachedData = await CacheService.getCachedHomeData();
        if (cachedData != null) {
          // Update notification badge count from cache
          NotificationBadgeService.instance.setCount(
            cachedData.data!.notificationsCount,
          );
          emit(HomeCubitState.loaded(cachedData));

          // IF CACHE IS EXPIRED
```

Cached home data updates the notification badge immediately, then a background fetch refreshes the cache.

`lib/features/home/presentation/cubit/cubit/home_cubit.dart`
```dart
      failure: (message) async {
        // Try to get cached data if API fails
        final cachedData = await CacheService.getCachedHomeData();
        if (cachedData != null) {
          // Update notification badge count from cache
          NotificationBadgeService.instance.setCount(
            cachedData.data!.notificationsCount,
          );
```

If the API fails, Home falls back to any cached home data before emitting failure.

#### HomeScreen
**File:** `lib/features/home/presentation/home_screen.dart`

Owns bottom navigation behavior and listens for global home refresh events.

`lib/features/home/presentation/home_screen.dart`
```dart
    _refreshSubscription = HomeRefreshService().refreshStream.listen((_) {
      if (mounted && _hasLoadedOnce) {
        // Refresh home data when approval request is created
        final lang = LanguageHelper.getLanguageCode(context);
        context.read<HomeCubit>().refreshHomeInfo(lang);
      }
    });
```

Home subscribes to `HomeRefreshService`; when another workflow notifies refresh, it reloads if home has already loaded.

`lib/features/home/presentation/home_screen.dart`
```dart
      case 1:
        context.push('/network');
        break;
      case 2:
        context.push('/approval-request');
        break;
      case 3:
        final homeResponse = context.read<HomeCubit>().state.maybeWhen(
```

Bottom navigation maps visual indices to routes. The profile route receives cached home response through `extra`.

### Data flow
User lands on `/home` -> `HomeScreen.initState()` schedules `_checkPermissionsAndLoadData()` -> `HomeCubit.getHomeInfo(lang)` -> `CacheService.getCachedHomeData()` may emit cached dashboard -> `_fetchAndCacheData()` calls `HomeRepository.getHomeInfo()` -> `HomeApiService.getHomeInfo()` -> `GET {lang}/Home/GetHomeInfo` -> `CacheService.cacheHomeData()` -> notification badge updated -> `HomeCubitState.loaded` rebuilds the dashboard.

### Edge cases / notable logic

- Lifecycle auto-refresh is commented out; manual refresh and refresh-stream events drive updates.
- E-card route opening is guarded by `_isECardRouteOpen` to prevent duplicate route pushes.
- Chronic medicines quick access shows a coming-soon dialog instead of navigating to its route.

---

## Medicard Network
**Location:** `lib/features/medicard_network`

### What it does
This feature mirrors provider-network browsing against the separate Medicard API host. It loads categories/governments first, then searches providers with filters and pagination.

### Key classes

#### MedicardNetworkCubit
**File:** `lib/features/medicard_network/logic/medicard_network_cubit.dart`

Stores all filter state in a custom state class and reloads providers when category/government/city/search changes.

`lib/features/medicard_network/logic/medicard_network_cubit.dart`
```dart
  Future<void> loadInitialData(String lang) async {
    emit(MedicardNetworkLoading());

    List<NetworkCategory> categories = [];
    List<Government> governments = [];

    final categoriesResult = await _repository.getCategories(lang);
    final governmentsResult = await _repository.getGovernments(lang);
```

Initial load performs category and government requests, tolerating individual failures by leaving lists empty.

`lib/features/medicard_network/logic/medicard_network_cubit.dart`
```dart
  Future<void> selectGovernment(int? governmentId, String lang) async {
    final currentState = state;
    if (currentState is MedicardNetworkLoaded) {
      _currentPage = 1;

      List<City> cities = [];
      if (governmentId != null) {
        final citiesResult = await _repository.getCitiesByGovernment(lang, governmentId);
```

Selecting a government resets pagination and conditionally loads city options before searching providers.

#### MedicardNetworkRepository
**File:** `lib/features/medicard_network/repository/medicard_network_repository.dart`

Wraps Medicard API calls into `ApiResult`.

`lib/features/medicard_network/repository/medicard_network_repository.dart`
```dart
      final response = await _apiService.searchProviders(
        lang,
        searchKey: searchKey,
        categoryId: categoryId,
        governmentId: governmentId,
        cityId: cityId,
        latitude: latitude,
        longitude: longitude,
```

The repository passes filter and location fields through to the external API service.

#### MedicardNetworkApiService
**File:** `lib/features/medicard_network/service/medicard_network_api_service.dart`

Defines Retrofit endpoints for the external Medicard base URL.

`lib/features/medicard_network/service/medicard_network_api_service.dart`
```dart
@RestApi(baseUrl: 'https://api.medicardeg.com/api/')
abstract class MedicardNetworkApiService {
  factory MedicardNetworkApiService(Dio dio, {String baseUrl}) = _MedicardNetworkApiService;

  @GET("/{lang}/Network/GetCategories")
  Future<NetworkCategoryResponse> getCategories(
    @Path("lang") String lang,
  );
```

This service does not use `ApiConstants.baseUrl`; the base URL is hardcoded to the external host.

### Data flow
User opens Medicard network screen -> `MedicardNetworkCubit.loadInitialData(lang)` -> `MedicardNetworkRepository.getCategories()` and `getGovernments()` -> `MedicardNetworkApiService` calls external endpoints -> Cubit emits `MedicardNetworkLoaded` with filters/options -> `_searchProviders(lang)` -> `GET /{lang}/Network/GetNetwork` on `api.medicardeg.com` -> providers list updates.

### Edge cases / notable logic

- Dedicated Dio client omits MCI authorization headers.
- `loadInitialData()` ignores category/government failures and still emits a loaded state.
- `medicard_network_screen.dart` has a TODO for provider detail navigation.

---

## Network
**Location:** `lib/features/network`

### What it does
The network feature searches the main MediConsult provider network by category, government, city, text, and optional user location. It caches reference data such as categories/governments/cities and paginates provider results.

### Key classes

#### NetworkCubit
**File:** `lib/features/network/logic/network_cubit.dart`

Owns filters, cached dropdown data, provider pagination, and location permission flow.

`lib/features/network/logic/network_cubit.dart`
```dart
  bool get hasActiveFilters =>
      _selectedCategoryId != null ||
      _selectedGovernmentId != null ||
      _selectedCityId != null ||
      (_searchKey != null && _searchKey!.isNotEmpty);

  /// Get all categories with caching
  Future<void> getCategories({
```

The Cubit derives active-filter state from private filter fields rather than storing another flag.

`lib/features/network/logic/network_cubit.dart`
```dart
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      // Permission already granted, get location directly without showing dialog
      await getUserLocation();
      // If location retrieved successfully, load providers
      if (_userLatitude != null && _userLongitude != null) {
        await searchProviders(resetPage: true, context: context);
```

When permission is already granted, the feature avoids showing the custom permission dialog and directly loads location-aware providers.

`lib/features/network/logic/network_cubit.dart`
```dart
    final result = await _repository.searchProviders(
      language,
      searchKey: _searchKey,
      categoryId: _selectedCategoryId,
      governmentId: _selectedGovernmentId,
      cityId: _selectedCityId,
      latitude: _userLatitude,
      longitude: _userLongitude,
```

Provider searches are built from the Cubit's current filter/location fields.

#### NetworkRepository
**File:** `lib/features/network/repository/network_repository.dart`

Wraps network category/provider/government/city endpoints into `ApiResult`.

`lib/features/network/repository/network_repository.dart`
```dart
      final response = await _apiService.searchProviders(
        lang,
        searchKey: searchKey,
        categoryId: categoryId,
        governmentId: governmentId,
        cityId: cityId,
        latitude: latitude,
        longitude: longitude,
        page: page,
```

The repository is pass-through with success checking and error normalization.

#### NetworkApiService
**File:** `lib/features/network/service/network_api_service.dart`

Defines the main MediConsult network endpoints.

`lib/features/network/service/network_api_service.dart`
```dart
  @GET('/{lang}/Network/GetNetwork')
  Future<NetworkProviderResponse> searchProviders(
    @Path('lang') String lang, {
    @Query("search") String? searchKey,
    @Query("categoryId") int? categoryId,
    @Query("governmentId") int? governmentId,
    @Query("cityId") int? cityId,
    @Query("latitude") double? latitude,
```

The Retrofit method exposes all search and location filters as optional query parameters.

### Data flow
User opens `/network` -> screen calls `NetworkCubit.getCategories()`, `getGovernments()`, and `requestLocationWithDialog()`/`searchProviders()` -> `NetworkCubit.searchProviders()` builds filters -> `NetworkRepository.searchProviders()` -> `NetworkApiService.searchProviders()` -> `GET /{lang}/Network/GetNetwork` -> Cubit emits `providersSuccess`, `providersEmpty`, or `providersError` -> list/map widgets rebuild.

### Edge cases / notable logic

- Location "Allow Once" expiration is handled by rechecking permission and clearing cached lat/long.
- Category/government/city lists are cached and background-refreshed.
- Empty provider responses emit `NetworkState.providersEmpty()` while still preserving filter metadata in `_currentProviderData`.

---

## Notifications
**Location:** `lib/features/notifications`

### What it does
Notifications includes both backend notification list management and Firebase push/local notification handling. The list Cubit supports pagination, cache-first loading, optimistic read updates, and badge count synchronization.

### Key classes

#### NotificationsCubit
**File:** `lib/features/notifications/presentation/cubit/notifications_cubit.dart`

Loads notifications, updates badge counts, and performs optimistic mark-as-read actions.

`lib/features/notifications/presentation/cubit/notifications_cubit.dart`
```dart
    if (_page == 1 && !forceRefresh) {
      final cachedData = await CacheService.getCachedNotificationsData();
      if (cachedData != null && cachedData.data != null) {
        final data = cachedData.data!;
        _items.clear();
        _items.addAll(data.notifications);
        NotificationBadgeService.instance.setCount(_items.where((e) => !e.isRead).length);
```

First page cache is used to render quickly and set badge count from unread items.

`lib/features/notifications/presentation/cubit/notifications_cubit.dart`
```dart
    final oldItem = _items[index];
    _items[index] = NotificationItem(
      id: oldItem.id,
      title: oldItem.title,
      body: oldItem.body,
      imageUrl: oldItem.imageUrl,
      isSeen: 1,
      date: oldItem.date,
```

Mark-as-read mutates the local item first, then emits a copied list to force UI rebuild.

#### NotificationRepository
**File:** `lib/features/notifications/repository/notification_repository.dart`

Wraps notification API calls and treats 2xx Retrofit `HttpResponse` values as successful read actions.

`lib/features/notifications/repository/notification_repository.dart`
```dart
      final res = await _notificationService.markAsRead(lang, notificationId);
      if (res.response.statusCode != null && res.response.statusCode! >= 200 && res.response.statusCode! < 300) {
        return const ApiResult.success(true);
      }
      return const ApiResult.failure('Failed to mark as read');
    } catch (e) {
```

The repository validates HTTP status codes for endpoints that return dynamic bodies.

#### PushNotificationService
**File:** `lib/features/notifications/service/push_notifications_service.dart`

Initializes Firebase Messaging and local notifications, requests permissions, handles background messages, and exposes streams for notification actions/token changes.

`lib/features/notifications/service/push_notifications_service.dart`
```dart
      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Request permissions
      final permissionGranted = await _requestPermission();
      if (!permissionGranted) {
```

Initialization sets the background handler before asking for permissions and configuring local notifications.

### Data flow
List flow: user opens notifications -> `NotificationsCubit.load(lang)` -> cache may emit immediately -> `NotificationRepository.getNotifications()` -> `NotificationService.getNotifications()` -> `GET {lang}/Notifications/GetAll` -> Cubit appends notifications and updates `NotificationBadgeService`.

Read flow: user taps a notification -> `NotificationsCubit.markAsRead(lang, notificationId)` -> local item is optimistically changed to `isSeen: 1` -> badge decrements -> `NotificationRepository.markAsRead()` -> `POST {lang}/Notifications/MarkAsReadById/{notificationId}` -> failure reverts old item and badge.

### Edge cases / notable logic

- `updateCounter` is incremented to force UI rebuild after optimistic updates.
- `markAllAsRead()` stores a copy of all old items and reverts on API failure.
- Push image support checks several data keys: `image`, `imageUrl`, `picture`, and Android image URL.

---

## Onboarding
**Location:** `lib/features/onboarding`

### What it does
Onboarding is a local first-run UI flow. It displays a welcome page plus three translated onboarding pages and persists `hasSeenOnboarding` when the user finishes or skips.

### Key classes

#### OnboardingScreen
**File:** `lib/features/onboarding/onboarding_screen.dart`

Owns the page controller, page definitions, indicator state, and finish behavior.

`lib/features/onboarding/onboarding_screen.dart`
```dart
  Future<void> _finish() async {
    await SharedPrefHelper.setData(SharedPrefKeys.hasSeenOnboarding, true);
    shouldShowOnboarding = false;
    if (!mounted) return;
    context.go(isLoggedInUser ? '/home' : '/login');
  }
```

Finishing onboarding writes persistent state, updates the global runtime flag, and routes based on login status.

`lib/features/onboarding/onboarding_screen.dart`
```dart
  final List<OnboardingModel> _pages = [
    OnboardingModel(
      image: 'assets/onboarding/2.png',
      title: 'onboarding.insurance_in_pocket',
      description: 'onboarding.insurance_description',
    ),
```

The pages are static local models using translation keys and asset paths.

### Data flow
User sees onboarding -> PageView updates `_currentPage` -> user taps skip/finish -> `_finish()` -> `SharedPrefHelper.setData(SharedPrefKeys.hasSeenOnboarding, true)` -> `shouldShowOnboarding = false` -> navigate to `/home` or `/login`.

### Edge cases / notable logic

- The app currently starts from `/home` or `/login`; the onboarding global flag is set during startup but is not part of the `AppRouter.initialLocation` in the inspected code.

---

## Policy
**Location:** `lib/features/policy`

### What it does
Policy loads coverage categories and category-specific policy details from the backend. The screen uses in-app `Navigator.push` to show `PolicyDetailsScreen` rather than defining every detail route in GoRouter.

### Key classes

#### GetPolicyCategoriesCubit
**File:** `lib/features/policy/presentation/cubit/get_policy_categories_cubit.dart`

Loads policy category data and records failures in Crashlytics.

`lib/features/policy/presentation/cubit/get_policy_categories_cubit.dart`
```dart
  Future<void> getPolicyCategories(String lang) async {
    emit(GetPolicyCategoriesState.loading());
    final response = await _repository.getPolicyCategories(lang);

    response.when(
      success: (data) {
        emit(GetPolicyCategoriesState.loaded(data));
      },
```

This is a simple load state machine: loading -> loaded/failed.

#### GetPolicyDetailsCubit
**File:** `lib/features/policy/presentation/cubit/get_policy_details_cubit.dart`

Loads a single category's policy details by `categoryId`.

`lib/features/policy/presentation/cubit/get_policy_details_cubit.dart`
```dart
  Future<void> getDetails(String lang, int categoryId) async {
    emit(const GetPolicyDetailsState.loading());
    
    try {
      final response = await _repository.getByCategoryId(lang, categoryId);
      response.when(
        success: (data) => emit(GetPolicyDetailsState.loaded(data)),
```

The Cubit catches unexpected exceptions separately from repository-level `ApiResult` failures.

#### PolicyDetailsScreen
**File:** `lib/features/policy/presentation/policy_details_screen.dart`

Creates its own details Cubit and triggers loading once after first build.

`lib/features/policy/presentation/policy_details_screen.dart`
```dart
              if (!_hasLoaded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<GetPolicyDetailsCubit>().getDetails(
                    LanguageHelper.getLanguageCode(context),
                    widget.categoryId,
                  );
                });
                _hasLoaded = true;
```

The `_hasLoaded` guard prevents repeated API calls during rebuilds.

#### GetPolicyDetailsRepository
**File:** `lib/features/policy/repository/get_policy_details_repo.dart`

Calls the Retrofit details service and returns `ApiResult`.

`lib/features/policy/repository/get_policy_details_repo.dart`
```dart
      final response = await _service.getPolicyDetailsByCategory(lang, categoryId);
      if (response.success == true) {
        return ApiResult.success(response);
      } else {
        // Ù…Ø¹Ø§Ù„Ø¬Ø© Ø±Ø³Ø§Ø¦Ù„ Ø§Ù„Ø®Ø·Ø£ Ù…Ù† Ø§Ù„Ø®Ø§Ø¯Ù…
        return ApiResult.failure(response.message);
      }
```

Backend `success == false` is treated as application-level failure even when HTTP succeeds.

### Data flow
User opens `/policy` -> `PolicyScreen` creates `GetPolicyCategoriesCubit` -> `getPolicyCategories(lang)` -> `GetPolicyCategoriesRepository.getPolicyCategories()` -> `GET {lang}/Policy/GetPolicyCategories` -> categories render -> user taps category -> `Navigator.push(PolicyDetailsScreen(categoryId))` -> `GetPolicyDetailsCubit.getDetails(lang, categoryId)` -> `GET {lang}/Policy/GetPolicyDetaliesByCateogryId?categoryId=...` -> details and providers render.

### Edge cases / notable logic

- Endpoint name is spelled `GetPolicyDetaliesByCateogryId` in source and should not be "corrected" unless backend changes.
- `policy_mock_data.dart` remains for tests/backward compatibility.
- GoRouter comment says deprecated specific policy detail routes were removed.

---

## Profile
**Location:** `lib/features/profile`

### What it does
Profile contains personal info, logout, password change, language selection, family/support navigation, insurance plan UI, FAQ/contact entry points, and terms/privacy entry points. It coordinates cache clearing and secure storage cleanup during logout.

### Key classes

#### ProfileScreen
**File:** `lib/features/profile/presentation/profile_screen.dart`

Builds the profile menu and owns logout behavior.

`lib/features/profile/presentation/profile_screen.dart`
```dart
      // Clear token
      await SharedPrefHelper.removeData(SharedPrefKeys.userToken);
      if (sl.isRegistered<ECardRepository>()) {
        await sl<ECardRepository>().clearCurrentUserCache();
      }

      // Update login status
      isLoggedInUser = false;
```

Logout clears session data and e-card cache for the current user before flipping the global login flag.

`lib/features/profile/presentation/profile_screen.dart`
```dart
      // Restore onboarding status (don't show onboarding again after logout)
      await SharedPrefHelper.setData(
        SharedPrefKeys.hasSeenOnboarding,
        hasSeenOnboarding,
      );

      // Clear secure storage (token)
      await SharedPrefHelper.clearAllSecuredData();
```

The screen preserves onboarding completion even while clearing broader preferences.

#### PersonalInfoCubit
**File:** `lib/features/profile/presentation/cubit/personal_info_cubit.dart`

Loads personal info from cache first and refreshes in the background.

`lib/features/profile/presentation/cubit/personal_info_cubit.dart`
```dart
      success: (data) async {
        await CacheService.cachePersonalInfo(data.toJson());
        emit(PersonalInfoState.loaded(data));
      },
      failure: (message) async {
        final cached = await CacheService.getCachedPersonalInfo();
        if (cached != null) {
```

On API failure, cached personal info is preferred over showing an error.

#### ChangePasswordCubit
**File:** `lib/features/profile/presentation/cubit/change_password_cubit.dart`

Submits old/new/confirm password to the repository and emits password change states.

`lib/features/profile/presentation/cubit/change_password_cubit.dart`
```dart
    final response = await _repository.changePassword(
      lang: lang,
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );

    response.when(
      success: (response) {
```

The Cubit passes the form fields directly through to the repository; validation is handled in UI/repository layers [INFERRED].

#### LanguageCubit
**File:** `lib/features/profile/presentation/cubit/language_cubit.dart`

Wraps `LanguageService` for saved-language load/change state.

`lib/features/profile/presentation/cubit/language_cubit.dart`
```dart
  Future<void> changeLanguage(String languageCode) async {
    try {
      emit(const LanguageState.loading());
      await _languageService.saveLanguage(languageCode);
      emit(LanguageState.loaded(languageCode));
    } catch (e) {
      emit(LanguageState.error(e.toString()));
```

Changing language is persisted before the loaded state is emitted.

### Data flow
Logout flow: user taps logout -> `LogoutDialog.show(context)` -> `_handleLogout()` -> read onboarding flag -> clear token, e-card cache, app caches, shared preferences, secure storage, Crashlytics user data -> restore onboarding flag -> `context.go('/login')`.

Personal info flow: screen calls `PersonalInfoCubit.load(lang)` -> cached JSON may emit immediately -> `ProfileRepository.getPersonalInfo()` -> `ProfileApiService.getPersonalInfo()` -> `GET /{lang}/Profile/GetPersonalInfo` -> cache updated -> `PersonalInfoState.loaded`.

### Edge cases / notable logic

- Logout clears multiple caches but preserves onboarding.
- `SharedPrefHelper.removeData(SharedPrefKeys.userToken)` clears non-secure data first; secure storage is cleared later.
- Profile can receive a `HomeResponse` through route `extra` and seed `HomeCubit` via `showCachedHomeInfo()`.

---

## Providers
**Location:** `lib/features/providers`

### What it does
Providers is a reusable provider search/list feature, used by provider selectors such as approval request provider selection. It supports pagination, search, category filtering, an in-memory first-page search cache, and duplicate prevention when loading more.

### Key classes

#### ProvidersCubit
**File:** `lib/features/providers/presentation/cubit/providers_cubit.dart`

Loads provider pages and caches first-page search results in memory.

`lib/features/providers/presentation/cubit/providers_cubit.dart`
```dart
    if (page == 1 && _searchCache.containsKey(searchKey) && search == _lastSearchTerm) {
      final cachedProviders = _searchCache[searchKey]!;
      emit(ProvidersState.loaded(
        providers: cachedProviders,
        pagination: Pagination(
          currentPage: 1,
          pageSize: pageSize,
```

The Cubit short-circuits API calls when the same first-page search was already loaded.

`lib/features/providers/presentation/cubit/providers_cubit.dart`
```dart
            // Use Set to avoid duplicates, then convert back to List
            final existingIds = current.providers.map((p) => p.id).toSet();
            final newProviders = data.providers.where((p) => !existingIds.contains(p.id)).toList();
            final merged = [...current.providers, ...newProviders];
            
            emit(ProvidersState.loaded(
```

Pagination merge removes duplicate provider IDs before emitting the combined list.

#### ProvidersRepository
**File:** `lib/features/providers/repository/providers_repository.dart`

Calls the providers API and requires both `success == true` and `data != null`.

`lib/features/providers/repository/providers_repository.dart`
```dart
      if (response.success == true && response.data != null) {
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(response.message ?? 'Unknown error');
      }
    } catch (error) {
      final errorMessage = ErrorHandler.handle(error);
```

The repository normalizes backend failures and missing data into `ApiResult.failure`.

#### ProvidersApiService
**File:** `lib/features/providers/service/providers_api_service.dart`

Defines the provider list endpoint.

`lib/features/providers/service/providers_api_service.dart`
```dart
  @GET("{lang}/Providers/GetProviders")
  Future<ProvidersResponse> getProviders(
    @Path("lang") String lang,
    @Query("page") int page,
    @Query("pageSize") int pageSize,
    @Query("search") String? search,
```

The service exposes pagination, search, and optional category filtering.

### Data flow
User opens provider picker -> `ProvidersCubit.loadProviders(lang, page, search, categoryId)` -> optional in-memory cache hit -> `ProvidersRepository.getProviders()` -> `ProvidersApiService.getProviders()` -> `GET {lang}/Providers/GetProviders` -> Cubit emits `ProvidersState.loaded` -> selector/list UI renders providers.

### Edge cases / notable logic

- Cache key is `search ?? 'all'`, and cache is only used when `search == _lastSearchTerm`.
- Duplicate providers are removed by ID during load-more merges.
- No persistent cache is used here.

---

## Refund
**Location:** `lib/features/refund`

### What it does
Refund handles refund submission, refund type/reason lookup, refund history, status filtering, member filtering, attachments, validation, and PDF retrieval. It uses multipart upload for create requests and cache-first history loading.

### Key classes

#### RefundRequestScreen
**File:** `lib/features/refund/presentation/screens/refund_request_screen.dart`

Owns refund form state and validation before calling `RefundRequestCubit`.

`lib/features/refund/presentation/screens/refund_request_screen.dart`
```dart
    if (_selectedMember == null) {
      _showError('refund_request.validation.select_member'.tr());
      await FormValidationService.scrollToField(
        scrollController: _scrollController,
        fieldKey: _memberKey,
      );
      return;
    }
```

The screen stops at the first invalid required field and scrolls to it.

`lib/features/refund/presentation/screens/refund_request_screen.dart`
```dart
    final daysDifference = today.difference(selectedDateOnly).inDays;
    if (daysDifference > 59) {
      _showError('refund_request.validation.date_too_old'.tr());
      return;
    }

    if (!_hasAllRequiredAttachments) {
```

Refund dates cannot be more than 59 days old, and all required attachments must be present.

#### RefundRequestCubit
**File:** `lib/features/refund/presentation/cubit/refund_request_cubit.dart`

Submits a validated refund request and maps repository failure messages through `AppErrorHandler`.

`lib/features/refund/presentation/cubit/refund_request_cubit.dart`
```dart
    result.when(
      success: (response) {
        emit(RefundRequestState.success(response.data!));
      },
      failure: (message) {
        // Friendly message for UI using centralized handler
        final friendlyMessage = AppErrorHandler.getUserFriendlyMessage(message);
```

Failures are converted to friendlier UI messages before being emitted.

#### RefundsCubit
**File:** `lib/features/refund/presentation/cubit/refunds_cubit.dart`

Loads refund history by status/member with persistent first-page cache and in-memory pagination cache.

`lib/features/refund/presentation/cubit/refunds_cubit.dart`
```dart
    if (_page == 1 && !forceRefresh && _memberId == null) {
      final cachedData = await CacheService.getCachedRefundsData(_status);
      if (cachedData != null && cachedData.data != null) {
        final data = cachedData.data!;
        _cache[_status] = data.refunds;
        _paginationCache[_status] = data.pagination;
```

Persistent cache is only used for first-page status views, not member-filtered lists.

#### RefundRepository
**File:** `lib/features/refund/repository/refund_repository.dart`

Converts file paths to multipart attachments, calls create/list/type/reason/PDF endpoints, and wraps results.

`lib/features/refund/repository/refund_repository.dart`
```dart
      // Convert file paths to MultipartFile
      final List<MultipartFile> attachments = [];
      for (String path in attachmentPaths) {
        final file = await MultipartFile.fromFile(path);
        attachments.add(file);
      }

      final response = await _apiService.createRefundRequest(
```

Like approvals, multipart conversion lives in the repository.

#### RefundApiService
**File:** `lib/features/refund/service/refund_api_service.dart`

Defines refund Retrofit endpoints.

`lib/features/refund/service/refund_api_service.dart`
```dart
  @POST("{lang}/Refund/Create")
  @MultiPart()
  Future<RefundRequestResponse> createRefundRequest(
    @Path("lang") String lang,
    @Part(name: "memberId") int memberId,
    @Part(name: "refundTypeId") int refundTypeId,
    @Part(name: "refundReasonId") int refundReasonId,
```

Create refund is multipart and includes member, type, reason, amount/date/provider fields, notes, and attachments.

### Data flow
User taps submit -> `RefundRequestScreen._submitRefundRequest()` validates member/type/provider/reason/amount/date/notes/attachments -> formats date as `yyyy-MM-dd` -> `RefundRequestCubit.createRefundRequest()` -> `RefundRepository.createRefundRequest()` converts paths to `MultipartFile` -> `RefundApiService.createRefundRequest()` -> `POST {lang}/Refund/Create` -> Cubit emits `RefundRequestState.success` or `failed`.

History flow: `RefundsCubit.load()` -> persistent cache may emit first page -> `RefundRepository.getRefunds()` chooses `getRefundsByMember` if `memberId != null`, otherwise `getRefunds` -> Cubit caches/merges and emits loaded state.

### Edge cases / notable logic

- Provider name must be at least two characters.
- Notes are limited to 300 characters.
- Future dates are rejected.
- Service date older than 59 days is rejected.
- Amount must be between 1 and 100000.
- `getRefundPdf()` uses a 10-second timeout.

---

## Shared
**Location:** `lib/features/shared`

### What it does
This feature folder currently contains a shared upload picker used by chronic medicines and likely reusable for other upload flows. It returns an `UploadSelection` containing preview image and file name.

### Key classes

#### UploadSelection and showUploadPickerSheet
**File:** `lib/features/shared/upload/upload_picker_sheet.dart`

Shows a modal bottom sheet with camera and gallery choices, previews the selected image, and returns the selected preview.

`lib/features/shared/upload/upload_picker_sheet.dart`
```dart
class UploadSelection {
  UploadSelection({required this.image, required this.name});
  final ImageProvider image;
  final String name;
}

Future<UploadSelection?> showUploadPickerSheet(BuildContext context) async {
```

The public API is a function returning a nullable selection.

`lib/features/shared/upload/upload_picker_sheet.dart`
```dart
                                  onTap: () async {
                                    final picked = await ImagePickerService.pickFromCameraWithPermission();
                                    if (picked != null) {
                                      setModalState(() {
                                        previewCameraImage = FileImage(File(picked.path));
                                        previewCameraName = picked.name;
                                      });
```

Camera selection uses `ImagePickerService.pickFromCameraWithPermission()` and stores a `FileImage` preview.

### Data flow
Caller awaits `showUploadPickerSheet(context)` -> user chooses camera/gallery -> image picker returns a picked file -> modal stores `FileImage`/name preview -> user taps Upload -> modal pops `UploadSelection(image, name)` or `null`.

### Edge cases / notable logic

- This picker returns preview data, not the file path. Features that need backend upload must keep their own file paths separately.

---

## Splash
**Location:** `lib/features/splash`

### What it does
This folder exists but contains no Dart source files in the inspected codebase. Splash behavior appears to be configured through Flutter/native splash configuration rather than a feature screen.

### Key classes
No significant classes found.

### Data flow
No Dart feature-level data flow found.

### Edge cases / notable logic
Check `flutter_native_splash.yaml` and platform native assets for splash behavior.

---

## Support
**Location:** `lib/features/support`

### What it does
Support loads contact information and FAQs from the backend. Both Cubits use cache-first behavior and background refresh, with FAQ adding a cache-cleared flag to avoid showing stale data after explicit cache clearing.

### Key classes

#### ContactCubit
**File:** `lib/features/support/presentation/cubit/contact_cubit.dart`

Loads support contact data and falls back to cached contacts when API refresh fails.

`lib/features/support/presentation/cubit/contact_cubit.dart`
```dart
        final cached = await CacheService.getCachedContactsData();
        if (cached != null) {
          final data = ContactsResponse.fromJson(cached);
          if (!isClosed) {
            emit(ContactState.loaded(data));
          }
          unawaited(_fetchAndCache(lang));
```

The Cubit checks `isClosed` before emitting because the async refresh can complete after screen disposal.

#### FaqCubit
**File:** `lib/features/support/presentation/cubit/faq_cubit.dart`

Loads FAQs and prevents old cache from being reused immediately after `clearCache()`.

`lib/features/support/presentation/cubit/faq_cubit.dart`
```dart
      // If cache was cleared, always force refresh
      if (_cacheCleared) {
        forceRefresh = true;
        _cacheCleared = false; // Reset flag after using it
      }
      
      if (!forceRefresh) {
```

The flag forces one post-clear load to bypass cache.

#### SupportRepository
**File:** `lib/features/support/repository/support_repository.dart`

Wraps contact and FAQ service calls.

`lib/features/support/repository/support_repository.dart`
```dart
  Future<ApiResult<ContactsResponse>> getContacts(String lang) async {
    try {
      final response = await _apiService.getContacts(lang);
      if (response.success == true) {
        return ApiResult.success(response);
      } else {
        return ApiResult.failure(response.message);
```

Support repository methods follow the app-wide success flag check.

#### SupportApiService
**File:** `lib/features/support/service/support_api_service.dart`

Defines contact and FAQ endpoints.

`lib/features/support/service/support_api_service.dart`
```dart
  /// Contacts endpoint: /{lang}/ContactUs/Get
  @GET('/{lang}/ContactUs/Get')
  Future<ContactsResponse> getContacts(@Path('lang') String lang);

  @GET('/{lang}/FAQ/GetFAQs')
  Future<FAQResponse> getFaqs(@Path('lang') String lang);
```

Both support endpoints are language-scoped GET requests.

### Data flow
Contact flow: user opens contact screen -> `ContactCubit.load(lang)` -> cached contacts may emit -> `SupportRepository.getContacts()` -> `SupportApiService.getContacts()` -> `GET /{lang}/ContactUs/Get` -> cache updated -> `ContactState.loaded`.

FAQ flow: user opens FAQ -> `FaqCubit.load(lang)` -> cache may emit unless cleared -> `SupportRepository.getFaqs()` -> `GET /{lang}/FAQ/GetFAQs` -> cache updated -> `FaqState.loaded`.

### Edge cases / notable logic

- Contact Cubit uses `isClosed` guards around async emits.
- FAQ `clearCache()` resets state to initial to avoid showing old FAQ content.

---

## Terms Policy
**Location:** `lib/features/terms_policy`

### What it does
Terms policy displays terms and privacy content from backend HTML/text responses. It has tab switching between terms and privacy and aggressively reloads on language changes to prevent stale-language content.

### Key classes

#### TermsCubit
**File:** `lib/features/terms_policy/presentation/cubit/terms_cubit.dart`

Loads terms/privacy, caches each separately, and controls whether old cache can be reused after clearing.

`lib/features/terms_policy/presentation/cubit/terms_cubit.dart`
```dart
  Future<void> loadTerms(String lang, {bool forceRefresh = false}) async {
    // If cache was cleared, always force refresh
    if (_cacheCleared) {
      forceRefresh = true;
    }
    
    if (!forceRefresh) {
      final cached = await CacheService.getCachedTerms();
```

Terms and privacy are separate load paths with shared cache-cleared behavior.

`lib/features/terms_policy/presentation/cubit/terms_cubit.dart`
```dart
      failure: (msg) async {
        // Don't use cache if it was cleared
        if (!_cacheCleared) {
          final cached = await CacheService.getCachedTerms();
          if (cached != null) {
            emit(TermsState.loaded(TermsPrivacyResponse.fromJson(cached)));
```

On failure, cache fallback is allowed only if the cache was not intentionally cleared.

#### TermsRepository
**File:** `lib/features/terms_policy/repository/terms_repository.dart`

Calls terms/privacy endpoints and wraps success flags.

`lib/features/terms_policy/repository/terms_repository.dart`
```dart
  Future<ApiResult<TermsPrivacyResponse>> getTerms(String lang) async {
    try {
      final res = await _apiService.getTerms(lang);
      return res.success ? ApiResult.success(res) : ApiResult.failure(res.message);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
```

The repository uses compact ternary mapping from response success to `ApiResult`.

#### TermsPolicyScreen
**File:** `lib/features/terms_policy/presentation/screens/terms_policy_screen.dart`

Handles tab state, language-change reload, and HTML rendering through `flutter_html`.

`lib/features/terms_policy/presentation/screens/terms_policy_screen.dart`
```dart
      if (isLanguageChange) {
        // Clear cache and reset state immediately to prevent showing old data
        context.read<TermsCubit>().clearCache();
      }
      
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
```

Language changes clear cache before a forced reload.

`lib/features/terms_policy/presentation/screens/terms_policy_screen.dart`
```dart
                            if (isTerms) {
                              cubit.loadTerms(lang, forceRefresh: true);
                            } else {
                              cubit.loadPrivacy(lang, forceRefresh: true);
                            }
                          },
```

Tab changes always force refresh to keep content aligned with selected language/tab.

### Data flow
User opens terms/privacy -> `TermsPolicyScreen.didChangeDependencies()` gets language -> `TermsCubit.loadTerms(lang, forceRefresh: true)` or `loadPrivacy` -> `TermsRepository.getTerms()`/`getPrivacy()` -> `TermsApiService` -> `GET /{lang}/PrivacyAndTerms/GetTermsAndConditions` or `GetPrivacyPolicy` -> Cubit caches JSON and emits `TermsState.loaded` -> screen renders content.

### Edge cases / notable logic

- Terms and privacy caches are separate.
- Language change clears both caches and waits 50 ms before reloading.
- The screen also triggers load from the `initial` BlocBuilder branch, so `_lastLanguageCode` and forced refresh guards are important.
