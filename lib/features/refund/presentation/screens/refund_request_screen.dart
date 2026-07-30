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
import 'package:mediconsult/features/approval_request/presentation/widgets/attachments/succes_dialog.dart';
import 'package:mediconsult/features/approval_request/presentation/widgets/family_members_selector.dart';
import 'package:mediconsult/features/approval_request/presentation/widgets/note_text_field.dart';
import 'package:mediconsult/features/family_members/data/family_response_model.dart';
import 'package:mediconsult/features/refund/data/refund_types_reasons_models.dart';
import 'package:mediconsult/features/refund/presentation/cubit/refund_request_cubit.dart';
import 'package:mediconsult/features/refund/presentation/cubit/refund_request_state.dart';
import 'package:mediconsult/features/refund/presentation/widgets/add_attachment_widget.dart';
import 'package:mediconsult/features/refund/presentation/widgets/reason_selector.dart';
import 'package:mediconsult/features/refund/presentation/widgets/refund_form_fields.dart';
import 'package:mediconsult/features/refund/presentation/widgets/refund_type_selector.dart';
import 'package:mediconsult/shared/widgets/app_snack_bar.dart';
import 'package:mediconsult/shared/widgets/page_header.dart';
import 'package:mediconsult/shared/widgets/form_stepper.dart';
import 'package:mediconsult/shared/widgets/section_card.dart';
import 'package:mediconsult/shared/services/form_validation_service.dart';
import 'package:mediconsult/features/refund/presentation/widgets/refund_instructions_dialog.dart';
// ignore_for_file: deprecated_member_use

class RefundRequestScreen extends StatefulWidget {
  const RefundRequestScreen({super.key});

  @override
  State<RefundRequestScreen> createState() => _RefundRequestScreenState();
}

class _RefundRequestScreenState extends State<RefundRequestScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _providerController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _noteFocusNode = FocusNode();
  final FocusNode _providerFocusNode = FocusNode();
  DateTime? _selectedDate;
  int? _selectedRefundTypeId;
  String? _selectedRefundTypeName;
  int? _selectedReasonId;
  FamilyMember? _selectedMember;
  List<String> _attachmentPaths = [];
  bool _hasAllRequiredAttachments = false;
  String? _noteError;
  String? _providerError;
  String? _amountError;
  List<RefundAttachment> _selectedRefundAttachments = [];

  // Scroll controller
  final ScrollController _scrollController = ScrollController();

  // Keys for scroll-to-error
  final GlobalKey _memberKey = GlobalKey();
  final GlobalKey _typeKey = GlobalKey();
  final GlobalKey _providerKey = GlobalKey();
  final GlobalKey _reasonKey = GlobalKey();
  final GlobalKey _amountKey = GlobalKey();
  final GlobalKey _dateKey = GlobalKey();
  final GlobalKey _noteKey = GlobalKey();
  final GlobalKey _attachKey = GlobalKey();
  final GlobalKey _submitKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  void _unfocusAll() {
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _providerController.dispose();
    _noteController.dispose();
    _amountFocusNode.dispose();
    _noteFocusNode.dispose();
    _providerFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int get _currentStep {
    if (_selectedMember == null) return 0;
    if (_selectedRefundTypeId == null) return 1;
    if (_providerController.text.isEmpty || _selectedReasonId == null) return 2;
    if (_amountController.text.isEmpty || _selectedDate == null) return 3;
    if (!_hasAllRequiredAttachments) return 4;
    return 5;
  }

  Future<void> _submitRefundRequest() async {
    setState(() {
      _noteError = null;
      _providerError = null;
      _amountError = null;
    });

    // Validation with scroll to error
    if (_selectedMember == null) {
      _showError('refund_request.validation.select_member'.tr());
      await FormValidationService.scrollToField(
        scrollController: _scrollController,
        fieldKey: _memberKey,
      );
      return;
    }
    if (_selectedRefundTypeId == null) {
      _showError('refund_request.validation.select_type'.tr());
      await FormValidationService.scrollToField(
        scrollController: _scrollController,
        fieldKey: _typeKey,
      );
      return;
    }

    final providerText = _providerController.text.trim();
    if (providerText.isEmpty) {
      final errorMsg = 'refund_request.validation.enter_provider'.tr();
      setState(() {
        _providerError = errorMsg;
      });
      _showError(errorMsg);
      await FormValidationService.scrollToField(
        scrollController: _scrollController,
        fieldKey: _providerKey,
      );
      return;
    }
    if (providerText.length < 2) {
      final errorMsg = 'refund_request.validation.provider_min_length'.tr();
      setState(() {
        _providerError = errorMsg;
      });
      _showError(errorMsg);
      await FormValidationService.scrollToField(
        scrollController: _scrollController,
        fieldKey: _providerKey,
      );
      return;
    }
    if (_selectedReasonId == null) {
      _showError('refund_request.validation.select_reason'.tr());
      await FormValidationService.scrollToField(
        scrollController: _scrollController,
        fieldKey: _reasonKey,
      );
      return;
    }
    if (_amountController.text.trim().isEmpty) {
      final errorMsg = 'refund_request.validation.enter_amount'.tr();
      setState(() {
        _amountError = errorMsg;
      });
      _showError(errorMsg);
      await FormValidationService.scrollToField(
        scrollController: _scrollController,
        fieldKey: _amountKey,
      );
      return;
    }
    if (_selectedDate == null) {
      _showError('refund_request.validation.select_date'.tr());
      await FormValidationService.scrollToField(
        scrollController: _scrollController,
        fieldKey: _dateKey,
      );
      return;
    }

    if (_noteController.text.length > 300) {
      final errorMsg = 'refund_request.validation.notes_too_long'.tr();
      setState(() {
        _noteError = errorMsg;
      });
      _showError(errorMsg);
      await FormValidationService.scrollToField(
        scrollController: _scrollController,
        fieldKey: _noteKey,
      );
      return;
    }

    // Date validation
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime selectedDateOnly = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
    );

    if (selectedDateOnly.isAfter(today)) {
      _showError('refund_request.validation.future_date_not_allowed'.tr());
      return;
    }

    final daysDifference = today.difference(selectedDateOnly).inDays;
    if (daysDifference > 59) {
      _showError('refund_request.validation.date_too_old'.tr());
      return;
    }

    if (!_hasAllRequiredAttachments) {
      _showError('refund_request.validation.add_attachment'.tr());
      await FormValidationService.scrollToField(
        scrollController: _scrollController,
        fieldKey: _attachKey,
      );
      return;
    }

    final formattedDate = DateFormat('yyyy-MM-dd', 'en').format(_selectedDate!);
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount < 1 || amount > 100000) {
      final errorMsg = 'refund_request.validation.amount_range'.tr();
      setState(() {
        _amountError = errorMsg;
      });
      _showError(errorMsg);
      await FormValidationService.scrollToField(
        scrollController: _scrollController,
        fieldKey: _amountKey,
      );
      return;
    }

    await context.read<RefundRequestCubit>().createRefundRequest(
      lang: context.locale.languageCode,
      memberId: _selectedMember!.memberId,
      refundTypeId: _selectedRefundTypeId!,
      refundReasonId: _selectedReasonId!,
      amount: amount,
      serviceDate: formattedDate,
      providerName: _providerController.text.trim(),
      notes: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      attachmentPaths: _attachmentPaths,
    );
  }

  void _showError(String message) {
    if (mounted) {
      HapticFeedback.lightImpact();
      showAppSnackBar(
        context,
        message,
        isError: true,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      HapticFeedback.selectionClick();
      showAppSnackBar(
        context,
        message,
        isError: false,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    _unfocusAll();
    await Future.delayed(const Duration(milliseconds: 50));

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime firstDate = today.subtract(const Duration(days: 59));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: firstDate,
      lastDate: today,
    );

    await Future.delayed(const Duration(milliseconds: 50));
    _unfocusAll();

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyClr,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: _unfocusAll,
        child: SafeArea(
          child: Column(
            children: [
              PageHeader(
                title: 'refund_request.title'.tr(),
                backPath: '/home',
                onHelp: () {
                  _unfocusAll();
                  RefundInstructionsDialog.show(context);
                },
              ),
              // Progress stepper
              Transform.translate(
                offset: Offset(0, -10.h),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.whiteClr,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.greyClr.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: FormStepperDots(
                    totalSteps: 6,
                    currentStep: _currentStep,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Family Members Section
                            AnimatedListItem(
                              index: 0,
                              key: _memberKey,
                              child: SectionCard(
                                icon: Icons.family_restroom,
                                title: 'refund_request.family_members'.tr(),
                                isRequired: true,
                                child: FamilyMembersSelector(
                                  onMemberSelected: (member) {
                                    setState(() {
                                      _selectedMember = member;
                                    });
                                  },
                                  selectedMember: _selectedMember,
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // Refund Type Section
                            AnimatedListItem(
                              index: 1,
                              key: _typeKey,
                              child: SectionCard(
                                icon: Icons.category_outlined,
                                title: 'refund_request.refund_type'.tr(),
                                isRequired: true,
                                child: GestureDetector(
                                  onTap: _unfocusAll,
                                  child: RefundTypeSelector(
                                    selectedTypeId: _selectedRefundTypeId,
                                    onTypeSelected: (type) {
                                      _unfocusAll();
                                      setState(() {
                                        _selectedRefundTypeId = type.id;
                                        _selectedRefundTypeName = type.name;
                                        _selectedRefundAttachments =
                                            type.attachments;
                                        _attachmentPaths = [];
                                        _hasAllRequiredAttachments = false;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // Provider Section
                            AnimatedListItem(
                              index: 2,
                              key: _providerKey,
                              child: SectionCard(
                                icon: Icons.local_hospital_outlined,
                                title: 'refund_request.provider'.tr(),
                                isRequired: true,
                                hasError: _providerError != null,
                                errorText: _providerError,
                                child: TextField(
                                  controller: _providerController,
                                  focusNode: _providerFocusNode,
                                  autofocus: false,
                                  decoration: InputDecoration(
                                    hintText: 'refund_request.provider_hint'
                                        .tr(),
                                    hintStyle: AppTextStyles.font14GreyRegular(
                                      context,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        color: _providerError != null
                                            ? AppColors.errorClr
                                            : AppColors.greyClr.withValues(
                                                alpha: 0.2,
                                              ),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        color: _providerError != null
                                            ? AppColors.errorClr
                                            : AppColors.greyClr.withValues(
                                                alpha: 0.2,
                                              ),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        color: _providerError != null
                                            ? AppColors.errorClr
                                            : AppColors.primaryClr,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 12.h,
                                    ),
                                  ),
                                  style: AppTextStyles.font14BlackMedium(
                                    context,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      final text = value.trim();
                                      if (text.isEmpty) {
                                        _providerError =
                                            'refund_request.validation.enter_provider'
                                                .tr();
                                      } else if (text.length < 2) {
                                        _providerError =
                                            'refund_request.validation.provider_min_length'
                                                .tr();
                                      } else {
                                        _providerError = null;
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // Reason Section
                            AnimatedListItem(
                              index: 3,
                              key: _reasonKey,
                              child: SectionCard(
                                icon: Icons.help_outline,
                                title: 'refund_request.reason'.tr(),
                                isRequired: true,
                                child: GestureDetector(
                                  onTap: _unfocusAll,
                                  child: ReasonSelector(
                                    selectedReasonId: _selectedReasonId,
                                    onReasonSelected: (id, name) {
                                      _unfocusAll();
                                      setState(() {
                                        _selectedReasonId = id;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // Amount and Date Section
                            AnimatedListItem(
                              index: 4,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    key: _amountKey,
                                    child: SectionCard(
                                      icon: Icons.attach_money,
                                      title: 'refund_request.amount'.tr(),
                                      isRequired: true,
                                      hasError: _amountError != null,
                                      padding: EdgeInsets.all(10.w),
                                      child: GestureDetector(
                                        onTap: () =>
                                            _amountFocusNode.requestFocus(),
                                        child: RefundAmountField(
                                          controller: _amountController,
                                          focusNode: _amountFocusNode,
                                          errorText: _amountError,
                                          onChanged: (value) {
                                            setState(() {
                                              final text = value.trim();
                                              if (text.isEmpty) {
                                                _amountError =
                                                    'refund_request.validation.enter_amount'
                                                        .tr();
                                              } else {
                                                final amount = double.tryParse(
                                                  text,
                                                );
                                                if (amount == null ||
                                                    amount < 1 ||
                                                    amount > 100000) {
                                                  _amountError =
                                                      'refund_request.validation.amount_range'
                                                          .tr();
                                                } else {
                                                  _amountError = null;
                                                }
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    key: _dateKey,
                                    child: SectionCard(
                                      icon: Icons.calendar_today_outlined,
                                      title: 'refund_request.date'.tr(),
                                      isRequired: true,
                                      padding: EdgeInsets.all(10.w),
                                      child: RefundDatePicker(
                                        selectedDate: _selectedDate,
                                        onTap: _selectDate,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // Note Section
                            AnimatedListItem(
                              index: 5,
                              key: _noteKey,
                              child: SectionCard(
                                icon: Icons.note_alt_outlined,
                                title: 'refund_request.note'.tr(),
                                hasError: _noteError != null,
                                errorText: _noteError,
                                child: GestureDetector(
                                  onTap: () => _noteFocusNode.requestFocus(),
                                  child: NoteTextField(
                                    controller: _noteController,
                                    focusNode: _noteFocusNode,
                                    maxLength: 300,
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
                            SizedBox(height: 16.h),

                            // Attachments Section
                            AnimatedListItem(
                              index: 6,
                              key: _attachKey,
                              child: Visibility(
                                visible:
                                    _selectedRefundTypeId != null &&
                                    _selectedRefundAttachments.isNotEmpty,
                                maintainSize: false,
                                maintainAnimation: false,
                                maintainState: false,
                                child:
                                    _selectedRefundTypeId != null &&
                                        _selectedRefundAttachments.isNotEmpty
                                    ? SectionCard(
                                        icon: Icons.attach_file,
                                        title: 'refund_request.attachments'
                                            .tr(),
                                        isRequired: true,
                                        child: AddAttachmentWidget(
                                          key: ValueKey(
                                            '${_selectedRefundTypeId}_${_attachmentPaths.length}',
                                          ),
                                          refundTypeName:
                                              _selectedRefundTypeName,
                                          attachments:
                                              _selectedRefundAttachments,
                                          initialAttachmentPaths:
                                              _attachmentPaths.isNotEmpty
                                              ? _attachmentPaths
                                              : null,
                                          onAttachmentsChanged:
                                              (paths, hasAllRequired) {
                                                setState(() {
                                                  _attachmentPaths = paths;
                                                  _hasAllRequiredAttachments =
                                                      hasAllRequired;
                                                });
                                              },
                                          onAttachmentDialogClosed: _unfocusAll,
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                            SizedBox(height: 24.h),

                            // Submit Button
                            AnimatedListItem(
                              index: 7,
                              key: _submitKey,
                              child:
                                  BlocConsumer<
                                    RefundRequestCubit,
                                    RefundRequestState
                                  >(
                                    listener: (context, state) {
                                      state.maybeWhen(
                                        success: (data) {
                                          _showSuccess(
                                            'refund_request.success_message'
                                                .tr(),
                                          );
                                          SuccessDialog.showRefund(context);
                                        },
                                        failed: (message) {
                                          _showError(message);
                                        },
                                        orElse: () {},
                                      );
                                    },
                                    builder: (context, state) {
                                      final isLoading = state.maybeWhen(
                                        loading: () => true,
                                        orElse: () => false,
                                      );
                                      return AppButton(
                                        onPressed: _submitRefundRequest,
                                        text: 'refund_request.submit'.tr(),
                                        isLoading: isLoading,
                                      );
                                    },
                                  ),
                            ),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
