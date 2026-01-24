import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_delegate.dart';
import '../../utils/constants.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_list_view.dart';
import '../../utils/widgets/s_loading.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/smart_body_layout.dart';
import 'adem_config.dart';
import 'configs_page_bloc.dart';

class ConfigsPage extends StatefulWidget {
  const ConfigsPage({super.key});

  @override
  State<ConfigsPage> createState() => _ConfigsPageState();
}

class _ConfigsPageState extends State<ConfigsPage> {
  late final _bloc = BlocProvider.of<ConfigsPageBloc>(context);
  List<AdemConfigDetail>? _configs;

  List<AdemConfigDetail>? get _validConfigs =>
      _configs?.where((o) => !o.isConflict).toList();

  List<AdemConfigDetail>? get _conflictConfigs =>
      _configs?.where((o) => o.isConflict).toList();

  @override
  void initState() {
    super.initState();
    _bloc.add(FetchEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: (_, state) {
        if (state is FetchedState) {
          setState(() => _configs = state.configs);
        } else if (state is FailedState) {
          context.pop();
        }
      },
      builder: (_, state) {
        return Scaffold(
          appBar: SAppBar(
            text: 'Configuration',
            hasAdemInfoAction: true,
            isLoading: _configs == null,
          ),
          body: SmartBodyLayout(
            child: _configs != null
                ? _configs!.isNotEmpty
                      ? Column(
                          spacing: 24.0,
                          children: [
                            if (_validConfigs!.isNotEmpty)
                              SListView(
                                value: _validConfigs!,
                                textBuilder: (o) => o.filename,
                                colorBuilder: (o) => o.isConflict
                                    ? colorScheme.warning(context)
                                    : colorScheme.text(context),
                                onPressed: (o) async {
                                  await context.push(
                                    '/setup/configuration/detail',
                                    extra: o,
                                  );
                                },
                              ),
                            if (_conflictConfigs!.isNotEmpty)
                              SListView(
                                value: _conflictConfigs!,
                                header: 'Conflict',
                                textBuilder: (o) => o.filename,
                                colorBuilder: (o) => o.isConflict
                                    ? colorScheme.warning(context)
                                    : colorScheme.text(context),
                                onPressed: (o) async {
                                  await context.push(
                                    '/setup/configuration/detail',
                                    extra: o,
                                  );
                                },
                              ),
                          ],
                        )
                      : const SText.titleMedium(
                          noConfigFoundString,
                          softWrap: true,
                          textAlign: TextAlign.center,
                        )
                : const SLoading(),
          ),
        );
      },
    );
  }
}
