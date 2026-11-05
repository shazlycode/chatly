import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const new({
    super.key,

    required this.labelText,
    required this.iconData,
    required this.onChanged,
    required this.validate,
  });

  final String labelText;
  final IconData iconData;
  final Function(String) onChanged;
  final FormFieldValidator<String>? validate;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: "",
      validator: validate,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.labelMedium,
      decoration: InputDecoration(
        errorStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        suffixIcon: Icon(iconData, color: Colors.white),
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white),
        enabled: true,

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }
}
