import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';

class RoutePreviewCard extends StatelessWidget {
  const RoutePreviewCard({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: RuniacColors.border),
      ),
      child: Row(
        children: [
          const _RouteThumbnailPlaceholder(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: RuniacColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(
                    color: RuniacColors.textSecondary,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            color: RuniacColors.textSecondary,
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _RouteThumbnailPlaceholder extends StatelessWidget {
  const _RouteThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: RuniacColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomPaint(painter: _RouteThumbnailPainter()),
      ),
    );
  }
}

class _RouteThumbnailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = RuniacColors.white
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(
        Offset(-6, 8),
        Offset(size.width + 6, size.height - 10),
        roadPaint,
      )
      ..drawLine(
        Offset(size.width * 0.58, -4),
        Offset(size.width * 0.35, size.height + 4),
        roadPaint,
      );

    final routePaint = Paint()
      ..color = RuniacColors.textPrimary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final routePath = Path()
      ..moveTo(size.width * 0.24, size.height * 0.68)
      ..cubicTo(
        size.width * 0.38,
        size.height * 0.24,
        size.width * 0.62,
        size.height * 0.84,
        size.width * 0.78,
        size.height * 0.36,
      );
    canvas.drawPath(routePath, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
