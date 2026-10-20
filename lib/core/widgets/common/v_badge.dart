import 'package:flutter/material.dart';
import '../../theme/app_palette.dart';

enum VBadgeVariant {
  accent,
  cyan,
  success,
  warning,
  danger,
  indigo,
  orange,
  neutral,
}

class VBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VBadgeVariant variant;
  final bool isBold;
  final EdgeInsetsGeometry padding;
  final double fontSize;

  const VBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = VBadgeVariant.accent,
    this.isBold = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    Color baseColor;
    switch (variant) {
      case VBadgeVariant.accent:
        baseColor = palette.accent;
        break;
      case VBadgeVariant.cyan:
        baseColor = palette.teal;
        break;
      case VBadgeVariant.success:
        baseColor = palette.success;
        break;
      case VBadgeVariant.warning:
        baseColor = palette.warning;
        break;
      case VBadgeVariant.danger:
        baseColor = palette.danger;
        break;
      case VBadgeVariant.indigo:
        baseColor = palette.indigo;
        break;
      case VBadgeVariant.orange:
        baseColor = palette.orange;
        break;
      case VBadgeVariant.neutral:
        baseColor = palette.textMuted;
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: context.isDark ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(
          color: baseColor.withValues(alpha: context.isDark ? 0.35 : 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 1, color: baseColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: baseColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
