import 'package:flutter/material.dart';

import '../../virtual_world/settings.dart';

class OSMDialog extends StatefulWidget {
  const OSMDialog({
    super.key,
    this.onSubmit,
    this.onDismiss,
  });

  final Function(String)? onSubmit;
  final VoidCallback? onDismiss;

  @override
  State<OSMDialog> createState() => _OSMDialogState();
}

class _OSMDialogState extends State<OSMDialog> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87.withOpacity(0.4),
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      child: Center(
        child: Container(
          width: MediaQuery.sizeOf(context).width / 2,
          height: MediaQuery.sizeOf(context).height / 2,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              VirtualWorldSettings.controlsRadius,
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.multiline,
                  minLines: 9,
                  maxLines: 9,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Paste OSM data here',
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => widget.onSubmit?.call(controller.text),
                    icon: const Icon(Icons.check, color: Colors.green),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: widget.onDismiss,
                    icon: const Icon(Icons.close, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
