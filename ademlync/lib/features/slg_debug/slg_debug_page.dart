import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_loading.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/s_decoration.dart';
import '../../utils/widgets/s_pop_scope.dart';
import '../../utils/widgets/smart_body_layout.dart';
import 'slg_debug_page_bloc.dart';

class SLGDebugPage extends StatefulWidget {
  const SLGDebugPage({super.key});

  @override
  State<SLGDebugPage> createState() => _SLGDebugPageState();
}

class _SLGDebugPageState extends State<SLGDebugPage> {
  late final _bloc = BlocProvider.of<SLGDebugBloc>(context);

  SLGData? _data;
  int _fetchCount = 0;
  bool _hasError = false;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _bloc.add(StartReading());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: _listener,
      builder: (_, state) {
        final isLoading = state is SLGDataFetching;

        return SPopScope(
          isCommunicating: _bloc.isCommunicating,
          cancelCommunication: () => _bloc.cancelCommunication(),
          child: Scaffold(
            appBar: const SAppBar(text: 'SLG47011 Debug'),
            body: SmartBodyLayout(
              child: isLoading && _data == null
                  ? const SLoading()
                  : _data != null
                      ? _buildContent()
                      : _hasError
                          ? Center(child: SText.bodyMedium(_errorMsg))
                          : const SLoading(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with fetch count
          SCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SText.titleLarge('SLG47011 Real-Time Data'),
                const Gap(4.0),
                SText.bodySmall('Read count: $_fetchCount'),
              ],
            ),
          ),
          const Gap(16.0),

          // DataBuffer0 - PTZ Absolute Pressure
          _buildBufferCard(
            'DataBuffer0 (PTZ Absolute Pressure)',
            _data!.buffer0Raw,
            _data!.buffer0_14bit,
            _data!.buffer0_12bit,
          ),
          const Gap(16.0),

          // DataBuffer1 - TQ Differential Pressure
          _buildBufferCard(
            'DataBuffer1 (TQ Differential Pressure)',
            _data!.buffer1Raw,
            _data!.buffer1_14bit,
            _data!.buffer1_12bit,
          ),
          const Gap(16.0),

          // ADC Direct
          _buildBufferCard(
            'ADC Direct Value',
            _data!.adcRaw,
            _data!.adc_14bit,
            _data!.adc_12bit,
          ),
        ],
      ),
    );
  }

  Widget _buildBufferCard(
    String title,
    int raw16,
    int val14,
    int val12,
  ) {
    return SCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SText.titleMedium(title),
          const Gap(12.0),
          Row(
            children: [
              Expanded(
                child: SDecoration(
                  header: 'Raw 16-bit',
                  child: SText.titleMedium(raw16.toString()),
                ),
              ),
              const Gap(16.0),
              Expanded(
                child: SDecoration(
                  header: 'Hex',
                  child: SText.titleMedium(
                    '0x${raw16.toRadixString(16).toUpperCase().padLeft(4, '0')}',
                  ),
                ),
              ),
            ],
          ),
          const Gap(12.0),
          Row(
            children: [
              Expanded(
                child: SDecoration(
                  header: '14-bit (0-16383)',
                  child: SText.titleMedium(val14.toString()),
                ),
              ),
              const Gap(16.0),
              Expanded(
                child: SDecoration(
                  header: '12-bit (0-4095)',
                  child: SText.titleMedium(val12.toString()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _listener(BuildContext context, Object? state) {
    if (state is SLGDataFetched) {
      setState(() {
        _data = state.data;
        _fetchCount = state.fetchCount;
        _hasError = false;
      });
    } else if (state is SLGDataError) {
      setState(() {
        _hasError = true;
        _errorMsg = 'Error: ${state.error}';
      });
    }
  }
}
