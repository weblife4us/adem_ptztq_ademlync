import 'package:ademlync_device/ademlync_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:number_text_input_formatter/number_text_input_formatter.dart';

import '../app_delegate.dart';
import '../custom_color_scheme.dart';
import 's_icon.dart';
import 's_text.dart';

class STextFormField extends StatelessWidget {
  final String? initialValue;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final String? errorText;
  final bool isEnabled;
  final bool readOnly;
  final bool isEdited;
  final List<TextInputFormatter>? formatters;
  final int? maxLength;
  final EdgeInsetsGeometry? contentPadding;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final bool? obscureText;
  final VoidCallback? onObscurePressed;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;
  final int? maxLines;
  final VoidCallback? onEditingComplete;
  final VoidCallback? onFocusChanged;
  final VoidCallback? onPressed;
  final void Function(String)? onFieldSubmitted;
  final TextAlign textAlign;

  const STextFormField({
    super.key,
    this.initialValue,
    this.controller,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.errorText,
    this.isEnabled = true,
    this.readOnly = false,
    this.isEdited = false,
    this.obscureText,
    this.formatters,
    this.maxLength,
    this.suffixIcon,
    this.contentPadding,
    this.keyboardType,
    this.onChanged,
    this.textInputAction,
    this.validator,
    this.autofillHints,
    this.maxLines,
    this.onEditingComplete,
    this.onObscurePressed,
    this.onFocusChanged,
    this.onPressed,
    this.onFieldSubmitted,
    this.textAlign = TextAlign.start,
  });

  factory STextFormField.digit({
    Param? param,
    TextEditingController? controller,
    num? initialValue,
    AdemParamLimit? limit,
    int decimal = 0,
    TextInputAction? textInputAction,
    final Widget? suffixIcon,
    String? Function(String?)? customValidator,
    void Function(num?)? onChanged,
    void Function()? onEditingComplete,
    bool isEdited = false,
    bool isEnabled = true,
    bool isError = false,
    bool isAutoValidate = true,
  }) {
    try {
      final adem = AppDelegate().adem;
      limit ??= param?.limit(adem);
      decimal = param?.decimal(adem) ?? 0;
    } catch (e) {
      // AdEM not ready.
    }

    final rangeStr = limit != null
        ? '${limit.min.toStringAsFixed(decimal)} ~ ${limit.max.toStringAsFixed(decimal)}'
        : null;

    String? err;
    if (isAutoValidate && controller?.text != null) {
      final val = num.tryParse(controller!.text);
      if (val == null) {
        err = 'Required';
      } else if (limit != null && !limit.isValid(val)) {
        err = rangeStr;
      }
      err = customValidator != null ? customValidator(err) : err;
    }

    return STextFormField(
      initialValue: initialValue?.toStringAsFixed(decimal),
      controller: controller,
      isEdited: isEdited,
      isEnabled: isEnabled,
      textInputAction: textInputAction,
      errorText: err ?? (isError ? rangeStr : null),
      // hintText: rangeStr,
      suffixIcon: suffixIcon,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      formatters: [
        NumberTextInputFormatter(
          integerDigits: initialValue
              ?.toStringAsFixed(decimal)
              .split('.')[0]
              .length,
          decimalDigits: decimal,
          allowNegative: true,
          insertDecimalPoint: true,
          insertDecimalDigits: true,
          fixNumber: true,
          overrideDecimalPoint: true,
        ),
      ],
      validator: (value) {
        String? err;
        final val = value != null ? num.tryParse(value) : null;
        if (val == null) {
          err = 'Required';
        } else if (limit != null && !limit.isValid(val)) {
          err = 'Out of Range';
        }

        return customValidator != null ? customValidator(err) : err;
      },
      onChanged: (value) {
        if (onChanged != null) {
          final val = num.tryParse(value);
          onChanged(val);
        }
      },
      onEditingComplete: onEditingComplete,
      textAlign: TextAlign.right,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = errorText != null
        ? colorScheme.warning(context)
        : (isEdited ? colorScheme.black : colorScheme.text(context)).withValues(
            alpha: isEnabled ? 1.0 : 0.4,
          );

    return GestureDetector(
      onTap: onPressed,
      child: TextFormField(
        initialValue: initialValue,
        controller: controller,
        autocorrect: false,
        focusNode: focusNode,
        enabled: isEnabled,
        readOnly: readOnly,
        inputFormatters: formatters,
        textAlign: textAlign,
        keyboardType: keyboardType,
        maxLength: maxLength,
        cursorHeight: 12.0,
        cursorWidth: 2.0,
        cursorColor: colorScheme.text(context),
        textInputAction: textInputAction,
        obscureText: obscureText ?? false,
        style: STextStyle.titleMedium.style.copyWith(color: textColor),
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          errorText: errorText,
          counterText: '',
          fillColor: isEdited
              ? colorScheme.accentGold(context)
              : Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10.5,
            horizontal: 12.0,
          ),
          labelStyle: STextStyle.titleMedium.style,
          suffixIcon:
              suffixIcon ??
              (obscureText != null && onObscurePressed != null
                  ? Focus(
                      canRequestFocus: false,
                      descendantsAreFocusable: false,
                      child: IconButton(
                        visualDensity: VisualDensity.standard,
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        icon: SIcon(
                          obscureText!
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 12.0,
                        ),
                        onPressed: onObscurePressed,
                      ),
                    )
                  : null),
          suffixIconConstraints: suffixIcon != null
              ? const BoxConstraints(maxHeight: 40.0)
              : BoxConstraints.tight(const Size.square(32.0)),
          errorMaxLines: 2,
        ),
        validator: validator,
        autofillHints: autofillHints,
        maxLines: maxLines ?? 1,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        onFieldSubmitted: onFieldSubmitted,
      ),
    );
  }
}
