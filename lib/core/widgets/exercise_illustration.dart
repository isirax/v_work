import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ExerciseIllustration extends StatefulWidget {
  final String illustrationKey;
  final double height;
  final bool isAnimated;

  const ExerciseIllustration({
    super.key,
    required this.illustrationKey,
    this.height = 140,
    this.isAnimated = true,
  });

  @override
  State<ExerciseIllustration> createState() => _ExerciseIllustrationState();
}

class _ExerciseIllustrationState extends State<ExerciseIllustration> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (widget.isAnimated) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F141F) : const Color(0xFFEDF2F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Stack(
        children: [
          // Background grid lines for biomechanical precision look
          Positioned.fill(
            child: CustomPaint(
              painter: _BiomechGridPainter(isDark: isDark),
            ),
          ),
          // Animated Vector Biomechanical Figure
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.height * 1.8, widget.height * 0.8),
                  painter: _ExerciseGraphicPainter(
                    type: widget.illustrationKey,
                    progress: _controller.value,
                    isDark: isDark,
                  ),
                );
              },
            ),
          ),
          // APT Alignment / Pelvic cue badge
          Positioned(
            bottom: 8,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryVolt.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_outlined, size: 12, color: AppColors.primaryVolt),
                  SizedBox(width: 4),
                  Text(
                    'APT PROTECTED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: AppColors.primaryVolt,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Loop indicator
          Positioned(
            top: 8,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark ? const Color(0x66000000) : const Color(0x66FFFFFF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.repeat, size: 12, color: AppColors.primaryCyan),
                  SizedBox(width: 4),
                  Text(
                    '5s LOOP',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryCyan,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BiomechGridPainter extends CustomPainter {
  final bool isDark;
  _BiomechGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04)
      ..strokeWidth = 1;

    const spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ExerciseGraphicPainter extends CustomPainter {
  final String type;
  final double progress;
  final bool isDark;

  _ExerciseGraphicPainter({
    required this.type,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final primaryPaint = Paint()
      ..color = AppColors.primaryVolt
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cyanPaint = Paint()
      ..color = AppColors.primaryCyan
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final barPaint = Paint()
      ..color = isDark ? Colors.white : const Color(0xFF1E293B)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    final jointPaint = Paint()
      ..color = isDark ? Colors.white : const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final animatedTravel = math.sin(progress * math.pi);

    switch (type) {
      case 'bench':
        // Bench pad
        canvas.drawLine(Offset(w * 0.2, h * 0.65), Offset(w * 0.8, h * 0.65), Paint()..color = Colors.grey.withValues(alpha: 0.5)..strokeWidth = 6);
        // Torso
        canvas.drawLine(Offset(w * 0.35, h * 0.62), Offset(w * 0.65, h * 0.62), primaryPaint);
        // Head
        canvas.drawCircle(Offset(w * 0.3, h * 0.60), 7, jointPaint);
        // Arms & Barbell traveling up and down
        final barY = h * 0.52 - (animatedTravel * 24);
        canvas.drawLine(Offset(w * 0.38, barY), Offset(w * 0.62, barY), barPaint);
        canvas.drawLine(Offset(w * 0.50, h * 0.62), Offset(w * 0.44, barY), cyanPaint);
        canvas.drawLine(Offset(w * 0.50, h * 0.62), Offset(w * 0.56, barY), cyanPaint);
        break;

      case 'squat':
        // Hack squat / Squat kinematics
        final hipY = h * 0.55 + (animatedTravel * 18);
        final kneeX = w * 0.56 + (animatedTravel * 8);
        final kneeY = h * 0.68;
        // Torso (Ribs stacked)
        canvas.drawLine(Offset(w * 0.44, hipY - 26), Offset(w * 0.48, hipY), primaryPaint);
        // Head
        canvas.drawCircle(Offset(w * 0.42, hipY - 34), 7, jointPaint);
        // Thigh
        canvas.drawLine(Offset(w * 0.48, hipY), Offset(kneeX, kneeY), cyanPaint);
        // Shin
        canvas.drawLine(Offset(kneeX, kneeY), Offset(w * 0.52, h * 0.85), primaryPaint);
        // Foot
        canvas.drawLine(Offset(w * 0.48, h * 0.85), Offset(w * 0.58, h * 0.85), barPaint);
        break;

      case 'glute_bridge':
        // Hip thrust / Glute bridge pelvic tuck
        final hipLiftY = h * 0.68 - (animatedTravel * 22);
        // Torso pivoted on bench
        canvas.drawLine(Offset(w * 0.35, h * 0.55), Offset(w * 0.50, hipLiftY), primaryPaint);
        // Pelvic circle
        canvas.drawCircle(Offset(w * 0.50, hipLiftY), 6, Paint()..color = AppColors.primaryVolt);
        // Thigh
        canvas.drawLine(Offset(w * 0.50, hipLiftY), Offset(w * 0.64, h * 0.55), cyanPaint);
        // Shin (Vertical at top)
        canvas.drawLine(Offset(w * 0.64, h * 0.55), Offset(w * 0.64, h * 0.82), primaryPaint);
        // Barbell
        canvas.drawLine(Offset(w * 0.42, hipLiftY - 4), Offset(w * 0.58, hipLiftY - 4), barPaint);
        break;

      case 'row':
      case 'lat_prayer':
      case 'pulldown':
        // Vertical/Horizontal pull kinematics
        final pullTravel = animatedTravel * 22;
        // Torso
        canvas.drawLine(Offset(w * 0.45, h * 0.35), Offset(w * 0.50, h * 0.72), primaryPaint);
        canvas.drawCircle(Offset(w * 0.43, h * 0.26), 7, jointPaint);
        // Arms
        final handY = h * 0.30 + pullTravel;
        canvas.drawLine(Offset(w * 0.46, h * 0.40), Offset(w * 0.62, handY), cyanPaint);
        // Cable / Handle
        canvas.drawLine(Offset(w * 0.55, handY), Offset(w * 0.70, handY), barPaint);
        // Thigh & Shin
        canvas.drawLine(Offset(w * 0.50, h * 0.72), Offset(w * 0.62, h * 0.72), primaryPaint);
        canvas.drawLine(Offset(w * 0.62, h * 0.72), Offset(w * 0.62, h * 0.90), primaryPaint);
        break;

      default:
        // Generic athletic form
        final swingY = math.sin(progress * math.pi) * 16;
        canvas.drawLine(Offset(w * 0.46, h * 0.35), Offset(w * 0.48, h * 0.65), primaryPaint);
        canvas.drawCircle(Offset(w * 0.45, h * 0.24), 7, jointPaint);
        canvas.drawLine(Offset(w * 0.46, h * 0.40), Offset(w * 0.60, h * 0.45 + swingY), cyanPaint);
        canvas.drawLine(Offset(w * 0.48, h * 0.65), Offset(w * 0.54, h * 0.85), primaryPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _ExerciseGraphicPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.type != type || oldDelegate.isDark != isDark;
  }
}
