import 'package:flutter/material.dart';

class MyCustomButton extends StatelessWidget {
  final VoidCallback onPress;
  final String text;
  const MyCustomButton({Key? key, required this.onPress, required this.text})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPress,
      child: Text(text),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.blue),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(horizontal: 30, vertical: 18),
        ),
      ),
    );
  }
}
