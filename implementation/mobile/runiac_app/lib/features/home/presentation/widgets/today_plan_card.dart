import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/card_title.dart';
import '../../../../core/widgets/crossed_placeholder.dart';
import '../../../../core/widgets/dashboard_card.dart';

class TodayPlanCard extends StatelessWidget {
  const TodayPlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(icon: Icons.calendar_today, title: 'Today\'s Plan'),
          const SizedBox(height: 14),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready for an easy run?',
                      style: TextStyle(
                        color: RuniacColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your next run will appear here.',
                      style: TextStyle(
                        color: RuniacColors.textSecondary,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 14),
              _PlanImagePlaceholder(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: RuniacColors.primaryBlue,
                    side: const BorderSide(color: RuniacColors.border),
                    minimumSize: const Size.fromHeight(42),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  child: const Text('View Plan'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.directions_run),
                  label: const Text('Quick Start'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(42),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanImagePlaceholder extends StatelessWidget {
  const _PlanImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const CrossedPlaceholder(width: 96, height: 96);
  }
}
