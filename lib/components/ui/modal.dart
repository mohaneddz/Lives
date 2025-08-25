import 'package:flutter/material.dart';

class MyModal extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;

  const MyModal({super.key, required this.title, required this.content, this.actions});

  static Future<void> show(BuildContext context, {required String title, required Widget content, List<Widget>? actions}) {
    return showDialog(
      context: context,
      builder: (context) => MyModal(title: title, content: content, actions: actions),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: content,
      actions: actions ?? [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
    );
  }
}
