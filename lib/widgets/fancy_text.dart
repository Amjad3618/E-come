import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? textColor;
  final TextAlign textAlign;
  final bool isGradient;
  final Color? gradientColorStart;
  final Color? gradientColorEnd;
  final bool hasShadow;
  final TextOverflow? overflow;
  final int? maxLines;
  final double? letterSpacing;
  final TextDecoration? decoration;

  const CustomText({
    Key? key,
    required this.text,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.normal,
    this.textColor = Colors.black,
    this.textAlign = TextAlign.left,
    this.isGradient = false,
    this.gradientColorStart = const Color(0xFF6A5AE0),
    this.gradientColorEnd = const Color(0xFF9087E5),
    this.hasShadow = false,
    this.overflow,
    this.maxLines,
    this.letterSpacing,
    this.decoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: isGradient ? null : textColor,
      shadows: hasShadow ? [
        Shadow(
          color: Colors.black.withOpacity(0.2),
          offset: const Offset(1, 1),
          blurRadius: 3,
        ),
      ] : null,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );

    if (isGradient) {
      return ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: [
              gradientColorStart!,
              gradientColorEnd!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: Text(
          text,
          style: textStyle,
          textAlign: textAlign,
          overflow: overflow,
          maxLines: maxLines,
        ),
      );
    }

    return Text(
      text,
      style: textStyle,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}

