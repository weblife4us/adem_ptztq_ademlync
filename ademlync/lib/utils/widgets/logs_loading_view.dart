import 'package:flutter/material.dart';

import '../app_delegate.dart';
import '../custom_color_scheme.dart';
import 's_button.dart';
import 's_card.dart';
import 's_loading.dart';
import 's_text.dart';
import 'smart_body_layout.dart';

class LogsLoadingView extends StatefulWidget {
  final int logCounts;
  final VoidCallback onCanceled;

  const LogsLoadingView({
    super.key,
    required this.logCounts,
    required this.onCanceled,
  });

  @override
  State<LogsLoadingView> createState() => _LogsLoadingViewState();
}

class _LogsLoadingViewState extends State<LogsLoadingView> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SmartBodyLayout(
      child: Center(
        child: SCard(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SLoading(text: 'Loading logs...'),
              const SizedBox(height: 24.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SText.bodySmall(
                  'Retrieved ${widget.logCounts} log(s) ',
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(height: 24.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SText.bodySmall(
                  'Wait until all logs are ready / Stop at any time to view',
                  softWrap: true,
                  textAlign: TextAlign.center,
                  color: colorScheme.grey,
                ),
              ),
              const SizedBox(height: 32.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: SButton.outlined(
                  text: 'Stop to View',
                  isLoading: _isLoading,
                  onPressed: () {
                    setState(() => _isLoading = true);
                    widget.onCanceled();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
