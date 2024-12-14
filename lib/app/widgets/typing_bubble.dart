// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';

class TypingBubble extends StatefulWidget {
  const TypingBubble({super.key});

  @override
  _TypingBubbleState createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<TypingBubble> {
  String typingText = "";
  late Timer _timer;
  int _dotCount = 0;

  @override
  void initState() {
    super.initState();
    _startTypingAnimation();
  }

  // Start the typing animation
  void _startTypingAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        // Cycle between 0, 1, 2, and 3 dots
        _dotCount = (_dotCount + 1) % 4;
        typingText = '.' * _dotCount; // Update the typing text with dots
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 150,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.grey[300], // Light gray for typing bubble
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 15,
                child: Icon(Icons.smart_toy_outlined, color: Colors.black),
              ),
              const SizedBox(width: 10),
              Text(
                "Typing$typingText", // Display typing text with animated dots
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
