import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/services/home_refresh_service.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:mediconsult/features/home/presentation/cubit/cubit/home_cubit.dart';
import 'package:mediconsult/features/home/presentation/cubit/cubit/home_state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mediconsult/features/home/presentation/widgets/home_header_widget.dart';
import 'package:mediconsult/features/home/presentation/widgets/user_plan_card_widget.dart';
import 'package:mediconsult/features/home/presentation/widgets/quick_access_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mediconsult/features/home/presentation/widgets/ongoing_request_widget.dart';
import 'package:mediconsult/features/home/presentation/widgets/health_tips_widget.dart';
import 'package:mediconsult/features/home/presentation/widgets/explore_widget.dart';
import 'package:mediconsult/features/home/presentation/widgets/bottom_navigation_bar_widget.dart';
import 'package:mediconsult/features/home/presentation/widgets/home_loading_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mediconsult/core/utils/language_helper.dart';
import 'package:mediconsult/core/widgets/error_state_widget.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  StreamSubscription<void>? _refreshSubscription;
  final ScrollController _scrollController = ScrollController();
  bool _isECardRouteOpen = false;
  // Flag to control refresh

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    // Listen to refresh notifications to update data when approval request is created
    _refreshSubscription = HomeRefreshService().refreshStream.listen((_) {
      if (mounted && _hasLoadedOnce) {
        // Refresh home data when approval request is created
        final lang = LanguageHelper.getLanguageCode(context);
        context.read<HomeCubit>().refreshHomeInfo(lang);
      }
    });
    // call home info when the screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionsAndLoadData();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    // Update refresh flag: only allow refresh if scroll is at the top
  }

  bool _onNotification(ScrollNotification notification) {
    // Allow refresh when user intentionally pulls down from the top
    // Only prevent refresh when overscrolling from status bar (when not at top)
    if (notification is ScrollStartNotification) {
      // Check if scroll is starting from top (pixels should be 0 or negative)
      if (_scrollController.hasClients) {}
    } else if (notification is OverscrollNotification) {
      // Only prevent refresh if we're NOT at the top and overscrolling
      // This prevents refresh when pulling status bar
      if (_scrollController.hasClients) {
        final pixels = _scrollController.position.pixels;
        // Allow refresh only if at top (pixels <= 0) and overscrolling downward
        if (pixels > 0) {
          // Not at top, prevent refresh (likely status bar pull)
        } else {
          // At top, allow refresh if overscrolling downward
        }
      }
    } else if (notification is ScrollUpdateNotification) {
      // Update refresh flag during scroll - allow if at top
      if (_scrollController.hasClients) {}
    }
    return false; // Allow notification to continue
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  bool _hasLoadedOnce = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Don't auto-refresh on lifecycle changes - only manual pull to refresh
    // Track when app goes to background (for future use if needed)
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {}

    // Disabled auto-refresh on resume - user must manually pull to refresh
    // if (state == AppLifecycleState.resumed && _hasLoadedOnce && _lastPausedTime != null) {
    //   final wasInBackground = _previousLifecycleState == AppLifecycleState.paused ||
    //                           _previousLifecycleState == AppLifecycleState.inactive;
    //
    //   if (wasInBackground) {
    //     final timeInBackground = DateTime.now().difference(_lastPausedTime!);
    //     if (timeInBackground.inMilliseconds > 3000) {
    //       _refreshIfNeeded();
    //     }
    //     _lastPausedTime = null;
    //   }
    // }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Don't auto-refresh on dependency changes - only manual pull to refresh
    // if (_hasLoadedOnce) {
    //   Future.delayed(const Duration(milliseconds: 300), () {
    //     if (mounted) {
    //       _refreshIfNeeded();
    //     }
    //   });
    // }
  }

  // This method will be called when the screen becomes visible again
  // It's triggered by the widget lifecycle when navigating back
  @override
  void activate() {
    super.activate();
    // Don't auto-refresh when screen becomes active - only manual pull to refresh
    // if (_hasLoadedOnce) {
    //   Future.delayed(const Duration(milliseconds: 300), () {
    //     if (mounted) {
    //       _refreshIfNeeded();
    //     }
    //   });
    // }
  }

  Future<void> _checkPermissionsAndLoadData() async {
    try {
      // Load home data regardless of permissions
      context.read<HomeCubit>().getHomeInfo(
        LanguageHelper.getLanguageCode(context),
      );
    } catch (e) {
      // If there's an error, still try to load home data
      context.read<HomeCubit>().getHomeInfo(
        LanguageHelper.getLanguageCode(context),
      );
    }
  }

  int? _pageIndexForVisualIndex(int visualIndex) {
    switch (visualIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 3:
        return 2;
      case 4:
        return 3;
      default:
        return null;
    }
  }

  Future<void> _handleBottomNavigationTap(int visualIndex) async {
    if (visualIndex == 2) {
      await _openECardRoute();
      return;
    }

    final pageIndex = _pageIndexForVisualIndex(visualIndex);
    if (pageIndex == null) return;

    switch (pageIndex) {
      case 0:
        if (mounted) {
          setState(() {
            _currentIndex = 0;
          });
        }
        break;
      case 1:
        context.push('/network');
        break;
      case 2:
        context.push('/approval-request');
        break;
      case 3:
        final homeResponse = context.read<HomeCubit>().state.maybeWhen(
          loaded: (model) => model,
          orElse: () => null,
        );
        context.push('/profile', extra: homeResponse);
        break;
    }
  }

  Future<void> _openECardRoute() async {
    if (_isECardRouteOpen) return;
    _isECardRouteOpen = true;
    try {
      await context.push('/e-card');
    } finally {
      _isECardRouteOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildHomeContent(context);
  }

  Widget _buildHomeContent(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyClr,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeCubitState>(
          builder: (context, state) {
            return state.when(
              initial: () => const HomeLoadingWidget(),
              loading: () => const HomeLoadingWidget(),

              /// when the data is loaded, show the page with the real data
              loaded: (model) {
                // Mark that we've loaded data at least once
                if (!_hasLoadedOnce) {
                  _hasLoadedOnce = true;
                }
                final data = model.data;
                return NotificationListener<ScrollNotification>(
                  onNotification: _onNotification,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      // Always allow refresh when user pulls down from top
                      // The _canRefresh flag is mainly for preventing status bar pulls
                      await context.read<HomeCubit>().refreshHomeInfo(
                        LanguageHelper.getLanguageCode(context),
                      );
                    },
                    // Prevent refresh when pulling from status bar
                    displacement: 40.0,
                    edgeOffset: 0.0,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: ClampingScrollPhysics(),
                      ),
                      child: Column(
                        children: [
                          // Wrap header in RepaintBoundary for better performance
                          RepaintBoundary(child: HomeHeaderWidget(data: data!)),
                          RepaintBoundary(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Reserve the overlap space for the card
                                // without painting an extra blue band behind it.
                                SizedBox(height: 130.h),
                                Positioned(
                                  bottom: -70.h,
                                  left: 16.w,
                                  right: 16.w,
                                  child: GestureDetector(
                                    onTap: () {
                                      context.push('/profile', extra: model);
                                    },
                                    child: UserPlanCardWidget(data: data),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 80.h),
                          Container(
                            color: AppColors.lightGreyClr,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RepaintBoundary(
                                  child: const QuickAccessWidget(),
                                ),
                                SizedBox(height: 24.h),
                                if (data.approvals.any(
                                  (approval) =>
                                      approval.status.toLowerCase() ==
                                      'reviewing',
                                )) ...[
                                  RepaintBoundary(
                                    child: OngoingRequestWidget(data: data),
                                  ),
                                  SizedBox(height: 24.h),
                                ],
                                RepaintBoundary(
                                  child: const HealthTipsWidget(),
                                ),
                                SizedBox(height: 24.h),
                                RepaintBoundary(child: const ExploreWidget()),
                                SizedBox(height: 40.h),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },

              /// in case of error
              failed: (message) => ErrorStateWidget(
                error: message,
                title: 'home.error_loading'.tr(),
                onRetry: () {
                  context.read<HomeCubit>().retry(
                    LanguageHelper.getLanguageCode(context),
                  );
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _currentIndex,
        onTap: _handleBottomNavigationTap,
      ),
    );
  }
}
