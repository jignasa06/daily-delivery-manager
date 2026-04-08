import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class CommonRoleSelector extends StatelessWidget {
  final String currentRole;
  final ValueChanged<String> onRoleChanged;

  const CommonRoleSelector({
    super.key,
    required this.currentRole,
    required this.onRoleChanged,
  });

  Widget _roleChip(String title) {
    bool isSelected = currentRole == title;
    return GestureDetector(
      onTap: () => onRoleChanged(title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceOffWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceLightGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: AppStyles.inputLabel.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _roleChip(AppStrings.roleUser)),
        const SizedBox(width: 16),
        Expanded(child: _roleChip(AppStrings.roleAdmin)),
      ],
    );
  }
}
