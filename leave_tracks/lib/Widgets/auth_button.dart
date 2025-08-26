import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isGoogle;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isGoogle = false,
  });
#for the faking of the golden age
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: isGoogle ? Colors.white : Theme.of(context).primaryColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isGoogle) ...[
            Image.asset('assets/google_logo.png', height: 24), // Add Google logo asset
            const SizedBox(width: 10),
          ],
          Text(
            text,
            style: TextStyle(
              color: isGoogle ? Colors.black : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}