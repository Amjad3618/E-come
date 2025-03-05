import 'package:flutter/material.dart';

class CircularImageButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;
  final double size;

  const CircularImageButton({
    Key? key,
    required this.imagePath,
    required this.onPressed,
    this.size = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage(imagePath),
            
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}