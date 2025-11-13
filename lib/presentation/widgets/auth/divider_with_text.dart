import 'package:flutter/material.dart';
import 'package:recipe_daily/core/constants/app_colors.dart';

class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.thirdary,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.thirdary,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.thirdary,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}