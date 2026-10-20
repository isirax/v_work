import 'package:flutter/material.dart';
import '../../theme/app_palette.dart';

class VCheckbox extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool>? onChanged;
  final double size;
  final Color? activeColor;
  final Color? checkColor;

  const VCheckbox({
    super.key,
    required this.isChecked,
    this.onChanged,
    this.size = 24,
    this.activeColor,
    this.checkColor,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final effectiveActiveColor = activeColor ?? palette.accent;
    final effectiveCheckColor = checkColor ?? palette.onAccent;

    return Semantics(
      checked: isChecked,
      child: InkWell(
        onTap: onChanged != null ? () => onChanged!(!isChecked) : null,
        borderRadius: BorderRadius.circular(Radii.sm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isChecked
                ? effectiveActiveColor
                : palette.surfaceSunken,
            borderRadius: BorderRadius.circular(Radii.sm),
            border: Border.all(
              color: isChecked
                  ? effectiveActiveColor
                  : palette.border,
              width: 1.5,
            ),
            boxShadow: isChecked && context.isDark
                ? [
                    BoxShadow(
                      color: effectiveActiveColor.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: AnimatedScale(
              duration: const Duration(milliseconds: 150),
              scale: isChecked ? 1.0 : 0.0,
              child: Icon(
                Icons.check_rounded,
                size: size * 0.72,
                color: effectiveCheckColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
