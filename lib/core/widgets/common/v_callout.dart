import 'package:flutter/material.dart';
import '../../theme/app_palette.dart';

enum VCalloutVariant {
  accent,
  info,
  warning,
  danger,
  indigo,
}

class VCallout extends StatelessWidget {
  final String message;
  final String? title;
  final IconData icon;
  final VCalloutVariant variant;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const VCallout({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.shield_outlined,
    this.variant = VCalloutVariant.accent,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    Color color;
    switch (variant) {
      case VCalloutVariant.accent:
        color = palette.accent;
        break;
      case VCalloutVariant.info:
        color = palette.teal;
        break;
      case VCalloutVariant.warning:
        color = palette.warning;
        break;
      case VCalloutVariant.danger:
        color = palette.danger;
        break;
      case VCalloutVariant.indigo:
        color = palette.indigo;
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: context.isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(
          color: color.withValues(alpha: context.isDark ? 0.35 : 0.25),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null && title!.isNotEmpty) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: palette.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
