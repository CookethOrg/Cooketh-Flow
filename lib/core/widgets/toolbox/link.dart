import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LinkInsertButton extends StatelessWidget {
  const LinkInsertButton({Key? key}) : super(key: key);

  void _showCompactLinkDialog(BuildContext context) {
    TextEditingController _linkController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: TextField(
                    controller: _linkController,
                    decoration: const InputDecoration(
                      hintText: "Paste URL",
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.url,
                    autofocus: true,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.blue),
                  onPressed: () {
                    // Handle link insertion logic
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(PhosphorIconsRegular.linkSimple),
      onPressed: () => _showCompactLinkDialog(context),
      tooltip: "Insert Link",
    );
  }
}
