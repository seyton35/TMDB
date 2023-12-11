import 'dart:math';
import 'package:flutter/material.dart';

class RoundPercentBarWidget extends StatelessWidget {
  final double percent;
  final double lineWidth;
  final Color fillcolor;
  final Color fullcolor;
  final Color freecolor;
  const RoundPercentBarWidget({
    super.key,
    required this.percent,
    required this.lineWidth,
    required this.fillcolor,
    required this.fullcolor,
    required this.freecolor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: _MyPainter(
            fillcolor: fillcolor,
            fullcolor: fullcolor,
            freecolor: freecolor,
            lineWidth: lineWidth,
            percent: percent,
          ),
        ),
        Positioned(
          left: lineWidth * 3,
          right: lineWidth * 3,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              '${percent.round()}%',
              style:
                  TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
        )
      ],
    );
  }
}

class _MyPainter extends CustomPainter {
  double percent;
  final double lineWidth;
  final Color fillcolor;
  final Color fullcolor;
  final Color freecolor;

  _MyPainter({
    super.repaint,
    required this.percent,
    required this.lineWidth,
    required this.fillcolor,
    required this.fullcolor,
    required this.freecolor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    percent = percent / 100;
    final arkRect = calculateArcRect(size);

    drawBackGround(canvas, size);
    drawFreeArk(canvas, arkRect);
    drawScoreArk(canvas, arkRect);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  Rect calculateArcRect(Size size) {
    final lineMargin = 3;
    final offset = lineWidth / 2 + lineMargin;
    final rect = Offset(offset, offset) &
        Size(size.width - offset * 2, size.height - offset * 2);
    return rect;
  }

  void drawBackGround(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = fillcolor;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.width / 2),
      size.width / 2,
      paint,
    );
  }

  void drawFreeArk(Canvas canvas, Rect rect) {
    final paint = Paint();
    paint.color = freecolor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = lineWidth;
    canvas.drawArc(
      rect,
      pi * 2 * percent - pi / 2,
      pi * 2 * (1 - percent),
      false,
      paint,
    );
  }

  void drawScoreArk(Canvas canvas, Rect rect) {
    final paint = Paint();
    paint.color = fullcolor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = lineWidth;
    paint.strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect,
      -pi / 2,
      pi * 2 * percent,
      false,
      paint,
    );
  }
}
