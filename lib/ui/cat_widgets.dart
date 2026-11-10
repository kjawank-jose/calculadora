import 'package:flutter/material.dart';

const kNavy = Color(0xFF012060);
const kNavyDark = Color(0xFF01143D);
const kBlue = Color(0xFF1450A0);
const kAmber = Color(0xFFFFAD1F);
const kCream = Color(0xFFF3E3CC);
const kBrown = Color(0xFF3B2A25);

// ---------- Huella ----------
class PawPainter extends CustomPainter {
  const PawPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final shape = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.64),
          width: w * 0.66,
          height: h * 0.52,
        ),
      );
    const toes = [
      Offset(0.15, 0.42),
      Offset(0.36, 0.20),
      Offset(0.64, 0.20),
      Offset(0.85, 0.42),
    ];
    for (final t in toes) {
      shape.addOval(
        Rect.fromCenter(
          center: Offset(w * t.dx, h * t.dy),
          width: w * 0.22,
          height: h * 0.26,
        ),
      );
    }

    // sombra suave
    canvas.drawPath(
      shape.shift(Offset(0, h * 0.03)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.05),
    );
    // relleno crema
    canvas.drawPath(
      shape,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF3E0), kCream],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(PawPainter old) => false;
}

class PawButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const PawButton({super.key, required this.label, required this.onTap});

  @override
  State<PawButton> createState() => _PawButtonState();
}

class _PawButtonState extends State<PawButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: AnimatedScale(
            scale: _down ? 0.88 : 1,
            duration: const Duration(milliseconds: 80),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: PawPainter()),
                ),
                Align(
                  alignment: const Alignment(0, 0.28),
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: kBrown,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
