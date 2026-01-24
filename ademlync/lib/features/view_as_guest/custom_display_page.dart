import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_delegate.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_style_text.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/smart_body_layout.dart';
import '../../utils/widgets/s_loading.dart';
import 'custom_display_page_bloc.dart';

class CustomDisplayPage extends StatefulWidget {
  const CustomDisplayPage({super.key});

  @override
  State<CustomDisplayPage> createState() => _CustomDisplayPageState();
}

class _CustomDisplayPageState extends State<CustomDisplayPage> {
  late final _bloc = BlocProvider.of<CustomDisplayPageBloc>(context);

  Map<Param, String>? _info;

  @override
  void initState() {
    super.initState();

    _bloc.add(FetchData());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _bloc,
      listener: _listener,
      child: Scaffold(
        appBar: SAppBar(
          text: locale.customDisplayString,
          hasAdemInfoAction: _info != null,
        ),
        body: SmartBodyLayout(
          child: _info != null
              ? SCard(
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (_, i) {
                      final o = _info!.entries.toList()[i];

                      return _Item(
                        title: o.key.displayName,
                        text: o.value,
                        unit: o.key.unit(AppDelegate().adem),
                      );
                    },
                    separatorBuilder: (_, _) => const Gap(24.0),
                    itemCount: _info!.length,
                  ),
                )
              : const SLoading(),
        ),
      ),
    );
  }

  void _listener(BuildContext context, Object? state) async {
    if (state is DataReady) {
      setState(() {
        _info = state.info;
      });
    } else if (state is FetchDataFailed) {
      await handleError(context, state.error);

      if (context.mounted && context.canPop()) context.pop();
    }
  }
}

class _Item extends StatelessWidget {
  final String title;
  final String text;
  final String? unit;

  const _Item({required this.title, required this.text, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: SText.bodyMedium(title)),
        const Gap(12.0),
        Expanded(
          child: SStyleText(
            text,
            textStyle: STextStyle.titleMedium.style,
            textAlign: TextAlign.end,
          ),
        ),
        if (unit != null) ...[
          const Gap(8.0),
          SStyleText(unit!, textColor: colorScheme.grey),
        ],
      ],
    );
  }
}
