import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class SellerStepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const SellerStepIndicator({
    super.key,
    required this.currentStep,
    this.steps = const ['Account', 'Business', 'Verification'],
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final stepIndex = index ~/ 2;
            final isCompleted = currentStep > stepIndex;
            return Expanded(
              child: Container(
                height: 3,
                color: isCompleted ? AppColors.primaryPurple : Colors.grey.shade300,
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final isActive = currentStep == stepIndex;
          final isCompleted = currentStep > stepIndex;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppColors.primaryPurple
                      : isActive
                          ? AppColors.primaryPurple
                          : Colors.grey.shade200,
                  border: Border.all(
                    color: isActive ? AppColors.primaryPurple : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text(
                          '${stepIndex + 1}',
                          style: AppTextStyles.bold.copyWith(
                            color: isActive ? Colors.white : Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIndex],
                style: AppTextStyles.bold.copyWith(
                  fontSize: 11,
                  color: isActive
                      ? AppColors.primaryPurple
                      : isCompleted
                          ? AppColors.darkText
                          : AppColors.hintText,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
