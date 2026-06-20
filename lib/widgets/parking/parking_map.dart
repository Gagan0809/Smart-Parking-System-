import 'package:flutter/material.dart';
import '../../core/constants.dart';

class ParkingMap extends StatelessWidget {
  const ParkingMap({
    required this.zoom,
    required this.location,
    required this.onZoomIn,
    required this.onZoomOut,
    super.key,
  });

  final double zoom;
  final String location;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: ParkingMapPainter(zoom: zoom)),
          Positioned(
            left: 12,
            bottom: 12,
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
                children: [
                  TextSpan(text: 'G', style: TextStyle(color: Color(0xFF4285F4))),
                  TextSpan(text: 'o', style: TextStyle(color: Color(0xFFDB4437))),
                  TextSpan(text: 'o', style: TextStyle(color: Color(0xFFF4B400))),
                  TextSpan(text: 'g', style: TextStyle(color: Color(0xFF4285F4))),
                  TextSpan(text: 'l', style: TextStyle(color: Color(0xFF0F9D58))),
                  TextSpan(text: 'e', style: TextStyle(color: Color(0xFFDB4437))),
                ],
              ),
            ),
          ),
          Positioned(
            right: 14,
            bottom: 22,
            child: Column(
              children: [
                MapZoomButton(icon: Icons.add, onPressed: onZoomIn),
                const SizedBox(height: 1),
                MapZoomButton(icon: Icons.remove, onPressed: onZoomOut),
              ],
            ),
          ),
          if (location.isNotEmpty)
            Positioned(
              left: 18,
              top: 18,
              right: 18,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  child: Text(
                    location,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ParkingMapPainter extends CustomPainter {
  ParkingMapPainter({required this.zoom});

  final double zoom;

  @override
  void paint(Canvas canvas, Size size) {
    final landPaint = Paint()..color = AppColors.mapLand;
    canvas.drawRect(Offset.zero & size, landPaint);

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(zoom);
    canvas.translate(-size.width / 2, -size.height / 2);

    final parkPaint = Paint()..color = const Color(0xFFD7E5CE);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.28, size.height * 0.34),
        width: size.width * 0.34,
        height: size.height * 0.2,
      ),
      parkPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.76, size.height * 0.62),
        width: size.width * 0.28,
        height: size.height * 0.18,
      ),
      parkPaint,
    );

    _drawRoad(
      canvas,
      [
        Offset(-20, size.height * 0.78),
        Offset(size.width * 0.18, size.height * 0.66),
        Offset(size.width * 0.48, size.height * 0.7),
        Offset(size.width + 20, size.height * 0.46),
      ],
      24,
      const Color(0xFFCFCFC8),
    );
    _drawRoad(
      canvas,
      [
        Offset(size.width * 0.58, -20),
        Offset(size.width * 0.56, size.height * 0.38),
        Offset(size.width * 0.62, size.height + 20),
      ],
      18,
      const Color(0xFFD8D8D2),
    );
    _drawRoad(
      canvas,
      [
        Offset(-20, size.height * 0.26),
        Offset(size.width * 0.32, size.height * 0.32),
        Offset(size.width * 0.68, size.height * 0.22),
        Offset(size.width + 20, size.height * 0.28),
      ],
      16,
      const Color(0xFFD2D2CC),
    );

    _drawParkingBlock(canvas, Offset(size.width * 0.2, size.height * 0.52), 'P');
    _drawParkingBlock(canvas, Offset(size.width * 0.7, size.height * 0.38), 'P');
    _drawMarker(canvas, Offset(size.width * 0.52, size.height * 0.56));

    canvas.restore();
  }

  void _drawRoad(
    Canvas canvas,
    List<Offset> points,
    double width,
    Color color,
  ) {
    final roadPaint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, roadPaint);

    final lanePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.64)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, lanePaint);
  }

  void _drawParkingBlock(Canvas canvas, Offset center, String label) {
    final rect = Rect.fromCenter(center: center, width: 42, height: 34);
    final paint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(7)),
      paint,
    );
    final border = Paint()
      ..color = AppColors.brightBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(7)),
      border,
    );
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: AppColors.brightBlue,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _drawMarker(Canvas canvas, Offset center) {
    final paint = Paint()..color = AppColors.occupied;
    final path = Path()
      ..moveTo(center.dx, center.dy + 18)
      ..quadraticBezierTo(center.dx - 17, center.dy - 2, center.dx, center.dy - 22)
      ..quadraticBezierTo(center.dx + 17, center.dy - 2, center.dx, center.dy + 18);
    canvas.drawPath(path, paint);
    canvas.drawCircle(center.translate(0, -6), 6, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(ParkingMapPainter oldDelegate) => oldDelegate.zoom != zoom;
}

class MapZoomButton extends StatelessWidget {
  const MapZoomButton({
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 43,
      height: 43,
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onPressed,
          child: Icon(icon, color: const Color(0xFF5C5C5C), size: 26),
        ),
      ),
    );
  }
}
