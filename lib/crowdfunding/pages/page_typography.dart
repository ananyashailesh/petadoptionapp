import 'package:adoption_ui_app/crowdfunding/components/color.dart';
import 'package:adoption_ui_app/crowdfunding/components/typography.dart';
import 'package:flutter/material.dart';


class TypographyPage extends StatelessWidget {
  static const String name = 'typography';

  const TypographyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Typography',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColor.mainColor,
                ),
              ),
              SizedBox(height: 20),
              _buildTypographySection('Headlines', [
                Text('Headline Primary', style: headlineTextStyle),
                Text('Headline Secondary', style: headlineSecondaryTextStyle),
                Text('Subtitle', style: subtitleTextStyle),
              ]),
              _buildTypographySection('Body Text', [
                Text('Body Text Regular', style: bodyTextStyle),
                Text(
                  'Body Text Bold',
                  style: bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Body Text Italic',
                  style: bodyTextStyle.copyWith(fontStyle: FontStyle.italic),
                ),
              ]),
              _buildTypographySection('Buttons', [
                Text('Button Text', style: buttonTextStyle),
                Text(
                  'Button Text Bold',
                  style: buttonTextStyle.copyWith(fontWeight: FontWeight.bold),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypographySection(String title, List<Widget> children) {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColor.mainColor,
            ),
          ),
          SizedBox(height: 15),
          ...children.map(
            (child) =>
                Padding(padding: EdgeInsets.only(bottom: 10), child: child),
          ),
        ],
      ),
    );
  }
}
