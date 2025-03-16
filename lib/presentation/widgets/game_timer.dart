import 'package:flutter/material.dart';

class GameTimer extends StatelessWidget {
  final int minutes;
  final int seconds;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color digitColor;
  final Color borderColor;

  const GameTimer({
    Key? key,
    required this.minutes,
    required this.seconds,
    this.width = 120,
    this.height = 40,
    this.backgroundColor = Colors.black54,
    this.digitColor = Colors.green,
    this.borderColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = seconds.toString().padLeft(2, '0');

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDigit(minutesStr[0]),
          _buildDigit(minutesStr[1]),
          _buildSeparator(),
          _buildDigit(secondsStr[0]),
          _buildDigit(secondsStr[1]),
        ],
      ),
    );
  }

  Widget _buildDigit(String digit) {
    return Container(
      width: 20,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.grey.shade700,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          digit,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: digitColor,
          ),
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return SizedBox(
      width: 10,
      child: Center(
        child: Text(
          ':',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: digitColor,
          ),
        ),
      ),
    );
  }
}
