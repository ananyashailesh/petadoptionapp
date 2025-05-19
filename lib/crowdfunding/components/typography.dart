import 'package:adoption_ui_app/crowdfunding/components/color.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

// Simple
TextStyle headlineTextStyle = GoogleFonts.montserrat(
  textStyle: const TextStyle(
    fontSize: 26,
    color: AppColor.textColor,
    letterSpacing: 1.5,
    fontWeight: FontWeight.w300,
  ),
);

TextStyle headlineSecondaryTextStyle = GoogleFonts.montserrat(
  textStyle: const TextStyle(
    fontSize: 20,
    color: AppColor.textColor,
    fontWeight: FontWeight.w300,
  ),
);

TextStyle subtitleTextStyle = GoogleFonts.openSans(
  textStyle: const TextStyle(
    fontSize: 14,
    color: AppColor.labelColor,
    letterSpacing: 1,
  ),
);

TextStyle bodyTextStyle = GoogleFonts.openSans(
  textStyle: const TextStyle(fontSize: 14, color: AppColor.textColor),
);

TextStyle buttonTextStyle = GoogleFonts.montserrat(
  textStyle: const TextStyle(
    fontSize: 14,
    color: AppColor.textColor,
    letterSpacing: 1,
  ),
);

// Advanced
// TODO: Add additional text styles.
