import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/card_title.dart';
import '../../../../core/widgets/dashboard_card.dart';
import '../../../../core/widgets/soft_notice.dart';

class PostRunFeedbackCard extends StatelessWidget {
  const PostRunFeedbackCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitle(
            icon: Icons.tips_and_updates_outlined,
            title: 'Post-run Feedback',
          ),
          SizedBox(height: 12),
          Text(
            'Feedback will appear after a completed run.',
            style: TextStyle(
              color: RuniacColors.textSecondary,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          SizedBox(height: 12),
          SoftNotice(text: 'Helpful guidance will appear here after a run.'),
        ],
      ),
    );
  }
}
