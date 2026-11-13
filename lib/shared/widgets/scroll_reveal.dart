import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';

/// Fades and slides a child into place the first time it becomes visible.
///
/// Implements design.md section 5: opacity 0 -> 1, 24px upward slide,
/// 400ms ease-out, triggered once at ~15% viewport visibility, with an
/// optional 80ms stagger between siblings. Respects reduced-motion settings.
class RevealOnScroll extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Duration stagger;
  final double slideOffset;

  const RevealOnScroll({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = AppConfig.animationDuration,
    this.stagger = AppConfig.staggerDelay,
    this.slideOffset = 24,
  });

  @override
  State<RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<RevealOnScroll> {
  bool _revealed = false;
  bool _reducedMotion = false;
  ScrollPosition? _position;
  Timer? _staggerTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _reducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    _attachScrollListener();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _evaluateVisibility();
    });
  }

  void _attachScrollListener() {
    final scrollable = Scrollable.maybeOf(context);
    final position = scrollable?.position;

    if (position == null || identical(position, _position)) return;

    _position?.removeListener(_evaluateVisibility);
    _position = position;
    _position?.addListener(_evaluateVisibility);
  }

  void _evaluateVisibility() {
    if (!mounted || _revealed) return;

    if (_reducedMotion) {
      _reveal();
      return;
    }

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;

    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) return;

    final top = renderObject.localToGlobal(Offset.zero).dy;
    final triggerLine = mediaQuery.size.height * 0.85;

    if (top <= triggerLine) {
      final staggerIndex =
          widget.index.clamp(0, AppConfig.maxStaggeredItems - 1);
      final delay = widget.stagger * staggerIndex;

      if (delay == Duration.zero) {
        _reveal();
      } else {
        _staggerTimer?.cancel();
        _staggerTimer = Timer(delay, () {
          if (mounted) _reveal();
        });
      }
    }
  }

  void _reveal() {
    if (!mounted || _revealed) return;

    _position?.removeListener(_evaluateVisibility);
    _position = null;
    setState(() => _revealed = true);
  }

  @override
  void dispose() {
    _staggerTimer?.cancel();
    _position?.removeListener(_evaluateVisibility);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_reducedMotion) return widget.child;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: _revealed ? 1 : 0),
      duration: _revealed ? widget.duration : Duration.zero,
      curve: Curves.easeOut,
      child: widget.child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, widget.slideOffset * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}

/// Reveals each child with the configured stagger.
class RevealGroup extends StatelessWidget {
  final List<Widget> children;
  final Duration stagger;
  final double spacing;

  const RevealGroup({
    super.key,
    required this.children,
    this.stagger = AppConfig.staggerDelay,
    this.spacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0 && spacing > 0) SizedBox(height: spacing),
          RevealOnScroll(
            index: i,
            stagger: stagger,
            child: children[i],
          ),
        ],
      ],
    );
  }
}
