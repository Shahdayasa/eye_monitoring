import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'typography.dart';

export 'typography.dart';

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxxl = 40;
  static const double xxxxxl = 48;

  static const double screenPadding = 16;
  static const double cardGap = 12;
}

class AppRadius {
  AppRadius._();

  static const double pill = 9999;
  static const double card = 16;
  static const double image = 16;
  static const double bottomSheet = 24;
  static const double input = 12;
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> soft = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 16,
      color: Color(0x0F000000),
    ),
  ];
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData.light();
    return _buildTheme(
      base: base,
      background: AppColorsLight.background,
      surface: AppColorsLight.surface,
      border: AppColorsLight.border,
      primaryText: AppColorsLight.primaryText,
      secondaryText: AppColorsLight.secondaryText,
      headingText: AppColorsLight.headingText,
      brandGreen: AppColorsLight.brandGreen,
      brightness: Brightness.light,
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark();
    return _buildTheme(
      base: base,
      background: AppColorsDark.background,
      surface: AppColorsDark.surface,
      border: AppColorsDark.border,
      primaryText: AppColorsDark.primaryText,
      secondaryText: AppColorsDark.secondaryText,
      headingText: AppColorsDark.headingText,
      brandGreen: AppColorsDark.brandGreen,
      brightness: Brightness.dark,
    );
  }

  static ThemeData _buildTheme({
    required ThemeData base,
    required Color background,
    required Color surface,
    required Color border,
    required Color primaryText,
    required Color secondaryText,
    required Color headingText,
    required Color brandGreen,
    required Brightness brightness,
  }) {
    final textTheme = AppTypography.textTheme(
      base: base.textTheme,
      headingText: headingText,
      primaryText: primaryText,
      secondaryText: secondaryText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: brandGreen,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primary0,
        onPrimaryContainer: brandGreen,
        secondary: AppColors.grey900,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondary0,
        onSecondaryContainer: AppColors.secondary200,
        surface: surface,
        onSurface: primaryText,
        error: AppColors.errorText,
        onError: Colors.white,
        errorContainer: AppColors.errorBg,
        onErrorContainer: AppColors.errorText,
        outline: border,
        outlineVariant: AppColors.secondary25,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: headingText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.heading3(color: headingText),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: AppTypography.bodyLarge(color: Colors.white)
              .copyWith(fontWeight: FontWeight.w600),
          elevation: 0,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.pressedPrimary;
            }
            if (states.contains(WidgetState.hovered)) {
              return AppColors.primary200;
            }
            return null;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: AppTypography.bodyLarge(color: headingText)
              .copyWith(fontWeight: FontWeight.w600),
          side: BorderSide(color: border),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primary25;
            }
            if (states.contains(WidgetState.hovered)) {
              return AppColors.primary0;
            }
            return null;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed) ||
                states.contains(WidgetState.hovered)) {
              return brandGreen;
            }
            return headingText;
          }),
          side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
            if (states.contains(WidgetState.pressed) ||
                states.contains(WidgetState.hovered)) {
              return BorderSide(color: brandGreen);
            }
            return BorderSide(color: border);
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brandGreen,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: AppTypography.bodyLarge(color: brandGreen)
              .copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.grey800,
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? AppColors.grey50
            : AppColorsDark.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(color: brandGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: const BorderSide(color: AppColors.errorText),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: const BorderSide(color: AppColors.errorText, width: 2),
        ),
        labelStyle: AppTypography.body(color: secondaryText),
        hintStyle: AppTypography.body(color: AppColors.secondary50),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: AppColors.grey900,
        disabledColor: AppColors.grey100,
        labelStyle: AppTypography.body(color: AppColors.grey800),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        side: BorderSide(color: AppColors.grey200),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.bottomSheet),
            topRight: Radius.circular(AppRadius.bottomSheet),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.grey900,
        contentTextStyle: AppTypography.body(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: brandGreen,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return AppColors.grey400;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return brandGreen;
          }
          return AppColors.grey200;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return brandGreen;
          }
          return AppColors.grey400;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return brandGreen;
          }
          return AppColors.grey400;
        }),
      ),
    );
  }
}
