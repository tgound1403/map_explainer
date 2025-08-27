import 'package:flutter/material.dart';

class ToggleButton extends StatelessWidget {
  const ToggleButton({super.key, required this.onPressed, required this.changeValue});
  final Function() onPressed;
  final bool changeValue;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        changeValue
            ? Icons.arrow_drop_down_rounded
            : Icons.arrow_drop_up_rounded,
        size: 32,
      ),
    );
  }
}
