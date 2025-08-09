import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_deficiencies/common/common.dart';

Future<void> showRenameDialog({
  required BuildContext context,
  required String initialTitle,
  required Function(String newTitle) onRename,
}) async {
  TextEditingController controller = TextEditingController(text: initialTitle);

  await showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: appText(
          title: 'Rename Title',
          fontWeight: FontWeight.w600,
          color: Colors.black,
          fontSize: 20
        ),
        content: Column(
          children: [
            SizedBox(height: 12),
            CupertinoTextField(
              controller: controller,
              placeholder: 'Enter new title',
              autofocus: true,
              cursorColor: Colors.black,
              style: TextStyle(
                fontFamily: 'gelasio',
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: appText(
              title: 'Cancel',
                color: Colors.black
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: appText(
              title: 'Rename',
              color: Colors.black
            ),
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                onRename(newTitle);
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
