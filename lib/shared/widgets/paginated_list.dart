import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'scroll_reveal.dart';
import 'skeleton.dart';

/// Lazily loading list that reveals items progressively and shows skeletons
/// while the next batch loads (design.md section 5).
///
/// The caller owns the item state and supplies [onLoadMore]. [onLoadMore] is
/// invoked when the user scrolls within ~200px of the bottom.
class PaginatedListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function()? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;
  final EdgeInsetsGeometry padding;
  final int skeletonCount;
  final bool enableReveal;
  final Widget? emptyState;

  const PaginatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.padding = const EdgeInsets.all(AppSpacing.screenPadding),
    this.skeletonCount = 3,
    this.enableReveal = true,
    this.emptyState,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final ScrollController _scrollController = ScrollController();
  bool _loadMoreRequested = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(covariant PaginatedListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isLoadingMore) _loadMoreRequested = false;
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!mounted) return;
    if (widget.onLoadMore == null || !widget.hasMore || widget.isLoadingMore) {
      return;
    }
    if (_loadMoreRequested) return;

    final position = _scrollController.position;
    if (!position.hasPixels) return;

    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMoreRequested = true;
      widget.onLoadMore!.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoadingMore) {
      return widget.emptyState ?? const SizedBox.shrink();
    }

    final skeletonCount = widget.isLoadingMore ? widget.skeletonCount : 0;
    final itemCount = widget.items.length + skeletonCount;

    return ListView.separated(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: itemCount,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.cardGap),
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          return const SkeletonCard();
        }

        final itemWidget = widget.itemBuilder(
          context,
          widget.items[index],
          index,
        );

        if (!widget.enableReveal) return itemWidget;

        return RevealOnScroll(index: index, child: itemWidget);
      },
    );
  }
}
