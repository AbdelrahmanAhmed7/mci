import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/features/family_members/data/family_response_model.dart';
import 'package:mediconsult/features/family_members/presentation/cubit/family_members_cubit.dart';
import 'package:mediconsult/features/family_members/presentation/cubit/family_members_state.dart';

/// Horizontal chips for filtering by family member
/// Shows only family members as selectable chips (no "All" option)
class FamilyMemberFilterDropdown extends StatefulWidget {
  final int? selectedMemberId;
  final Function(int) onMemberChanged; // Changed from int? to int (required)

  const FamilyMemberFilterDropdown({
    super.key,
    this.selectedMemberId,
    required this.onMemberChanged,
  });

  @override
  State<FamilyMemberFilterDropdown> createState() =>
      _FamilyMemberFilterDropdownState();
}

class _FamilyMemberFilterDropdownState
    extends State<FamilyMemberFilterDropdown> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFamilyMembers();
    });
  }

  void _loadFamilyMembers() {
    final cubit = context.read<FamilyMembersCubit>();
    final state = cubit.state;
    state.maybeWhen(
      loaded: (_) {},
      loading: () {},
      orElse: () {
        cubit.getFamilyMembers(context.locale.languageCode);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FamilyMembersCubit, FamilyMembersState>(
      builder: (context, state) {
        return state.when(
          initial: () => _buildChips([]),
          loading: () => _buildLoadingChips(),
          loaded: (response) => _buildChips(response.data.familyMembers),
          failed: (message) => _buildChips([]),
        );
      },
    );
  }

  Widget _buildLoadingChips() {
    return SizedBox(
      height: 40.h,
      child: Row(
        children: [
          SizedBox(
            width: 20.w,
            height: 20.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryClr,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChips(List<FamilyMember> members) {
    if (members.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: members.length, // Removed +1 for "All Members"
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          // Family member chips only
          final member = members[index];
          final isSelected = widget.selectedMemberId == member.memberId;
          return _buildChip(
            label: member.memberName,
            isSelected: isSelected,
            onTap: () => widget.onMemberChanged(member.memberId),
            imageUrl: member.memberImage,
          );
        },
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    String? imageUrl,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryClr : AppColors.whiteClr,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryClr : AppColors.borderClr,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageUrl != null) ...[
              CircleAvatar(
                radius: 10.r,
                backgroundImage: NetworkImage(imageUrl),
                backgroundColor: AppColors.primaryClr.withValues(alpha: 0.1),
              ),
              SizedBox(width: 6.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.whiteClr : AppColors.blackClr,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
