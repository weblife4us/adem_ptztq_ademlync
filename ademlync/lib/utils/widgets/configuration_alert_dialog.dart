import 'package:flutter/material.dart';

import 's_dialog_layout.dart';

class ConfigurationAlertDialog extends StatelessWidget {
  final String? message;

  const ConfigurationAlertDialog({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return SDialogLayout(
      title: 'Configuration Warning',
      detail: message ?? 'Please check all parameters on this page.',
      isShowCloseButton: true,
    );
  }
}
