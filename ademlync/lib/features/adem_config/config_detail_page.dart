import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../utils/access_code_helper.dart';
import '../../utils/app_delegate.dart';
import '../../utils/constants.dart';
import '../../utils/controllers/param_format_manager.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_data_field.dart';
import '../../utils/widgets/s_decoration.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/smart_body_layout.dart';
import 'adem_config.dart';
import 'configs_page_bloc.dart';

class ConfigDetailPage extends StatelessWidget with AccessCodeHelper {
  final AdemConfigDetail config;

  const ConfigDetailPage({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    late final bloc = BlocProvider.of<ConfigsPageBloc>(context);

    return BlocConsumer(
      bloc: bloc,
      listener: (_, state) {
        if (state is ImportedState) {
          context.pop();
          showToast(context, text: 'Import succeed.');
        } else if (state is FailedState) {
          showToast(context, text: 'Import failed.');
        }
      },
      builder: (_, state) {
        return Scaffold(
          appBar: SAppBar.withSubmit(
            context,
            text: 'Configuration',
            isSubmitLoading: state is ImportingState,
            actionText: 'Import',
            onPressed: !config.isConflict
                ? () async {
                    final accessCode = await getAccessCode(context);
                    if (accessCode != null) {
                      bloc.add(ImportEvent(accessCode, config));
                    }
                  }
                : null,
          ),
          body: SmartBodyLayout(
            child: Column(
              children: [
                if (config.isConflict) ...[
                  SCard(
                    title: 'Conflicts',
                    child: ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (_, i) {
                        final o = config.conflicts.toList()[i];

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SText.bodyMedium('• '),
                            Expanded(
                              child: SText.bodyMedium(o.text, softWrap: true),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (_, _) => const Gap(12.0),
                      itemCount: config.conflicts.length,
                    ),
                  ),
                  const Gap(24.0),
                ],
                SCard(
                  title: 'Parameter Validation',
                  child: Column(
                    spacing: 24.0,
                    children: excludedAdemConfigParams(AppDelegate().adem)
                        .map(
                          (o) => SDecoration(
                            header: o.displayName,
                            child: SDataField.string(
                              param: o,
                              value: ParamFormatManager().decodeToDisplayValue(
                                o,
                                config.config[o],
                                AppDelegate().adem,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const Gap(24.0),
                SCard(
                  title: 'Import Parameters',
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (_, i) {
                      final o = config
                          .importableConfig(AppDelegate().adem)
                          .entries
                          .toList()[i];
                      final value = ParamFormatManager().decodeToDisplayValue(
                        o.key,
                        o.value,
                        AppDelegate().adem,
                      );

                      return SDecoration(
                        header: o.key.displayName,
                        child: SDataField.string(param: o.key, value: value),
                      );
                    },
                    separatorBuilder: (_, _) => const Divider(height: 24.0),
                    itemCount: config
                        .importableConfig(AppDelegate().adem)
                        .length,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
