import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SPopScope extends StatelessWidget {
  final bool isCommunicating;
  final void Function() cancelCommunication;
  final Widget child;

  const SPopScope({
    super.key,
    required this.isCommunicating,
    required this.cancelCommunication,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isCommunicating,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          if (isCommunicating) cancelCommunication();
          if (context.canPop()) context.pop();
        }
      },
      child: child,
    );
  }
}
