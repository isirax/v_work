import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';

class VLogo extends StatelessWidget {
  final double size;
  final bool showGlow;
  final bool useAssetImage;
  final bool showBadge;

  const VLogo({
    super.key,
    this.size = 48,
    this.showGlow = true,
    this.useAssetImage = true,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget logoContent = SvgPicture.asset(
      'assets/images/logo.svg',
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholderBuilder: (context) => Image.asset(
        'assets/images/logo_1024.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _VectorVLogo(size: size),
      ),
    );

    if (showBadge) {
      return Container(
        width: size * 1.25,
        height: size * 1.25,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(size * 0.32),
          border: Border.all(
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
            width: 1.5,
          ),
          boxShadow: showGlow
              ? [
                  BoxShadow(
                    color: isDark
                        ? AppColors.primaryCobalt.withValues(alpha: 0.3)
                        : AppColors.logoNavy.withValues(alpha: 0.12),
                    blurRadius: size * 0.35,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: logoContent,
        ),
      );
    }

    if (!showGlow) {
      return SizedBox(
        width: size,
        height: size,
        child: logoContent,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.primaryIce.withValues(alpha: 0.30)
                : AppColors.logoNavy.withValues(alpha: 0.15),
            blurRadius: size * 0.4,
            spreadRadius: 1,
          ),
          if (isDark)
            BoxShadow(
              color: AppColors.primaryCobalt.withValues(alpha: 0.25),
              blurRadius: size * 0.6,
            ),
        ],
      ),
      child: logoContent,
    );
  }
}

class _VectorVLogo extends StatelessWidget {
  final double size;
  const _VectorVLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _VLogoPainter(),
    );
  }
}

class _VLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Scale from 1000x1000 canonical coordinate space
    final sx = w / 1000.0;
    final sy = h / 1000.0;

    // Outer Silver / Platinum Polygon:
    // points="115,127 371,226 500,545 629,226 885,127 572,870 428,870"
    final outerPath = Path()
      ..moveTo(115 * sx, 127 * sy)
      ..lineTo(371 * sx, 226 * sy)
      ..lineTo(500 * sx, 545 * sy)
      ..lineTo(629 * sx, 226 * sy)
      ..lineTo(885 * sx, 127 * sy)
      ..lineTo(572 * sx, 870 * sy)
      ..lineTo(428 * sx, 870 * sy)
      ..close();

    final outerPaint = Paint()
      ..color = const Color(0xFFCBD2D9)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(outerPath, outerPaint);

    // Inner Deep Navy / Cobalt Polygon:
    // points="155,165 353,242 500,605 647,242 845,165 555,846 445,846"
    final innerPath = Path()
      ..moveTo(155 * sx, 165 * sy)
      ..lineTo(353 * sx, 242 * sy)
      ..lineTo(500 * sx, 605 * sy)
      ..lineTo(647 * sx, 242 * sy)
      ..lineTo(845 * sx, 165 * sy)
      ..lineTo(555 * sx, 846 * sy)
      ..lineTo(445 * sx, 846 * sy)
      ..close();

    final innerPaint = Paint()
      ..color = const Color(0xFF002D62)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(innerPath, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
