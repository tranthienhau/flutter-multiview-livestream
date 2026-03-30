import 'package:flutter/material.dart';

import '../../models/stream_layout.dart';

/// Horizontal toolbar for switching between stream layouts.
class LayoutToolbar extends StatelessWidget {
  final StreamLayout currentLayout;
  final ValueChanged<StreamLayout> onLayoutChanged;

  const LayoutToolbar({
    super.key,
    required this.currentLayout,
    required this.onLayoutChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: StreamLayout.values.map((layout) {
        final isSelected = layout == currentLayout;
        return Expanded(
          child: GestureDetector(
            onTap: () => onLayoutChanged(layout),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _iconForLayout(layout),
                    size: 18,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    layout.displayName,
                    style: TextStyle(
                      fontSize: 9,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _iconForLayout(StreamLayout layout) {
    switch (layout) {
      case StreamLayout.grid2x2:
        return Icons.grid_view;
      case StreamLayout.primaryWithThumbnails:
        return Icons.view_agenda;
      case StreamLayout.sideBySide:
        return Icons.view_column;
    }
  }
}
