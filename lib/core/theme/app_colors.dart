import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary0 = Color(0xFFEAFCF2);
  static const Color primary25 = Color(0xFFD3F8E3);
  static const Color primary50 = Color(0xFFAAF0C9);
  static const Color primary100 = Color(0xFF7DE6AC);
  static const Color primary200 = Color(0xFF4DDB8F);
  static const Color primary300 = Color(0xFF22C55E);

  static const Color secondary0 = Color(0xFFE4EEEC);
  static const Color secondary25 = Color(0xFFCCDAD7);
  static const Color secondary50 = Color(0xFF9DB3AF);
  static const Color secondary100 = Color(0xFF6C8A86);
  static const Color secondary200 = Color(0xFF386360);
  static const Color secondary300 = Color(0xFF052F2C);

  static const Color grey0 = Color(0xFFFFFFFF);
  static const Color grey50 = Color(0xFFF7F8F8);
  static const Color grey100 = Color(0xFFEDEEEE);
  static const Color grey200 = Color(0xFFD9DBDB);
  static const Color grey400 = Color(0xFF9A9E9E);
  static const Color grey600 = Color(0xFF5A5E5E);
  static const Color grey800 = Color(0xFF222424);
  static const Color grey900 = Color(0xFF111111);

  static const Color successBg = Color(0xFFEAFCF2);
  static const Color successText = Color(0xFF22C55E);
  static const Color warningBg = Color(0xFFFFF4D6);
  static const Color warningText = Color(0xFFD99A00);
  static const Color warningBorder = Color(0xFFF3D08A);
  static const Color errorBg = Color(0xFFFDE8E8);
  static const Color errorText = Color(0xFFDC2626);
  static const Color infoBg = Color(0xFFE6F0FF);
  static const Color infoText = Color(0xFF2563EB);

  static const Color pressedPrimary = Color(0xFF1AA64D);
}

class AppColorsLight {
  static const Color background = AppColors.grey50;
  static const Color surface = AppColors.grey0;
  static const Color border = AppColors.secondary25;
  static const Color primaryText = AppColors.grey800;
  static const Color secondaryText = AppColors.grey600;
  static const Color headingText = AppColors.grey900;
  static const Color brandGreen = AppColors.primary300;
}

class AppColorsDark {
  static const Color background = Color(0xFF171717);
  static const Color surface = Color(0xFF232525);
  static const Color border = Color(0xFF343737);
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFA8ADAD);
  static const Color headingText = Color(0xFFFFFFFF);
  static const Color brandGreen = AppColors.primary300;
}
