import 'package:flutter/material.dart';

class CustomDialog extends StatefulWidget {
  final String? title;
  final String? content;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  const CustomDialog({
    super.key,
    this.title,
    this.content,
    this.onCancel,
    this.onConfirm, 
    this.confirmText, 
    this.cancelText, 
  });

  @override
  State<CustomDialog> createState() => _CustomDialogState();

  // Static method to show the dialog
  static Future<bool?> show(
    BuildContext context, {
    String? title,
    String? content,
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
    String? confirmText ,
    String? cancelText ,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: title,
          content: content,
          onCancel: onCancel,
          onConfirm: onConfirm,
          confirmText: confirmText,
          cancelText: cancelText,
        );
      },
    );
  }
}

class _CustomDialogState extends State<CustomDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title ?? 'Custom Dialog'),
      content: Text(widget.content ?? 'This is a custom dialog example.'),
      actions: <Widget>[
        TextButton(
          child: Text(widget.cancelText ?? 'Cancel'),
          onPressed: () {
            if (widget.onCancel != null) {
              widget.onCancel!();
            }
            Navigator.of(context).pop(false);
          },
        ),
        TextButton(
          child: Text(widget.confirmText ?? 'OK') ,
          onPressed: () {
            if (widget.onConfirm != null) {
              widget.onConfirm!();
            }
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}
