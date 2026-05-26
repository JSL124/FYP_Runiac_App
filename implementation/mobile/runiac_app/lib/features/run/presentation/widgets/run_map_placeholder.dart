import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';

class RunMapPlaceholder extends StatelessWidget {
  const RunMapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: RuniacColors.background),
      child: Stack(
        children: [
          Positioned.fill(child: _RunMapGrid()),
          Positioned.fill(child: _RunRouteLine()),
          Positioned(left: 52, top: 92, child: _RunRouteMarker()),
          Positioned(right: 58, top: 148, child: _RunRouteFlag()),
          Positioned(left: 110, bottom: 196, child: _RunRouteMarker()),
        ],
      ),
    );
  }
}

class _RunMapGrid extends StatelessWidget {
  const _RunMapGrid();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _RunMapGridPainter());
  }
}

class _RunRouteLine extends StatelessWidget {
  const _RunRouteLine();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _RunRouteLinePainter());
  }
}

class _RunRouteMarker extends StatelessWidget {
  const _RunRouteMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: RuniacColors.accentOrange, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A172033),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.place,
        color: RuniacColors.accentOrange,
        size: 16,
      ),
    );
  }
}

class _RunRouteFlag extends StatelessWidget {
  const _RunRouteFlag();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: RuniacColors.primaryBlue,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A172033),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.flag, color: RuniacColors.white, size: 20),
    );
  }
}

class _RunMapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = RuniacColors.background;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final roadPaint = Paint()
      ..color = RuniacColors.border
      ..strokeWidth = 2;
    for (var x = -size.height; x < size.width; x += 76) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        roadPaint,
      );
    }
    for (var y = 34.0; y < size.height; y += 72) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 26), roadPaint);
    }

    final parkPaint = Paint()..color = const Color(0x1435B779);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.58, 30, size.width * 0.28, 84),
        const Radius.circular(8),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(24, size.height * 0.62, size.width * 0.32, 78),
        const Radius.circular(8),
      ),
      parkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RunRouteLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final routePath = Path()
      ..moveTo(size.width * 0.18, size.height * 0.34)
      ..cubicTo(
        size.width * 0.36,
        size.height * 0.18,
        size.width * 0.52,
        size.height * 0.56,
        size.width * 0.68,
        size.height * 0.42,
      )
      ..cubicTo(
        size.width * 0.82,
        size.height * 0.30,
        size.width * 0.82,
        size.height * 0.66,
        size.width * 0.56,
        size.height * 0.70,
      )
      ..cubicTo(
        size.width * 0.40,
        size.height * 0.73,
        size.width * 0.34,
        size.height * 0.56,
        size.width * 0.30,
        size.height * 0.82,
      );

    final shadowPaint = Paint()
      ..color = const Color(0x332F50C7)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, shadowPaint);

    final routePaint = Paint()
      ..color = RuniacColors.primaryBlue
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
