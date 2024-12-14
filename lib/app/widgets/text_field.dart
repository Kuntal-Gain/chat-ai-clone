import 'package:flutter/material.dart';

Widget textFieldWidget(
    {required TextEditingController controller, required String label}) {
  return Container(
    height: 60,
    padding: const EdgeInsets.all(12),
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xffc2c2c2),
      ),
    ),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: label,
        border: InputBorder.none,
      ),
    ),
  );
}

Widget passwordFieldWidget(
    {required TextEditingController controller,
    required String label,
    required bool isHidden,
    required Function() onTap}) {
  return Container(
    height: 60,
    padding: const EdgeInsets.all(12),
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xffc2c2c2),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: isHidden,
            decoration: InputDecoration(
              hintText: label,
              border: InputBorder.none,
            ),
          ),
        ),
        IconButton(
          onPressed: onTap,
          icon: Icon(
            !isHidden ? Icons.visibility : Icons.visibility_off,
          ),
        )
      ],
    ),
  );
}
