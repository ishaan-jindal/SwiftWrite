import 'package:flutter/material.dart';
import 'package:writer/utils/constants/app_colors.dart';

class ShowcaseContainer extends StatelessWidget {
  final String title;
  final String description;

  const ShowcaseContainer({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardColorLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        spacing: 5,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(color: AppColors.textColorLight),
          ),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: AppColors.textColorLight),
          ),
        ],
      ),
    );
  }
}
