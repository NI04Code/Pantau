import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
class CustomOverflowText extends StatefulWidget {
  final String text;
  final int maxLines;
  final String overflowSymbol;
  final String readMoreText;

  CustomOverflowText({
    required this.text,
    this.maxLines = 1,
    this.overflowSymbol = '...',
    this.readMoreText = 'Baca Selengkapnya',
  });

  @override
  _CustomOverflowTextState createState() => _CustomOverflowTextState();
}

class _CustomOverflowTextState extends State<CustomOverflowText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final textSpan = TextSpan(
      text: widget.text,
      style: TextStyle(fontSize: 16, color: Colors.black),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: widget.maxLines,
    );

    textPainter.layout(maxWidth: double.infinity);

    if (textPainter.didExceedMaxLines && !isExpanded) {
      final truncatedSpan = TextSpan(
        text: widget.overflowSymbol,
        style: TextStyle(fontSize: 16, color: Colors.black),
      );

      final readMoreSpan = TextSpan(
        text: ' ' + widget.readMoreText,
        style: TextStyle(
          fontSize: 16,
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()..onTap = expandText,
      );

      return RichText(
        maxLines: widget.maxLines,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: [textSpan, truncatedSpan, readMoreSpan],
        ),
      );
    } else {
      return RichText(
        text: textSpan,
      );
    }
  }

  void expandText() {
    setState(() {
      isExpanded = true;
    });
  }
}
