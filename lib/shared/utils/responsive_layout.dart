import 'package:flutter/material.dart';

enum ScreenSize {
  small,
  medium,
  large,
  extraLarge,
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 600) {
      return ScreenSize.small;
    } else if (width < 900) {
      return ScreenSize.medium;
    } else if (width < 1200) {
      return ScreenSize.large;
    } else {
      return ScreenSize.extraLarge;
    }
  }

  static bool isMobile(BuildContext context) {
    return getScreenSize(context) == ScreenSize.small;
  }

  static bool isTablet(BuildContext context) {
    return getScreenSize(context) == ScreenSize.medium;
  }

  static bool isDesktop(BuildContext context) {
    final size = getScreenSize(context);
    return size == ScreenSize.large || size == ScreenSize.extraLarge;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = getScreenSize(context);

    if (screenSize == ScreenSize.extraLarge && desktop != null) {
      return desktop!;
    } else if (screenSize == ScreenSize.large && desktop != null) {
      return desktop!;
    } else if (screenSize == ScreenSize.medium && tablet != null) {
      return tablet!;
    }

    return mobile;
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSize screenSize) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveLayout.getScreenSize(context);
    return builder(context, screenSize);
  }
}

class AdaptiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;
  final double? maxWidth;

  const AdaptiveContainer({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveLayout.getScreenSize(context);

    EdgeInsets padding;
    if (screenSize == ScreenSize.extraLarge || screenSize == ScreenSize.large) {
      padding = desktopPadding ?? const EdgeInsets.all(24);
    } else if (screenSize == ScreenSize.medium) {
      padding = tabletPadding ?? const EdgeInsets.all(20);
    } else {
      padding = mobilePadding ?? const EdgeInsets.all(16);
    }

    Widget content = Padding(
      padding: padding,
      child: child,
    );

    if (maxWidth != null) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth!),
          child: content,
        ),
      );
    }

    return content;
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? mobileFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;

  const ResponsiveText({
    super.key,
    required this.text,
    this.style,
    this.mobileFontSize,
    this.tabletFontSize,
    this.desktopFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveLayout.getScreenSize(context);

    double? fontSize;
    if (screenSize == ScreenSize.extraLarge || screenSize == ScreenSize.large) {
      fontSize = desktopFontSize;
    } else if (screenSize == ScreenSize.medium) {
      fontSize = tabletFontSize;
    } else {
      fontSize = mobileFontSize;
    }

    final textStyle = style ?? Theme.of(context).textTheme.bodyMedium;

    return Text(
      text,
      style: fontSize != null
          ? textStyle?.copyWith(fontSize: fontSize)
          : textStyle,
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveLayout.getScreenSize(context);

    int columnCount;
    if (screenSize == ScreenSize.extraLarge || screenSize == ScreenSize.large) {
      columnCount = desktopColumns;
    } else if (screenSize == ScreenSize.medium) {
      columnCount = tabletColumns;
    } else {
      columnCount = mobileColumns;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columnCount,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      children: children,
    );
  }
}

class ResponsiveSpacing extends StatelessWidget {
  final double mobile;
  final double tablet;
  final double desktop;
  final bool isHorizontal;

  const ResponsiveSpacing({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveLayout.getScreenSize(context);

    double size;
    if (screenSize == ScreenSize.extraLarge || screenSize == ScreenSize.large) {
      size = desktop;
    } else if (screenSize == ScreenSize.medium) {
      size = tablet;
    } else {
      size = mobile;
    }

    return SizedBox(
      width: isHorizontal ? size : null,
      height: isHorizontal ? null : size,
    );
  }
}
