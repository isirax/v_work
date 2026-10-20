import 'package:flutter/material.dart';
import '../../theme/app_palette.dart';

class VProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? color;
  final Widget? centerChild;
  final String? label;
  final String? valueText;
  final String? targetText;

  const VProgressRing({
    super.key,
    required this.progress,
    this.size = 60,
    this.strokeWidth = 5,
    this.color,
    this.centerChild,
    this.label,
    this.valueText,
    this.targetText,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final effectiveColor = color ?? palette.accent;
    final clampedProgress = progress.clamp(0.0, 1.0);

    final ringWidget = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: clampedProgress,
            strokeWidth: strokeWidth,
            strokeCap: StrokeCap.round,
            backgroundColor: effectiveColor.withValues(alpha: context.isDark ? 0.15 : 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
          ),
          if (centerChild != null)
            centerChild!
          else if (valueText != null)
            Text(
              valueText!,
              style: TextStyle(
                fontSize: size * 0.22,
                fontWeight: FontWeight.w900,
                color: palette.textPrimary,
              ),
            ),
        ],
      ),
    );

    if (label == null) {
      return ringWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ringWidget,
        const SizedBox(height: 6),
        Text(
          label!,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: palette.textPrimary,
          ),
        ),
        if (targetText != null)
          Text(
            targetText!,
            style: TextStyle(
              fontSize: 10,
              color: palette.textMuted,
            ),
          ),
      ],
    );
  }
}
