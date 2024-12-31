import 'package:flutter/material.dart';

class FormattedMessage extends StatelessWidget {
  final String text;
  final Color textColor;
  final double fontSize;

  const FormattedMessage({
    Key? key,
    required this.text,
    required this.textColor,
    this.fontSize = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: _buildFormattedText(text),
    );
  }

  TextSpan _buildFormattedText(String text) {
    List<TextSpan> spans = [];
    RegExp boldStarsPattern = RegExp(r'\*\*(.*?)\*\*');
    RegExp italicStarsPattern = RegExp(r'\*(.*?)\*');
    RegExp bulletPattern = RegExp(r'^\s*-\s*', multiLine: true);
    RegExp numberPattern = RegExp(r'^\s*\d+\.\s*', multiLine: true);

    // Split the text by newlines to handle lists properly
    List<String> lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];

      // Check if the line is a bullet point or numbered list
      if (bulletPattern.hasMatch(line)) {
        line = line.replaceFirst(bulletPattern, '• ');
      } else if (numberPattern.hasMatch(line)) {
        // Keep the numbering as is
        line = line.replaceFirstMapped(
            numberPattern, (match) => '${match.group(0)} ');
      }

      // Process bold and italic formatting
      String remainingText = line;
      int lastIndex = 0;

      // Handle bold text
      boldStarsPattern.allMatches(remainingText).forEach((match) {
        // Add text before the match
        if (match.start > lastIndex) {
          spans.add(TextSpan(
            text: remainingText.substring(lastIndex, match.start),
            style: TextStyle(color: textColor, fontSize: fontSize),
          ));
        }

        // Add bold text
        spans.add(TextSpan(
          text: match.group(1),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: fontSize,
          ),
        ));

        lastIndex = match.end;
      });

      // Add remaining text after bold processing
      if (lastIndex < remainingText.length) {
        String finalText = remainingText.substring(lastIndex);

        // Process italic text in the remaining content
        lastIndex = 0;
        italicStarsPattern.allMatches(finalText).forEach((match) {
          if (match.start > lastIndex) {
            spans.add(TextSpan(
              text: finalText.substring(lastIndex, match.start),
              style: TextStyle(color: textColor, fontSize: fontSize),
            ));
          }

          spans.add(TextSpan(
            text: match.group(1),
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: textColor,
              fontSize: fontSize,
            ),
          ));

          lastIndex = match.end;
        });

        if (lastIndex < finalText.length) {
          spans.add(TextSpan(
            text: finalText.substring(lastIndex),
            style: TextStyle(color: textColor, fontSize: fontSize),
          ));
        }
      }

      // Add newline if not the last line
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return TextSpan(children: spans);
  }
}
