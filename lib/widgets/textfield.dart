import 'package:flutter/material.dart';

class MyCustomTextField extends StatelessWidget {
  final String hint;
  final bool obscureText;
  final TextEditingController controller;
  MyCustomTextField({
    Key? key,
    required this.hint,
    required this.obscureText,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
