import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_delegate.dart';
import '../utils/custom_color_scheme.dart';
import '../utils/functions.dart';
import '../utils/widgets/s_app_bar.dart';
import '../utils/widgets/s_card.dart';
import '../utils/widgets/s_text.dart';
import '../utils/widgets/smart_body_layout.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  late final appState = Provider.of<AppStateNotifier>(context);

  AppDelegate get _app => AppDelegate();

  @override
  Widget build(BuildContext context) {
    // final isDark = appState.isDark;

    return Scaffold(
      appBar: SAppBar(text: locale.settingsString),
      body: SmartBodyLayout(
        children: [
          SCard(
            child: Column(
              spacing: 12.0,
              children: [
                _Item(
                  text: 'System Appearance',
                  child: Switch(
                    value: appState.isSysAppearance,
                    onChanged: (_) => appState.toggleSysAppearance(),
                  ),
                ),

                if (!appState.isSysAppearance) ...[
                  const Divider(height: 0.0),

                  _Item(
                    text: 'Dark Appearance',
                    child: Switch(
                      value: appState.isDark,
                      onChanged: (_) => appState.toggleAppearance(),
                    ),
                  ),
                ],
              ],
            ),
          ),

          SCard(
            child: _Item(
              text: '24 Hours Format',
              child: Switch(
                value: _app.is24HTimeFmt,
                onChanged: _updateTimeFmt,
              ),
            ),
          ),

          SCard(
            child: RadioGroup<ExportFormat>(
              groupValue: _app.exportFmt,
              onChanged: _updateExportFmt,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, i) {
                  final type = i == 0 ? ExportFormat.pdf : ExportFormat.excel;
                  return _Item(
                    text: type.displayName,
                    child: Radio(
                      value: type,
                      activeColor: colorScheme.accentGold(context),
                    ),
                  );
                },
                separatorBuilder: (_, _) =>
                    const Divider(height: 12.0, thickness: 1.0),
                itemCount: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateTimeFmt(bool value) {
    _app.updateTimeFmt(value);
    setState(() {});
  }

  void _updateExportFmt(ExportFormat? value) {
    _app.updateExportFmt(value ?? ExportFormat.pdf);
    setState(() {});
  }
}

class _Item extends StatelessWidget {
  final String text;
  final Widget child;

  const _Item({required this.text, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [SText.titleMedium(text), child],
    );
  }
}
