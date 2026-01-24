import 'package:flutter/material.dart';

import 'widgets/access_code_input_dialog.dart';
import 'app_delegate.dart';

mixin AccessCodeHelper {
  Future<String?> getAccessCode(
    BuildContext context, {
    bool isRequireSuperAccessCode = false,
  }) async {
    final adem = AppDelegate().adem;
    final isSuperAccessCodeSupported = adem.isSuperAccessCodeSupported;
    final accessCode = await showDialog<String>(
      context: context,
      builder: (_) => AccessCodeInputDialog(
        isRequireSuperAccessCode && isSuperAccessCodeSupported,
      ),
    );
    return accessCode?.length == 5 ? accessCode : null;
  }
}
