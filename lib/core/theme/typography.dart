import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system defined in design.md section 2.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Manrope';

  static TextStyle heading1({Color? color}) => GoogleFonts.manrope(
        fontSize: 32,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle heading2({Color? color}) => GoogleFonts.manrope(
        fontSize: 24,
        height: 1.33,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle heading3({Color? color}) => GoogleFonts.manrope(
        fontSize: 20,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle bodyLarge({Color? color}) => GoogleFonts.manrope(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle body({Color? color}) => GoogleFonts.manrope(
        fontSize: 14,
        height: 1.43,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle caption({Color? color}) => GoogleFonts.manrope(
        fontSize: 12,
        height: 1.33,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle label({Color? color, FontWeight? weight}) => GoogleFonts.manrope(
        fontSize: 14,
        height: 1.43,
        fontWeight: weight ?? FontWeight.w500,
        color: color,
      );

  static TextTheme textTheme({
    required TextTheme base,
    required Color headingText,
    required Color primaryText,
    required Color secondaryText,
  }) {
    return GoogleFonts.manropeTextTheme(
      base.copyWith(
        displayLarge: heading1(color: headingText),
        displayMedium: heading1(color: headingText),
        displaySmall: heading2(color: headingText),
        headlineMedium: heading2(color: headingText),
        headlineSmall: heading3(color: headingText),
        titleLarge: heading3(color: headingText),
        bodyLarge: bodyLarge(color: primaryText),
        bodyMedium: body(color: primaryText),
        bodySmall: body(color: secondaryText),
        labelLarge: bodyLarge(color: primaryText),
        labelMedium: body(color: secondaryText),
        labelSmall: caption(color: secondaryText),
      ),
    );
  }
}
