import 'package:flutter/material.dart';
import '../../theme/app_palette.dart';

class VSegmentItem<T> {
  final T value;
  final String label;
  final IconData? icon;

  const VSegmentItem({
    required this.value,
    required this.label,
    this.icon,
  });
}

class VSegmentControl<T> extends StatelessWidget {
  final List<VSegmentItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final Color? activeColor;
  final double height;

  const VSegmentControl({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    this.activeColor,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final primaryActive = activeColor ?? palette.accent;

    return Container(
      height: height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: palette.surfaceSunken,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: items.map((item) {
          final isSelected = item.value == selectedValue;

          return Expanded(
            child: InkWell(
              onTap: () => onSelected(item.value),
              borderRadius: BorderRadius.circular(Radii.sm),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryActive
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(Radii.sm),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryActive.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.icon != null) ...[
                        Icon(
                          item.icon,
                          size: 14,
                          color: isSelected
                              ? palette.onAccent
                              : palette.textMuted,
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? palette.onAccent
                              : palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
