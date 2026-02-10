import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// File browser sidebar showing note folders and files.
class FileBrowserScreen extends ConsumerWidget {
  const FileBrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Text(
        'File Browser',
        style: ShadTheme.of(context).textTheme.h4,
      ),
    );
  }
}
