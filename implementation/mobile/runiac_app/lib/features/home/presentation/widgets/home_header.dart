import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeAccentBar(),
              SizedBox(height: 12),
              Text(
                'Good to see you',
                style: TextStyle(
                  color: RuniacColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Your Home dashboard is ready for a calm start.',
                style: TextStyle(
                  color: RuniacColors.textSecondary,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12),
        _HomeProfilePlaceholder(),
      ],
    );
  }
}

class _HomeProfilePlaceholder extends StatelessWidget {
  const _HomeProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 58,
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            top: 17,
            child: Icon(
              Icons.notifications_none,
              color: RuniacColors.textPrimary,
              size: 24,
            ),
          ),
          Positioned(
            right: 0,
            top: 2,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: RuniacColors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: RuniacColors.border),
              ),
              child: const Icon(
                Icons.person_outline,
                color: RuniacColors.textSecondary,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeAccentBar extends StatelessWidget {
  const _HomeAccentBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 5,
          decoration: BoxDecoration(
            color: RuniacColors.primaryBlue,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 18,
          height: 5,
          decoration: BoxDecoration(
            color: RuniacColors.accentOrange,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}
