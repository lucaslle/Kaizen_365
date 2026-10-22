import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_palette.dart';
import '../app_text.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.onChanged,
    this.initialValue = '',
    this.hint,
    this.lines = 1,
    this.style,
    this.fill,
    this.radius = 16,
    this.verticalPadding = 14,
    this.keyboardType,
    this.inputFormatters,
    this.onSubmitted,
    this.autofillHints,
    this.textAlign = TextAlign.start,
    this.hasBorder = true,
  });

  final String label;
  final ValueChanged<String> onChanged;
  final String initialValue;
  final String? hint;
  final int lines;
  final TextStyle? style;
  final Color? fill;
  final double radius;
  final double verticalPadding;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;
  final TextAlign textAlign;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: hasBorder ? BorderSide(color: color, width: 1.5) : BorderSide.none,
    );
    final textStyle = style ?? context.text.sans(16);
    return Semantics(
      label: label,
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        minLines: lines,
        maxLines: lines,
        style: textStyle,
        textAlign: textAlign,
        keyboardType: keyboardType ?? (lines > 1 ? TextInputType.multiline : TextInputType.text),
        inputFormatters: inputFormatters,
        autofillHints: autofillHints,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: textStyle.copyWith(color: context.palette.muted),
          filled: true,
          fillColor: fill ?? context.palette.surface,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: verticalPadding),
          enabledBorder: border(context.palette.inputBorder),
          focusedBorder: border(context.palette.accent),
        ),
      ),
    );
  }
}
