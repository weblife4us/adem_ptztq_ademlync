import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_delegate.dart';
import '../constants.dart';
import '../controllers/date_time_fmt_manager.dart';
import '../custom_color_scheme.dart';
import 's_checkbox.dart';
import 's_dropdown.dart';
import 's_style_text.dart';
import 's_text.dart';
import 's_text_form_field.dart';

class SDataField<T> extends StatelessWidget {
  final String? title;
  final String? footer;
  final Param? param;
  final String? unit;
  final bool isSealed;
  late final Widget Function(String? unit) child;

  SDataField.string({
    super.key,
    this.title,
    this.param,
    this.footer,
    this.unit,
    required String? value,
    String? prefix,
  }) : isSealed = false {
    const fallback = noDataString;

    // Set value to fallback if the value is null
    value ??= fallback;

    // Hidden unit when the value is fallback
    child = (unit) => _WithUnitLayout.string(
      prefix: prefix,
      text: value!,
      suffix: value != fallback ? unit : null,
    );
  }

  SDataField.digit({
    super.key,
    this.title,
    this.param,
    this.footer,
    this.unit,
    required num? value,
    int? decimal,
    String? prefix,
  }) : isSealed = false {
    const fallback = noDataString;
    decimal ??= param?.decimal(AppDelegate().adem);

    // Set text to fallback if the value is null
    final text = value?.toStringAsFixed(decimal ?? 0) ?? fallback;

    // Hidden unit when the value is fallback
    child = (unit) => _WithUnitLayout.string(
      prefix: prefix,
      text: text,
      suffix: text != fallback ? unit : null,
    );
  }

  SDataField.alarm({
    super.key,
    this.title,
    this.param,
    this.footer,
    this.unit,
    required bool value,
  }) : isSealed = false {
    child = (unit) => _WithUnitLayout.string(
      text: value ? locale.yesString : locale.noString,
      suffix: unit,
    );
  }

  SDataField.date({
    super.key,
    this.title,
    this.footer,
    this.param,
    this.unit,
    DateTime? value,
  }) : isSealed = false {
    child = (_) => SText.titleMedium(
      value != null ? DateTimeFmtManager.formatDate(value) : noDataString,
      textAlign: TextAlign.right,
      softWrap: true,
    );
  }

  SDataField.time({
    super.key,
    this.title,
    this.footer,
    this.param,
    this.unit,
    DateTime? value,
  }) : isSealed = false {
    child = (_) => SText.titleMedium(
      value != null ? DateTimeFmtManager.formatTime(value) : noDataString,
      textAlign: TextAlign.right,
      softWrap: true,
    );
  }

  SDataField.dateTime({
    super.key,
    this.title,
    this.footer,
    this.param,
    this.unit,
    DateTime? value,
  }) : isSealed = false {
    child = (_) => SText.titleMedium(
      value != null ? DateTimeFmtManager.formatDateTime(value) : noDataString,
      textAlign: TextAlign.right,
      softWrap: true,
    );
  }

  SDataField.digitEdit({
    super.key,
    this.title,
    this.footer,
    this.param,
    this.unit,
    this.isSealed = false,
    TextEditingController? controller,
    num? initialValue,
    AdemParamLimit? limit,
    TextInputAction? textInputAction,
    String? Function(String?)? customValidator,
    void Function(num?)? onChanged,
    void Function()? onEditingComplete,
    bool isEdited = false,
    bool isEnabled = true,
    bool isError = false,
    bool isAutoValidate = true,
    int decimal = 0,
  }) {
    if (isSealed) {
      const fallback = noDataString;

      // Set value to fallback if the value is null
      late String text = controller != null && controller.text.isNotEmpty
          ? controller.text
          : initialValue != null
          ? initialValue.toString()
          : fallback;

      // Hidden unit when the value is fallback
      child = (unit) => _WithUnitLayout.string(
        text: text,
        suffix: text != fallback ? unit : null,
      );
    } else {
      child = (unit) => STextFormField.digit(
        param: param,
        controller: controller,
        initialValue: initialValue,
        limit: limit,
        textInputAction: textInputAction,
        customValidator: customValidator,
        decimal: decimal,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        isEdited: isEdited && (controller?.text.isNotEmpty ?? false),
        isEnabled: isEnabled && !isSealed,
        isError: isError,
        suffixIcon: unit != null
            ? Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 24.0),
                child: SStyleText(
                  unit,
                  textColor: colorScheme.grey,
                  textStyle: STextStyle.bodyMedium.style,
                  tagTextStyle: STextStyle.titleMedium.style,
                ),
              )
            : null,
        isAutoValidate: isAutoValidate,
      );
    }
  }

  SDataField.stringEdit({
    super.key,
    this.title,
    this.footer,
    this.param,
    this.unit,
    this.isSealed = false,
    bool isError = false,
    String? errorText,
    String? initialValue,
    TextEditingController? controller,
    FocusNode? focusNode,
    bool isEdited = false,
    bool isEnabled = true,
    String? hintText,
    TextInputType? keyboardType,
    int? maxLength,
    List<TextInputFormatter>? formatters,
    TextInputAction? textInputAction,
    TextAlign textAlign = TextAlign.right,
    int? maxLines,
    void Function()? onEditingComplete,
    required void Function(String)? onChanged,
    void Function(String)? onFieldSubmitted,
  }) {
    child = (_) => STextFormField(
      initialValue: initialValue,
      controller: controller,
      focusNode: focusNode,
      isEdited: isEdited,
      errorText: errorText,
      hintText: hintText,
      isEnabled: isEnabled && !isSealed,
      maxLength: maxLength,
      keyboardType: keyboardType,
      formatters: formatters,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }

  SDataField.dropdown({
    super.key,
    this.title,
    this.footer,
    this.param,
    this.unit,
    this.isSealed = false,
    required T value,
    required List<T> list,
    required bool isEdited,
    bool softWrap = false,
    TextOverflow? overflow,
    int? index,
    bool isDisable = false,
    String Function(T)? stringBuilder,
    required void Function(T?) onChanged,
  }) {
    child = (_) => SDropdownButton<T>(
      value: value,
      items: list,
      index: index,
      isEdited: isEdited,
      isDisable: isDisable || isSealed,
      softWrap: softWrap,
      overflow: overflow,
      stringBuilder: stringBuilder,
      onChanged: onChanged,
    );
  }

  SDataField.reset({
    super.key,
    this.title,
    this.footer,
    this.param,
    this.unit,
    this.isSealed = false,
    required num value,
    required bool isActive,
    bool isDisable = false,
    required void Function(bool) onChanged,
  }) {
    child = (unit) => Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _WithUnitLayout.string(
          text: value.toStringAsFixed(param?.decimal(AppDelegate().adem) ?? 0),
          suffix: unit,
        ),
        SCheckbox(
          text: locale.resetString,
          isActive: isActive,
          isDisabled: isDisable || isSealed,
          onPressed: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _Layout(
      title: title ?? param?.displayName,
      footer: footer,
      isSealed:
          isSealed &&
          (param == null || AppDelegate().adem.checkProtectedBySeal(param!)),
      child: child(unit ?? param?.unit(AppDelegate().adem)),
    );
  }
}

class _Layout extends StatelessWidget {
  final String? title;
  final String? footer;
  final bool isSealed;
  final Widget child;

  const _Layout({
    required this.title,
    required this.footer,
    required this.isSealed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        Column(
          children:
              [
                    if (isSealed)
                      SText.bodySmall(
                        locale.protectedBySealDescription,
                        color: colorScheme.grey,
                        softWrap: true,
                      ),
                    if (footer != null)
                      SText.bodySmall(
                        footer!,
                        color: colorScheme.grey,
                        softWrap: true,
                      ),
                  ]
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: e,
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}

class _WithUnitLayout extends StatelessWidget {
  final String? prefix;
  final String? suffix;
  final Widget child;

  const _WithUnitLayout({
    required this.prefix,
    required this.suffix,
    required this.child,
  });

  _WithUnitLayout.string({this.prefix, this.suffix, required String text})
    : child = SStyleText(
        text,
        textAlign: TextAlign.left,
        softWrap: true,
        textStyle: STextStyle.titleMedium.style,
      );

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      children: [
        if (prefix != null) SText.bodySmall('$prefix — '),
        Wrap(
          alignment: WrapAlignment.end,
          children: [
            child,
            if (suffix != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SStyleText(
                  suffix!,
                  textColor: colorScheme.grey,
                  textStyle: STextStyle.bodyMedium.style,
                  tagTextStyle: STextStyle.titleMedium.style,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
