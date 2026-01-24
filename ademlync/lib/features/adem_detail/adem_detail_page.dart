import 'dart:async';

import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../utils/app_delegate.dart';
import '../../utils/access_code_helper.dart';
import '../../utils/controllers/date_time_fmt_manager.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/adem_model_info.dart';
import '../../utils/widgets/date_time_picker_button.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_bottom_sheet_decoration.dart';
import '../../utils/widgets/s_button.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_data_field.dart';
import '../../utils/widgets/s_decoration.dart';
import '../../utils/widgets/smart_body_layout.dart';
import '../../utils/widgets/svg_image.dart';
import 'adem_detail_page_bloc.dart';

class AdemDetailPage extends StatefulWidget {
  const AdemDetailPage({super.key});

  @override
  State<AdemDetailPage> createState() => _AdemDetailPageState();
}

class _AdemDetailPageState extends State<AdemDetailPage> {
  late final _subBloc = BlocProvider.of<AdemDetailPageBloc>(context);

  Adem get _adem => AppDelegate().adem;
  CredentialUser? get _user => AppDelegate().user;
  bool get _hasWriteAccess => _user?.canWriteAdem ?? false;

  @override
  void initState() {
    super.initState();
    _subBloc.add(FetchEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _subBloc,
      listener: (_, state) {
        if (state is FetchedState) setState(() {});
      },
      child: Scaffold(
        appBar: const SAppBar(text: 'AdEM Detail'),
        body: SmartBodyLayout(
          child: Column(
            spacing: 24.0,
            mainAxisSize: MainAxisSize.min,
            children: [
              SCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AdemModelInfo(adem: _adem),
                    const Gap(24.0),
                    Row(
                      spacing: 24.0,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SDecoration(
                            header: 'S/N',
                            child: SDataField.string(value: _adem.serialNumber),
                          ),
                        ),
                        if (_adem.isSerialNumberPart2Supported)
                          Expanded(
                            child: InkWell(
                              onTap: _hasWriteAccess ? _changeSNPart2 : null,
                              child: Row(
                                spacing: 8.0,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: SDecoration(
                                      header: '2<u>nd</u> S/N',
                                      child: SDataField.string(
                                        value: _adem.serialNumberPart2,
                                      ),
                                    ),
                                  ),
                                  if (_hasWriteAccess)
                                    const SvgImage(
                                      'edit',
                                      width: 24.0,
                                      height: 24.0,
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Gap(24.0),
                    Row(
                      spacing: 24.0,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _hasWriteAccess ? _changeCustomerID : null,
                            child: Row(
                              spacing: 8.0,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SDecoration(
                                    header: 'Customer ID',
                                    child: SDataField.string(
                                      value: _adem.customerId.trim(),
                                    ),
                                  ),
                                ),
                                if (_hasWriteAccess)
                                  const SvgImage(
                                    'edit_user',
                                    width: 24.0,
                                    height: 24.0,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: _hasWriteAccess ? _changeDateTime : null,
                            child: Row(
                              spacing: 8.0,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SDecoration(
                                    header: 'Date Time',
                                    child: SDataField.string(
                                      value:
                                          '${DateTimeFmtManager.formatDate(_adem.dateTime)}\n${DateTimeFmtManager.formatTime(_adem.dateTime)}',
                                    ),
                                  ),
                                ),
                                if (_hasWriteAccess)
                                  const SvgImage(
                                    'edit',
                                    width: 24.0,
                                    height: 24.0,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(24.0),
                    InkWell(
                      onTap: _hasWriteAccess ? _changeSiteLocation : null,
                      child: Row(
                        spacing: 24.0,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SDecoration(
                              header: 'Site Name',
                              child: SDataField.string(
                                value: _adem.siteAddress,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              spacing: 8.0,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SDecoration(
                                    header: 'Address',
                                    child: SDataField.string(
                                      value: _adem.siteName,
                                    ),
                                  ),
                                ),
                                if (_hasWriteAccess)
                                  const SvgImage(
                                    'edit_map',
                                    width: 24.0,
                                    height: 24.0,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                spacing: 8.0,
                children: [
                  if (_user?.canChangeAdemAccessCode ?? false)
                    SButton.filled(
                      text: locale.changeAccessCodeString,
                      onPressed: _changeAccessCode,
                    ),
                  if ((_user?.canChangeAdemSuperAccessCode ?? false) &&
                      _adem.isSuperAccessCodeSupported)
                    SButton.filled(
                      text: locale.changeSuperAccessCodeString,
                      onPressed: _changeSuperAccessCode,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changeSNPart2() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      isDismissible: false,
      builder: (_) {
        return _ChangeSNPart2BottomSheet(
          type: AdemDetailConfigType.changeSerialNumberPart2,
          value: _adem.serialNumberPart2,
        );
      },
    );

    setState(() {});
  }

  Future<void> _changeCustomerID() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      isDismissible: false,
      builder: (_) {
        return _ChangeCustomerIdBottomSheet(
          type: AdemDetailConfigType.changeCustomerId,
          id: _adem.customerId,
        );
      },
    );

    setState(() {});
  }

  Future<void> _changeDateTime() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      isDismissible: false,
      builder: (_) {
        return _ChangeDateTimeBottomSheet(
          type: AdemDetailConfigType.changeDateTime,
          date: _adem.date,
          time: _adem.time,
        );
      },
    );

    setState(() {});
  }

  Future<void> _changeSiteLocation() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      isDismissible: false,
      builder: (_) {
        return _ChangeSiteLocationBottomSheet(
          type: AdemDetailConfigType.changeSiteLocation,
          siteName: _adem.siteName,
          siteAddress: _adem.siteAddress,
        );
      },
    );

    setState(() {});
  }

  Future<void> _changeAccessCode() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      isDismissible: false,
      builder: (_) {
        return const _ChangeAccessCodeBottomSheet(
          type: AdemDetailConfigType.changeAccessCode,
        );
      },
    );

    setState(() {});
  }

  Future<void> _changeSuperAccessCode() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      isDismissible: false,
      builder: (_) {
        return const _ChangeSuperAccessCodeBottomSheet(
          type: AdemDetailConfigType.changeSuperAccessCode,
        );
      },
    );

    setState(() {});
  }
}

enum AdemDetailConfigType {
  changeSerialNumber,
  changeSerialNumberPart2,
  changeAccessCode,
  changeSuperAccessCode,
  resetSuperAccessCode,
  changeSiteLocation,
  changeCustomerId,
  changeDateTime;

  int get maxChar => switch (this) {
    AdemDetailConfigType.changeSerialNumber ||
    AdemDetailConfigType.changeSerialNumberPart2 => 8,
    AdemDetailConfigType.changeAccessCode ||
    AdemDetailConfigType.changeSuperAccessCode ||
    AdemDetailConfigType.resetSuperAccessCode => 5,
    AdemDetailConfigType.changeSiteLocation ||
    AdemDetailConfigType.changeCustomerId => 16,
    AdemDetailConfigType.changeDateTime => 0,
  };

  String get title => switch (this) {
    AdemDetailConfigType.changeSerialNumber => 'Change Serial Number',
    AdemDetailConfigType.changeSerialNumberPart2 =>
      'Change Serial Number Part 2',
    AdemDetailConfigType.changeAccessCode => 'Change Access Code',
    AdemDetailConfigType.changeSuperAccessCode => 'Change Super Access Code',
    AdemDetailConfigType.resetSuperAccessCode => 'Reset Super Code',
    AdemDetailConfigType.changeSiteLocation => 'Change Site Location',
    AdemDetailConfigType.changeCustomerId => 'Change Customer ID',
    AdemDetailConfigType.changeDateTime => 'Change AdEM Date Time',
  };

  String? get description => switch (this) {
    AdemDetailConfigType.changeSerialNumber ||
    AdemDetailConfigType.changeSerialNumberPart2 ||
    AdemDetailConfigType.changeSiteLocation ||
    AdemDetailConfigType.changeCustomerId =>
      'Your input exceeds the maximum limit of $maxChar characters.',
    AdemDetailConfigType.changeDateTime => null,
    AdemDetailConfigType.changeAccessCode ||
    AdemDetailConfigType.changeSuperAccessCode ||
    AdemDetailConfigType.resetSuperAccessCode =>
      'Your input must be at least $maxChar characters long',
  };
}

// MARK: Serial number part 2

class _ChangeSNPart2BottomSheet extends StatefulWidget {
  final AdemDetailConfigType type;
  final String? value;

  const _ChangeSNPart2BottomSheet({required this.type, required this.value});

  @override
  State<_ChangeSNPart2BottomSheet> createState() =>
      _ChangeSNPart2BottomSheetState();
}

class _ChangeSNPart2BottomSheetState extends State<_ChangeSNPart2BottomSheet>
    with AccessCodeHelper {
  final _bloc = AdemDetailPageBloc();

  late final _controller = TextEditingController(text: widget.value?.trim());
  late final _type = widget.type;

  @override
  void dispose() {
    _bloc.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: (_, state) async {
        if (state is ChangedState) {
          Navigator.pop(context);
        } else if (state is FailureState &&
            state.event is ChangeCustomerIdEvent) {
          await handleError(context, state.error);
        }
      },
      builder: (_, state) {
        return GestureDetector(
          onTap: FocusManager.instance.primaryFocus?.unfocus,
          child: SBottomSheetDecoration(
            header: _type.title,
            text: _type.description,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SDataField.stringEdit(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.done,
                  isEnabled: state is! ChangingState,
                  keyboardType: TextInputType.number,
                  formatters: [
                    LengthLimitingTextInputFormatter(_type.maxChar),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: _isValid() ? (_) => _submit() : null,
                ),
                const Gap(24.0),
                Row(
                  children: [
                    Expanded(
                      child: SButton.outlined(
                        text: 'Close',
                        onPressed: state is ChangingState
                            ? null
                            : () => Navigator.pop(context),
                      ),
                    ),
                    const Gap(12.0),
                    Expanded(
                      child: SButton.filled(
                        text: 'Confirm',
                        isLoading: state is ChangingState,
                        onPressed: state is ChangingState ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isValid() {
    return _controller.text.isNotEmpty;
  }

  Future<void> _submit() async {
    final accessCode = await getAccessCode(context);
    if (accessCode == null) return;

    FocusManager.instance.primaryFocus?.unfocus();

    _bloc.add(ChangeSNPart2Event(_controller.text, accessCode));
  }
}

// MARK: Custom ID

class _ChangeCustomerIdBottomSheet extends StatefulWidget {
  final AdemDetailConfigType type;
  final String id;

  const _ChangeCustomerIdBottomSheet({required this.type, required this.id});

  @override
  State<_ChangeCustomerIdBottomSheet> createState() =>
      _ChangeCustomerIdBottomSheetState();
}

class _ChangeCustomerIdBottomSheetState
    extends State<_ChangeCustomerIdBottomSheet>
    with AccessCodeHelper {
  final _bloc = AdemDetailPageBloc();

  late final _idTEC = TextEditingController(text: widget.id.trim());
  late final _type = widget.type;

  @override
  void dispose() {
    _bloc.close();
    _idTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: (_, state) async {
        if (state is ChangedState) {
          Navigator.pop(context);
        } else if (state is FailureState &&
            state.event is ChangeCustomerIdEvent) {
          await handleError(context, state.error);
        }
      },
      builder: (_, state) {
        return GestureDetector(
          onTap: FocusManager.instance.primaryFocus?.unfocus,
          child: SBottomSheetDecoration(
            header: _type.title,
            text: _type.description,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SDataField.stringEdit(
                  controller: _idTEC,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.done,
                  isEnabled: state is! ChangingState,
                  formatters: [LengthLimitingTextInputFormatter(_type.maxChar)],
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: _isValid() ? (_) => _submit() : null,
                ),
                const Gap(24.0),
                Row(
                  children: [
                    Expanded(
                      child: SButton.outlined(
                        text: 'Close',
                        onPressed: state is ChangingState
                            ? null
                            : () => Navigator.pop(context),
                      ),
                    ),
                    const Gap(12.0),
                    Expanded(
                      child: SButton.filled(
                        text: 'Confirm',
                        isLoading: state is ChangingState,
                        onPressed: state is ChangingState ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isValid() {
    return _idTEC.text.isNotEmpty;
  }

  Future<void> _submit() async {
    final accessCode = await getAccessCode(context);
    if (accessCode == null) return;

    FocusManager.instance.primaryFocus?.unfocus();

    _bloc.add(ChangeCustomerIdEvent(_idTEC.text, accessCode));
  }
}

// MARK: Location

class _ChangeSiteLocationBottomSheet extends StatefulWidget {
  final AdemDetailConfigType type;
  final String siteName;
  final String siteAddress;

  const _ChangeSiteLocationBottomSheet({
    required this.type,
    required this.siteName,
    required this.siteAddress,
  });

  @override
  State<_ChangeSiteLocationBottomSheet> createState() =>
      _ChangeSiteLocationBottomSheetState();
}

class _ChangeSiteLocationBottomSheetState
    extends State<_ChangeSiteLocationBottomSheet>
    with AccessCodeHelper {
  final _bloc = AdemDetailPageBloc();

  late final _siteNameTEC = TextEditingController(text: widget.siteName.trim());
  late final _siteAddressTEC = TextEditingController(
    text: widget.siteAddress.trim(),
  );
  late final _type = widget.type;

  @override
  void dispose() {
    _bloc.close();
    _siteNameTEC.dispose();
    _siteAddressTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: (_, state) async {
        if (state is ChangedState) {
          Navigator.pop(context);
        } else if (state is FailureState &&
            state.event is ChangeSiteLocationEvent) {
          await handleError(context, state.error);
        }
      },
      builder: (_, state) {
        return GestureDetector(
          onTap: FocusManager.instance.primaryFocus?.unfocus,
          child: SBottomSheetDecoration(
            header: _type.title,
            text: _type.description,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SDataField.stringEdit(
                  controller: _siteNameTEC,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
                  isEnabled: state is! ChangingState,
                  formatters: [LengthLimitingTextInputFormatter(_type.maxChar)],
                  keyboardType: TextInputType.streetAddress,
                  onChanged: (_) => setState(() {}),
                ),
                const Gap(24.0),
                SDataField.stringEdit(
                  controller: _siteAddressTEC,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.done,
                  isEnabled: state is! ChangingState,
                  formatters: [LengthLimitingTextInputFormatter(_type.maxChar)],
                  keyboardType: TextInputType.streetAddress,
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: _isValid() ? (_) => _submit() : null,
                ),
                const Gap(24.0),
                Row(
                  children: [
                    Expanded(
                      child: SButton.outlined(
                        text: 'Close',
                        onPressed: state is ChangingState
                            ? null
                            : () => Navigator.pop(context),
                      ),
                    ),
                    const Gap(12.0),
                    Expanded(
                      child: SButton.filled(
                        text: 'Confirm',
                        isLoading: state is ChangingState,
                        onPressed: state is ChangingState ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isValid() {
    return _siteNameTEC.text.isNotEmpty && _siteAddressTEC.text.isNotEmpty;
  }

  Future<void> _submit() async {
    final accessCode = await getAccessCode(context);
    if (accessCode == null) return;

    FocusManager.instance.primaryFocus?.unfocus();

    _bloc.add(
      ChangeSiteLocationEvent(
        _siteNameTEC.text,
        _siteAddressTEC.text,
        accessCode,
      ),
    );
  }
}

// MARK: Access code

class _ChangeAccessCodeBottomSheet extends StatefulWidget {
  final AdemDetailConfigType type;

  const _ChangeAccessCodeBottomSheet({required this.type});

  @override
  State<_ChangeAccessCodeBottomSheet> createState() =>
      _ChangeAccessCodeBottomSheetState();
}

class _ChangeAccessCodeBottomSheetState
    extends State<_ChangeAccessCodeBottomSheet>
    with AccessCodeHelper {
  final _bloc = AdemDetailPageBloc();

  late final _codeTEC = TextEditingController();
  late final _confirmTEC = TextEditingController();
  late final _type = widget.type;

  @override
  void dispose() {
    _bloc.close();
    _codeTEC.dispose();
    _confirmTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: (_, state) async {
        if (state is ChangedState) {
          Navigator.pop(context);
        } else if (state is FailureState &&
            state.event is ChangeAccessCodeEvent) {
          await handleError(context, state.error);
        }
      },
      builder: (_, state) {
        return GestureDetector(
          onTap: FocusManager.instance.primaryFocus?.unfocus,
          child: SBottomSheetDecoration(
            header: _type.title,
            text: _type.description,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SDataField.stringEdit(
                  controller: _codeTEC,
                  hintText: 'Access Code',
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  isEnabled: state is! ChangingState,
                  formatters: [
                    LengthLimitingTextInputFormatter(_type.maxChar),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (_) => setState(() {}),
                ),
                const Gap(24.0),
                SDataField.stringEdit(
                  controller: _confirmTEC,
                  hintText: 'Re-enter',
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  isEnabled: state is! ChangingState,
                  formatters: [
                    LengthLimitingTextInputFormatter(_type.maxChar),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: _isValid() ? (_) => _submit() : null,
                ),
                const Gap(24.0),
                Row(
                  children: [
                    Expanded(
                      child: SButton.outlined(
                        text: 'Close',
                        onPressed: state is ChangingState
                            ? null
                            : () => Navigator.pop(context),
                      ),
                    ),
                    const Gap(12.0),
                    Expanded(
                      child: SButton.filled(
                        text: 'Confirm',
                        isLoading: state is ChangingState,
                        onPressed: state is ChangingState ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isValid() {
    return _codeTEC.text.length == _type.maxChar &&
        _codeTEC.text == _confirmTEC.text;
  }

  Future<void> _submit() async {
    final accessCode = await getAccessCode(context);
    if (accessCode == null) return;

    FocusManager.instance.primaryFocus?.unfocus();

    _bloc.add(ChangeAccessCodeEvent(_codeTEC.text, accessCode));
  }
}

// MARK: Super access code

class _ChangeSuperAccessCodeBottomSheet extends StatefulWidget {
  final AdemDetailConfigType type;

  const _ChangeSuperAccessCodeBottomSheet({required this.type});

  @override
  State<_ChangeSuperAccessCodeBottomSheet> createState() =>
      _ChangeSuperAccessCodeBottomSheetState();
}

class _ChangeSuperAccessCodeBottomSheetState
    extends State<_ChangeSuperAccessCodeBottomSheet>
    with AccessCodeHelper {
  final _bloc = AdemDetailPageBloc();

  late final _codeTEC = TextEditingController();
  late final _confirmTEC = TextEditingController();
  late final _type = widget.type;

  @override
  void dispose() {
    _bloc.close();
    _codeTEC.dispose();
    _confirmTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: (_, state) async {
        if (state is ChangedState) {
          Navigator.pop(context);
        } else if (state is FailureState &&
            state.event is ChangeSuperAccessCodeEvent) {
          await handleError(context, state.error);
        }
      },
      builder: (_, state) {
        return GestureDetector(
          onTap: FocusManager.instance.primaryFocus?.unfocus,
          child: SBottomSheetDecoration(
            header: _type.title,
            text: _type.description,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SDataField.stringEdit(
                  controller: _codeTEC,
                  hintText: 'Super Access Code',
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
                  isEnabled: state is! ChangingState,
                  formatters: [LengthLimitingTextInputFormatter(_type.maxChar)],
                  onChanged: (_) => setState(() {}),
                ),
                const Gap(24.0),
                SDataField.stringEdit(
                  controller: _confirmTEC,
                  hintText: 'Re-enter',
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.done,
                  isEnabled: state is! ChangingState,
                  formatters: [LengthLimitingTextInputFormatter(_type.maxChar)],
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: _isValid() ? (_) => _submit() : null,
                ),
                const Gap(24.0),
                Row(
                  children: [
                    Expanded(
                      child: SButton.outlined(
                        text: 'Close',
                        onPressed: state is ChangingState
                            ? null
                            : () => Navigator.pop(context),
                      ),
                    ),
                    const Gap(12.0),
                    Expanded(
                      child: SButton.filled(
                        text: 'Confirm',
                        isLoading: state is ChangingState,
                        onPressed: state is ChangingState ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isValid() {
    return _codeTEC.text.length == _type.maxChar &&
        _codeTEC.text == _confirmTEC.text;
  }

  Future<void> _submit() async {
    final accessCode = await getAccessCode(context);
    if (accessCode == null) return;

    FocusManager.instance.primaryFocus?.unfocus();

    _bloc.add(ChangeSuperAccessCodeEvent(_codeTEC.text, accessCode));
  }
}

// MARK: Date time

class _ChangeDateTimeBottomSheet extends StatefulWidget {
  final AdemDetailConfigType type;
  final DateTime date;
  final DateTime time;

  const _ChangeDateTimeBottomSheet({
    required this.type,
    required this.date,
    required this.time,
  });

  @override
  State<_ChangeDateTimeBottomSheet> createState() =>
      _ChangeDateTimeBottomSheetState();
}

class _ChangeDateTimeBottomSheetState extends State<_ChangeDateTimeBottomSheet>
    with AccessCodeHelper {
  final _bloc = AdemDetailPageBloc();

  late final _type = widget.type;
  late DateTime _date = widget.date;
  late DateTime _time = widget.time;

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: (_, state) async {
        if (state is ChangedState) {
          Navigator.pop(context);
        } else if (state is FailureState &&
            state.event is ChangeDateTimeEvent) {
          await handleError(context, state.error);
        }
      },
      builder: (_, state) {
        return GestureDetector(
          onTap: FocusManager.instance.primaryFocus?.unfocus,
          child: SBottomSheetDecoration(
            header: _type.title,
            text: _type.description,
            child: Column(
              spacing: 24.0,
              mainAxisSize: MainAxisSize.min,
              children: [
                DateTimePickerButton.date(
                  context,
                  title: locale.adEMDateString,
                  value: _date,
                  enable: state is! AdemDetailPageDateTimeChangeInProgress,
                  onChanged: (v) {
                    setState(() => _date = v.asDateFmt);
                  },
                ),

                DateTimePickerButton.time(
                  context,
                  title: locale.adEMTimeString,
                  value: _time,
                  enable: state is! AdemDetailPageDateTimeChangeInProgress,
                  onChanged: (v) => setState(() => _time = v.asTimeFmt),
                ),

                SButton.filled(
                  text: 'Sync with Current Time Zone',
                  isLoading:
                      state is AdemDetailPageDateTimeChangeInProgress &&
                      state.isSync,
                  onPressed: state is AdemDetailPageDateTimeChangeInProgress
                      ? null
                      : () => _submit(isSync: true),
                ),

                Row(
                  children: [
                    Expanded(
                      child: SButton.outlined(
                        text: 'Close',
                        onPressed:
                            state is AdemDetailPageDateTimeChangeInProgress
                            ? null
                            : () => Navigator.pop(context),
                      ),
                    ),

                    const Gap(12.0),
                    Expanded(
                      child: SButton.filled(
                        text: 'Confirm',
                        isLoading:
                            state is AdemDetailPageDateTimeChangeInProgress &&
                            !state.isSync,
                        onPressed:
                            state is AdemDetailPageDateTimeChangeInProgress
                            ? null
                            : _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit({bool isSync = false}) async {
    final accessCode = await getAccessCode(context);
    if (accessCode == null) return;

    FocusManager.instance.primaryFocus?.unfocus();

    _bloc.add(
      isSync
          ? ChangeDateTimeEvent(accessCode)
          : ChangeDateTimeEvent(accessCode, ademDate: _date, ademTime: _time),
    );
  }
}

extension _DateTimeExt on DateTime {
  DateTime get asDateFmt => DateTime(year, month, day);
  DateTime get asTimeFmt => DateTime(year, month, day, hour, minute);
}
