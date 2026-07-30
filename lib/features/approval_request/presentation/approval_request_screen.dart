import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/core/theming/app_text_styles.dart';
import 'package:mediconsult/core/utils/app_button.dart';
import 'package:mediconsult/core/widgets/animated_list_item.dart';
import 'package:mediconsult/features/approval_request/presentation/cubit/approval_request_cubit.dart';
import 'package:mediconsult/features/approval_request/presentation/cubit/approval_request_state.dart';
import 'package:mediconsult/features/approval_request/presentation/widgets/attachments/succes_dialog.dart';
import 'package:mediconsult/features/approval_request/presentation/widgets/attachments_section.dart';
import 'package:mediconsult/features/approval_request/presentation/widgets/family_members_selector.dart';
import 'package:mediconsult/features/approval_request/presentation/widgets/note_text_field.dart';
import 'package:mediconsult/features/approval_request/presentation/widgets/provider_selector.dart';
import 'package:mediconsult/features/family_members/data/family_response_model.dart';
import 'package:mediconsult/features/providers/data/providers_models.dart';
import 'package:mediconsult/shared/widgets/app_snack_bar.dart';
import 'package:mediconsult/shared/widgets/page_header.dart';
import 'package:mediconsult/shared/widgets/custom_showcase.dart';
import 'package:mediconsult/shared/widgets/form_stepper.dart';
import 'package:mediconsult/shared/widgets/section_card.dart';
import 'package:mediconsult/shared/services/recent_providers_service.dart';
import 'package:mediconsult/shared/services/form_validation_service.dart';
import 'package:mediconsult/core/cache/cache_service.dart';
import 'package:mediconsult/core/services/home_refresh_service.dart';
// ignore_for_file: deprecated_member_use

class ApprovalRequestScreen extends StatefulWidget {
  const ApprovalRequestScreen({super.key});

  @override
  State<ApprovalRequestScreen> createState() => _ApprovalRequestScreenState();
}

class _ApprovalRequestScreenState extends State<ApprovalRequestScreen> {
  FamilyMember? _selectedFamilyMember;
  ProviderItem? _selectedProvider;
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocusNode = FocusNode();
  final List<String> _attachments = [];
  String? _noteError;

  // Scroll controller for scroll-to-error
  final ScrollController _scrollController = ScrollController();

  // Recent providers
  final RecentProvidersService _recentProvidersService =
      RecentProvidersService.instance;
  List<RecentProvider> _recentProviders = [];

  // Showcase keys
  final GlobalKey _familyKey = GlobalKey();
  final GlobalKey _submitKey = GlobalKey();
  final GlobalKey _providerKey = GlobalKey();
  final GlobalKey _noteKey = GlobalKey();
  final GlobalKey _attachKey = GlobalKey();

  // Showcase state
  int _showcaseIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadRecentProviders();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentProviders() async {
    final providers = await _recentProvidersService.getRecentProviders();
    if (mounted) {
      setState(() {
        _recentProviders = providers;
      });
    }
  }

  int get _currentStep {
    if (_selectedFamilyMember == null) return 0;
    if (_selectedProvider == null) return 1;
    if (_attachments.isEmpty) return 2;
    return 3;
  }

  List<FormStep> get _formSteps => [
    FormStep(
      label: 'form.steps.member'.tr(),
      icon: Icons.family_restroom,
      fieldKey: _familyKey,
    ),
    FormStep(
      label: 'form.steps.provider'.tr(),
      icon: Icons.local_hospital,
      fieldKey: _providerKey,
    ),
    FormStep(
      label: 'form.steps.attachments'.tr(),
      icon: Icons.attach_file,
      fieldKey: _attachKey,
    ),
    FormStep(
      label: 'form.steps.submit'.tr(),
      icon: Icons.send,
      fieldKey: _submitKey,
    ),
  ];

  Future<void> _submitApprovalRequest() async {
    setState(() {
      _noteError = null;
    });

    // Validation with scroll to error
    if (_selectedFamilyMember == null) {
      _showError('approval_request.validation.select_member'.tr());
      await FormValidationService.scrollToField(
        scrollController: _scrollController,
        fieldKey: _familyKey,
      );
      return;
    }

    if (_selectedProvider == null) {
      _showError('approval_request.validation.select_provider'.tr());
      await FormValidationService.scrollToField(
        scrollController: _scrollController,
        fieldKey: _providerKey,
      );
      return;
    }

    if (_noteController.text.length > 300) {
      setState(() {
        _noteError = 'approval_request.validation.notes_too_long'.tr();
      });
      await FormValidationService.scrollToField(
        scrollController: _scrollController,
        fieldKey: _noteKey,
      );
      return;
    }

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
        RecentProvider(
          id: _selectedProvider!.id,
          name: _selectedProvider!.name,
          logoUrl: _selectedProvider!.logo,
        ),
      );
    }

    // Submit
    context.read<ApprovalRequestCubit>().createApprovalRequest(
      lang: context.locale.languageCode,
      memberId: _selectedFamilyMember!.memberId,
      providerId: _selectedProvider!.id,
      notes: _noteController.text.isNotEmpty ? _noteController.text : null,
      attachmentPaths: _attachments,
    );
  }

  void _showError(String message) {
    if (mounted) {
      HapticFeedback.lightImpact();
      showAppSnackBar(
        context,
        message,
        isError: true,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _selectedFamilyMember = null;
      _selectedProvider = null;
      _noteController.clear();
      _attachments.clear();
    });
    context.read<ApprovalRequestCubit>().reset();
  }

  void _startShowcase() {
    setState(() {
      _showcaseIndex = 0;
    });
  }

  void _nextShowcase() {
    if (_showcaseIndex < _showcaseKeys.length - 1) {
      setState(() {
        _showcaseIndex++;
      });
    } else {
      _dismissShowcase();
    }
  }

  void _dismissShowcase() {
    setState(() {
      _showcaseIndex = -1;
    });
  }

  List<GlobalKey> get _showcaseKeys => [
    _familyKey,
    _providerKey,
    _noteKey,
    _attachKey,
    _submitKey,
  ];

  List<String> get _showcaseDescriptions => [
    'tutorial.family_members.select'.tr(),
    'tutorial.provider.select'.tr(),
    'tutorial.note.hint'.tr(),
    'tutorial.attachments.hint'.tr(),
    'tutorial.submit.tap'.tr(),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomShowcaseOverlay(
      targetKeys: _showcaseKeys,
      descriptions: _showcaseDescriptions,
      currentIndex: _showcaseIndex,
      onNext: _nextShowcase,
      onDismiss: _dismissShowcase,
      child: Scaffold(
        backgroundColor: AppColors.lightGreyClr,
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: Column(
              children: [
                PageHeader(
                  title: 'approval_request.title'.tr(),
                  backPath: '/approval-history',
                  onHelp: () {
                    FocusScope.of(context).unfocus();
                    FocusManager.instance.primaryFocus?.unfocus();
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                    _startShowcase();
                  },
                ),
                // Progress stepper
                Transform.translate(
                  offset: Offset(0, -10.h),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: AppColors.whiteClr,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.greyClr.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: FormStepperDots(
                      totalSteps: _formSteps.length,
                      currentStep: _currentStep,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform.translate(
                          offset: Offset(0, -10.h),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.whiteClr,
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.greyClr.withValues(alpha: 0.06),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: AppColors.greyClr.withValues(alpha: 0.04),
                                    blurRadius: 40,
                                    offset: const Offset(0, 12),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Family Members Section
                                    AnimatedListItem(
                                      index: 0,
                                      child: CustomShowcase(
                                        key: _familyKey,
                                        targetKey: _familyKey,
                                        child: SectionCard(
                                          icon: Icons.family_restroom,
                                          title:
                                              'approval_request.family_members'
                                                  .tr(),
                                          isRequired: true,
                                          child: FamilyMembersSelector(
                                            onMemberSelected: (member) {
                                              setState(() {
                                                _selectedFamilyMember = member;
                                              });
                                            },
                                            selectedMember:
                                                _selectedFamilyMember,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20.h),

                                    // Recent Providers (if any)
                                    if (_recentProviders.isNotEmpty &&
                                        _selectedProvider == null)
                                      AnimatedListItem(
                                        index: 1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.history,
                                                  size: 16.sp,
                                                  color: AppColors.greyClr,
                                                ),
                                                SizedBox(width: 6.w),
                                                Text(
                                                  'form.recent_providers'.tr(),
                                                  style:
                                                      AppTextStyles.font12GreyRegular(
                                                        context,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8.h),
                                            Wrap(
                                              spacing: 8.w,
                                              runSpacing: 8.h,
                                              children: _recentProviders.take(3).map((
                                                provider,
                                              ) {
                                                return InkWell(
                                                  onTap: () {
                                                    // Quick select recent provider
                                                    // This would need integration with ProviderSelector
                                                    showAppSnackBar(
                                                      context,
                                                      'form.select_from_list'
                                                          .tr(),
                                                    );
                                                  },
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        20.r,
                                                      ),
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 12.w,
                                                          vertical: 6.h,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors
                                                          .primaryClr
                                                          .withValues(alpha: 0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20.r,
                                                          ),
                                                      border: Border.all(
                                                        color: AppColors
                                                            .primaryClr
                                                            .withValues(alpha: 0.3),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      provider.name,
                                                      style:
                                                          AppTextStyles.font12GreyRegular(
                                                            context,
                                                          ).copyWith(
                                                            color: AppColors
                                                                .primaryClr,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                            SizedBox(height: 12.h),
                                          ],
                                        ),
                                      ),

                                    // Provider Section
                                    AnimatedListItem(
                                      index: 2,
                                      child: CustomShowcase(
                                        key: _providerKey,
                                        targetKey: _providerKey,
                                        child: SectionCard(
                                          icon: Icons.local_hospital,
                                          title: 'approval_request.provider'
                                              .tr(),
                                          isRequired: true,
                                          child: ProviderSelector(
                                            onProviderSelected: (provider) {
                                              setState(() {
                                                _selectedProvider = provider;
                                              });
                                            },
                                            selectedProvider: _selectedProvider,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20.h),

                                    // Note Section
                                    AnimatedListItem(
                                      index: 3,
                                      child: CustomShowcase(
                                        key: _noteKey,
                                        targetKey: _noteKey,
                                        child: SectionCard(
                                          icon: Icons.note_alt_outlined,
                                          title: 'approval_request.note'.tr(),
                                          hasError: _noteError != null,
                                          errorText: _noteError,
                                          child: NoteTextField(
                                            maxLength: 300,
                                            controller: _noteController,
                                            errorText: _noteError,
                                            onChanged: (value) {
                                              if (_noteError != null &&
                                                  value.length <= 300) {
                                                setState(() {
                                                  _noteError = null;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20.h),

                                    // Attachments Section
                                    AnimatedListItem(
                                      index: 4,
                                      child: CustomShowcase(
                                        key: _attachKey,
                                        targetKey: _attachKey,
                                        child: SectionCard(
                                          icon: Icons.attach_file,
                                          title: 'approval_request.attachments'
                                              .tr(),
                                          isRequired: true,
                                          child: AttachmentsSection(
                                            onAttachmentsChanged:
                                                (attachments) {
                                                  setState(() {
                                                    _attachments.clear();
                                                    _attachments.addAll(
                                                      attachments,
                                                    );
                                                  });
                                                  Future.delayed(
                                                    const Duration(
                                                      milliseconds: 300,
                                                    ),
                                                    () {
                                                      if (mounted) {
                                                        FocusScope.of(
                                                          context,
                                                        ).unfocus();
                                                        FocusManager
                                                            .instance
                                                            .primaryFocus
                                                            ?.unfocus();
                                                        SystemChannels.textInput
                                                            .invokeMethod(
                                                              'TextInput.hide',
                                                            );
                                                      }
                                                    },
                                                  );
                                                },
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 28.h),

                                    // Submit Button
                                    AnimatedListItem(
                                      index: 5,
                                      child: CustomShowcase(
                                        key: _submitKey,
                                        targetKey: _submitKey,
                                        child:
                                            BlocConsumer<
                                              ApprovalRequestCubit,
                                              ApprovalRequestState
                                            >(
                                              listener: (context, state) {
                                                state.when(
                                                  initial: () {},
                                                  loading: () {},
                                                  success: (data) {
                                                    CacheService.clearCache();
                                                    HomeRefreshService()
                                                        .notifyRefresh();

                                                    if (mounted) {
                                                      showAppSnackBar(
                                                        context,
                                                        'approval_request.success.title'
                                                            .tr(),
                                                      );
                                                    }

                                                    SuccessDialog.show(context);
                                                    _resetForm();
                                                  },
                                                  failed: (message) {
                                                    _showError(message);
                                                  },
                                                );
                                              },
                                              builder: (context, state) {
                                                final isLoading =
                                                    state is Loading;
                                                return AppButton(
                                                  text: 'common.save'.tr(),
                                                  onPressed:
                                                      _submitApprovalRequest,
                                                  isLoading: isLoading,
                                                  width: double.infinity,
                                                );
                                              },
                                            ),
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
