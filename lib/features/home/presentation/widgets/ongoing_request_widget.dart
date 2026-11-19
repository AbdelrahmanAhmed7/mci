import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/features/home/data/home_response_model.dart';

class OngoingRequestWidget extends StatelessWidget {
  final HomeData data;

  const OngoingRequestWidget({super.key, required this.data});

  Approval? get _latestReview {
    final approvals =
        data.approvals
            .where((item) => item.status.toLowerCase() == 'reviewing')
            .toList()
          ..sort((a, b) => b.createdDate.compareTo(a.createdDate));
    return approvals.isEmpty ? null : approvals.first;
  }

  String _date(String raw) {
    if (raw.isEmpty) return '--';
    try {
      final date = DateTime.parse(raw);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.day} ${months[date.month - 1]}';
    } catch (_) {
      return raw.split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final approval = _latestReview;
    if (approval == null) return const SizedBox.shrink();

    final date = _date(approval.createdDate);
    return Container(
      width: double.infinity,
      height: 195.h,
      padding: EdgeInsets.all(17.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF9FAFB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 35.w,
                height: 35.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFDEEAFD),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Icon(
                  Icons.hourglass_empty,
                  size: 22.w,
                  color: const Color(0xFF5983F3),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Approval in progress',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5983F3),
                      ),
                    ),
                    Text(
                      '${approval.providerName.trim()}  •  ${approval.notes.isEmpty ? 'Request' : approval.notes}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: const Text(
                  'Under review',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E40AF),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _Timeline(date: date),
          const Spacer(),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Expected within 7 Min',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    letterSpacing: .5,
                    color: Color(0xFF5D636E),
                  ),
                ),
              ),
              InkWell(
                onTap: () => context.push('/approval-history'),
                child: const Row(
                  children: [
                    Text(
                      'View Details',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5983F3),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 14,
                      color: Color(0xFF5983F3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final String date;

  const _Timeline({required this.date});

  @override
  Widget build(BuildContext context) {
    const labels = ['Submitted', 'Reviewing', 'Decision', 'Completed'];
    return SizedBox(
      height: 75.h,
      child: Stack(
        children: [
          Positioned(
            left: 18.w,
            right: 18.w,
            top: 13.h,
            child: Container(height: 2.h, color: const Color(0xFFE5E7EB)),
          ),
          Positioned(
            left: 18.w,
            width: 110.w,
            top: 13.h,
            child: Container(height: 2.h, color: const Color(0xFF5983F3)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(labels.length, (index) {
              final active = index < 2;
              return SizedBox(
                width: 54.w,
                child: Column(
                  children: [
                    Container(
                      width: 28.w,
                      height: 28.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFF5983F3)
                            : const Color(0xFFE6E6EA),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        index == 0
                            ? Icons.check
                            : index == 1
                            ? Icons.search
                            : index == 2
                            ? Icons.verified_outlined
                            : Icons.assignment_outlined,
                        size: 18.w,
                        color: active ? Colors.white : const Color(0xFF9CA3AF),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      labels[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: active
                            ? const Color(0xFF5983F3)
                            : const Color(0xFF6B7280),
                        fontWeight: active
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    if (index < 2)
                      Text(
                        date,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
