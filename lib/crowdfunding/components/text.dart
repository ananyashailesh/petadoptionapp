import 'package:adoption_ui_app/crowdfunding/components/spacing.dart';
import 'package:adoption_ui_app/crowdfunding/components/typography.dart';
import 'package:flutter/material.dart';

import 'color.dart';

class TextBody extends StatelessWidget {
  final String text;

  const TextBody({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: marginBottom24,
      child: Text(text, style: bodyTextStyle),
    );
  }
}

class TextBodySecondary extends StatelessWidget {
  final String text;

  const TextBodySecondary({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: marginBottom24,
      child: Text(text, style: subtitleTextStyle),
    );
  }
}

class TextHeadlineSecondary extends StatelessWidget {
  final String text;

  const TextHeadlineSecondary({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: marginBottom12,
      child: Text(text, style: headlineSecondaryTextStyle),
    );
  }
}

class TextBlockquote extends StatelessWidget {
  final String text;

  const TextBlockquote({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: marginBottom24,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(width: 2, color: AppColor.primary)),
      ),
      padding: const EdgeInsets.only(left: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: bodyTextStyle),
      ),
    );
  }
}

ButtonStyle? menuButtonStyle = TextButton.styleFrom(
  foregroundColor: AppColor.labelColor,
  backgroundColor: Colors.transparent,
  disabledForegroundColor: const Color.fromRGBO(0, 0, 0, 0.38),
  textStyle: buttonTextStyle,
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
);
