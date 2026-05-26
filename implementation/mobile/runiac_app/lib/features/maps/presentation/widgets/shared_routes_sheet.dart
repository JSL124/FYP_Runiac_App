import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import 'route_preview_card.dart';

class SharedRoutesSheet extends StatelessWidget {
  const SharedRoutesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      minChildSize: 0.18,
      initialChildSize: 0.46,
      maxChildSize: 0.7,
      snap: true,
      snapSizes: const [0.18, 0.46, 0.7],
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: RuniacColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A172033),
                blurRadius: 18,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            physics: const ClampingScrollPhysics(),
            children: const [
              _SheetDragHandle(),
              SizedBox(height: 8),
              _SharedRoutesHeader(),
              SizedBox(height: 6),
              Text(
                'Nearby route suggestions will appear after location setup.',
                style: TextStyle(
                  color: RuniacColors.textSecondary,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              SizedBox(height: 12),
              RoutePreviewCard(
                title: 'Route preview',
                message: 'Details will appear after setup.',
              ),
              SizedBox(height: 8),
              RoutePreviewCard(
                title: 'Community routes',
                message: 'Shared route details will appear here.',
              ),
              SizedBox(height: 8),
              RoutePreviewCard(
                title: 'Saved routes',
                message: 'Saved routes will be available later.',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SheetDragHandle extends StatelessWidget {
  const _SheetDragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          color: RuniacColors.border,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _SharedRoutesHeader extends StatelessWidget {
  const _SharedRoutesHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Shared Routes',
            style: TextStyle(
              color: RuniacColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: RuniacColors.primaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          child: const Text('See all'),
        ),
      ],
    );
  }
}
