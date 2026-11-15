import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/core/widgets/smooth_shimmer.dart';
import 'package:mediconsult/core/widgets/animated_list_item.dart';
import 'package:mediconsult/core/widgets/error_state_widget.dart';
import 'package:mediconsult/features/refund/presentation/cubit/refunds_cubit.dart';
import 'package:mediconsult/features/refund/presentation/cubit/refunds_state.dart';
import 'package:mediconsult/features/refund/presentation/widgets/refund_card.dart';
import 'package:mediconsult/features/refund/presentation/widgets/refund_empty_state.dart';
import 'package:mediconsult/shared/widgets/page_header.dart';
import 'package:mediconsult/shared/widgets/segmented_tabs.dart';
import 'package:mediconsult/shared/widgets/custom_showcase.dart';
import 'package:mediconsult/shared/widgets/family_member_filter_dropdown.dart';
import 'package:mediconsult/features/home/presentation/cubit/cubit/home_cubit.dart';
import 'package:mediconsult/features/home/presentation/cubit/cubit/home_state.dart';
// ignore_for_file: deprecated_member_use

class RefundHistoryScreen extends StatefulWidget {
  const RefundHistoryScreen({super.key});

  @override
  State<RefundHistoryScreen> createState() => _RefundHistoryScreenState();
}

class _RefundHistoryScreenState extends State<RefundHistoryScreen> {
  final ScrollController _controller = ScrollController();
  int _currentTab = 0;
  bool _isLoadingMore = false;
  bool _canRefresh = true; // Flag to control refresh
  bool _isTabChanging = false; // Track tab changes
  int? _selectedMemberId; // Track selected family member filter
  StreamSubscription? _homeSubscription; // Track home cubit subscription

  final GlobalKey _tabsKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();
  
  // Showcase state
  int _showcaseIndex = -1;

  int? _getCurrentUserMemberId() {
    try {
      final homeState = context.read<HomeCubit>().state;
      return homeState.maybeWhen(
        loaded: (homeResponse) => homeResponse.data?.memberId,
        orElse: () => null,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Load home data first if not loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final homeCubit = context.read<HomeCubit>();
        final homeState = homeCubit.state;
        homeState.maybeWhen(
          initial: () {
            // Load home data if not loaded
            homeCubit.getHomeInfo(context.locale.languageCode);
          },
          orElse: () {},
        );
        
        // Initialize selectedMemberId with current user's memberId from HomeCubit
        if (_selectedMemberId == null) {
          final currentMemberId = _getCurrentUserMemberId();
          if (currentMemberId != null) {
            setState(() {
              _selectedMemberId = currentMemberId;
            });
            // Load refunds with initial memberId after setting it
            final lang = context.locale.languageCode;
            final apiStatus = [
              'All',
              'Pending',
              'Approved',
              'Rejected',
            ];
            context.read<RefundsCubit>().load(
              lang: lang,
              status: apiStatus[_currentTab],
              memberId: _selectedMemberId,
              reset: true,
            );
          } else {
            // Wait for home data to load, then initialize
            _homeSubscription?.cancel();
            _homeSubscription = homeCubit.stream.listen((state) {
              if (mounted && _selectedMemberId == null) {
                final memberId = state.maybeWhen(
                  loaded: (homeResponse) => homeResponse.data?.memberId,
                  orElse: () => null,
                );
                if (memberId != null) {
                  _homeSubscription?.cancel();
                  setState(() {
                    _selectedMemberId = memberId;
                  });
                  final lang = context.locale.languageCode;
                  final apiStatus = [
                    'All',
                    'Pending',
                    'Approved',
                    'Rejected',
                  ];
                  context.read<RefundsCubit>().load(
                    lang: lang,
                    status: apiStatus[_currentTab],
                    memberId: _selectedMemberId,
                    reset: true,
                  );
                }
              }
            });
          }
        } else {
          // If already initialized, just load with current memberId
          final lang = context.locale.languageCode;
          final apiStatus = [
            'All',
            'Pending',
            'Approved',
            'Rejected',
          ];
          context.read<RefundsCubit>().load(
            lang: lang,
            status: apiStatus[_currentTab],
            memberId: _selectedMemberId,
            reset: true,
          );
        }
      }
    });
  }

  void _onScroll() {
    if (!_controller.hasClients || _isLoadingMore) return;
    final position = _controller.position;
    
    // Update refresh flag: only allow refresh if scroll is at the top
    _canRefresh = position.pixels <= 0;
    
    if (position.pixels >= position.maxScrollExtent - 200) {
      final state = context.read<RefundsCubit>().state;
      state.maybeWhen(
        loaded: (refunds, pagination, status, loadingMore) {
          if (pagination.hasNextPage && !loadingMore) {
            _isLoadingMore = true;
            final lang = context.locale.languageCode;
            context.read<RefundsCubit>().loadMore(lang).then((_) {
              _isLoadingMore = false;
            });
          }
        },
        orElse: () {},
      );
    }
  }
  
  bool _onNotification(ScrollNotification notification) {
    // Prevent refresh when pulling down from status bar or notification panel
    if (notification is ScrollStartNotification) {
      // Check if scroll is starting from top (pixels should be 0 or negative)
      if (_controller.hasClients) {
        final pixels = _controller.position.pixels;
        _canRefresh = pixels <= 0;
      }
    } else if (notification is OverscrollNotification) {
      // Prevent refresh on overscroll when not at the top
      if (_controller.hasClients) {
        final pixels = _controller.position.pixels;
        // Only allow refresh if we're at the top and overscrolling downward
        _canRefresh = pixels <= 0 && notification.overscroll > 0;
      }
    } else if (notification is ScrollUpdateNotification) {
      // Update refresh flag during scroll
      if (_controller.hasClients) {
        final pixels = _controller.position.pixels;
        _canRefresh = pixels <= 0;
      }
    }
    return false; // Allow notification to continue
  }

  @override
  @override
  void dispose() {
    _homeSubscription?.cancel();
    _controller.dispose();
    super.dispose();
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
        _tabsKey,
        _fabKey,
      ];

  List<String> get _showcaseDescriptions => [
        'tutorial.refund_history.swipe'.tr(),
        'tutorial.refund_history.fab'.tr(),
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
        body: SafeArea(
          child: Column(
            children: [
              PageHeader(
                title: 'refund_history.title'.tr(),
                backPath: '/home',
                onHelp: () {
                  _startShowcase();
                },
              ),
              Expanded(
                child: Transform.translate(
                  offset: Offset(0, -20.h),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.whiteClr,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.greyClr.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 16.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: CustomShowcase(
                              key: _tabsKey,
                              targetKey: _tabsKey,
                              child: SegmentedTabs(
                                labels: [
                                  'approval_history.tabs.all'.tr(),
                                  'approval_history.tabs.pending'.tr(),
                                  'approval_history.tabs.approved'.tr(),
                                  'approval_history.tabs.rejected'.tr(),
                                ],
                                selectedIndex: _currentTab,
                                onTap: (i) {
                                  setState(() {
                                    _currentTab = i;
                                    _isTabChanging = true;
                                  });
                                  final apiStatus = [
                                    'All',
                                    'Pending',
                                    'Approved',
                                    'Rejected',
                                  ];
                                  final lang = context.locale.languageCode;
                                  // Use current memberId or fallback to current user's memberId
                                  final memberIdToUse = _selectedMemberId ?? _getCurrentUserMemberId();
                                  if (memberIdToUse != null) {
                                    context.read<RefundsCubit>().load(
                                      lang: lang,
                                      status: apiStatus[i],
                                      memberId: memberIdToUse,
                                      reset: true,
                                    );
                                  }
                                  // Reset flag after a delay
                                  Future.delayed(const Duration(milliseconds: 500), () {
                                    if (mounted) {
                                      setState(() => _isTabChanging = false);
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                          // Family Member Filter Dropdown
                          Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                            child: Builder(
                              builder: (context) {
                                final currentMemberId = _selectedMemberId ?? _getCurrentUserMemberId();
                                if (currentMemberId == null) {
                                  return const SizedBox.shrink();
                                }
                                return FamilyMemberFilterDropdown(
                                  selectedMemberId: currentMemberId,
                                  onMemberChanged: (memberId) {
                                    setState(() {
                                      _selectedMemberId = memberId;
                                    });
                                    // Apply filter to API call
                                    final apiStatus = [
                                      'All',
                                      'Pending',
                                      'Approved',
                                      'Rejected',
                                    ];
                                    final lang = context.locale.languageCode;
                                    context.read<RefundsCubit>().load(
                                      lang: lang,
                                      status: apiStatus[_currentTab],
                                      memberId: memberId,
                                      reset: true,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: BlocBuilder<RefundsCubit, RefundsState>(
                                buildWhen: (previous, current) {
                                  // Always rebuild when tab changes or state changes
                                  return previous != current;
                                },
                                builder: (context, state) {
                                  // Show shimmer if loading or tab is changing
                                  final showShimmer = state.maybeWhen(
                                    loading: () => true,
                                    orElse: () => false,
                                  ) || _isTabChanging;
                                  
                                  if (showShimmer) {
                                    return ListView.builder(
                                      itemCount: 5,
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        return const ShimmerApprovalCard();
                                      },
                                    );
                                  }
                                  
                                  return state.when(
                                    initial: () => ListView.builder(
                                      itemCount: 5,
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        return const ShimmerApprovalCard();
                                      },
                                    ),
                                    loading: () => ListView.builder(
                                      itemCount: 5,
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        return const ShimmerApprovalCard();
                                      },
                                    ),
                                    failed: (message) => ErrorStateWidget(
                                      error: message,
                                      onRetry: () {
                                        final lang = context.locale.languageCode;
                                        context.read<RefundsCubit>().refreshRefunds(lang);
                                      },
                                    ),
                                    loaded: (refunds, pagination, status, loadingMore) {
                                      if (refunds.isEmpty) {
                                        return const RefundEmptyState();
                                      }
                                      return NotificationListener<ScrollNotification>(
                                        onNotification: _onNotification,
                                        child: RefreshIndicator(
                                          onRefresh: _canRefresh ? () async {
                                            final lang =
                                                context.locale.languageCode;
                                            await context
                                                .read<RefundsCubit>()
                                                .load(
                                                  lang: lang,
                                                  status: [
                                                    'All',
                                                    'Pending',
                                                    'Approved',
                                                    'Rejected',
                                                  ][_currentTab],
                                                  memberId: _selectedMemberId ?? _getCurrentUserMemberId(),
                                                  reset: true,
                                                  forceRefresh: true,
                                                );
                                          } : () async {
                                            // Do nothing if refresh is not allowed
                                            return;
                                          },
                                          // Prevent refresh when pulling from status bar
                                          displacement: 40.0,
                                          edgeOffset: 0.0,
                                          // Only trigger refresh if scroll is at the top
                                          child: ListView.separated(
                                            controller: _controller,
                                            physics:
                                                const AlwaysScrollableScrollPhysics(
                                                  parent: BouncingScrollPhysics(),
                                                ),
                                            cacheExtent: 500,
                                            addAutomaticKeepAlives: true,
                                            addRepaintBoundaries: true,
                                            itemCount:
                                                refunds.length +
                                                (pagination.hasNextPage ? 1 : 0),
                                            separatorBuilder: (_, __) =>
                                                SizedBox(height: 20.h),
                                            itemBuilder: (context, index) {
                                              if (index >= refunds.length) {
                                                return const ShimmerApprovalCard();
                                              }
                                              return AnimatedListItem(
                                                index: index,
                                                child: RefundCard(
                                                  key: ValueKey(refunds[index].id),
                                                  item: refunds[index],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: CustomShowcase(
          key: _fabKey,
          targetKey: _fabKey,
          child: Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryShadowClr,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () {
                context.push('/refund-request');
              },
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
