import 'package:flutter/material.dart';

import '../block_registry.dart';

/// Shows a popup menu to insert a GMA-MD block template.
/// Returns the template string to insert, or null if cancelled.
Future<String?> showBlockInsertMenu(BuildContext context, Offset position) {
  final categories = blocksByCategory;

  return showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      position.dx + 1,
      position.dy + 1,
    ),
    items: [
      for (final entry in categories.entries) ...[
        PopupMenuItem<String>(
          enabled: false,
          height: 28,
          child: Text(
            entry.key,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
        ),
        for (final def in entry.value)
          PopupMenuItem<String>(
            value: def.template,
            height: 36,
            child: Row(
              children: [
                Icon(def.icon, size: 14, color: def.color),
                const SizedBox(width: 8),
                Text(def.label, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
      ],
    ],
  );
}
