import 'package:flutter/material.dart';

class OptimizedListView extends StatelessWidget {
  /// The number of items the ListView should display
  final int itemCount;

  /// Builder function that creates widgets for list items
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Optional scroll controller
  final ScrollController? controller;

  /// Optional padding
  final EdgeInsetsGeometry? padding;

  /// Optional separator builder for ListView.separated style
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// Whether to shrink wrap the list
  final bool shrinkWrap;

  /// Scroll physics
  final ScrollPhysics? physics;

  /// Whether to add automatic keep alives (default: true for better performance)
  final bool addAutomaticKeepAlives;

  /// Whether to add repaint boundaries (default: true for better performance)
  final bool addRepaintBoundaries;

  /// Cache extent multiplier (default: 250.0 for optimal performance)
  final double cacheExtent;

  /// Whether to reverse the list
  final bool reverse;

  /// Primary scroll direction
  final Axis scrollDirection;

  const OptimizedListView.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.cacheExtent = 250.0,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
  }) : separatorBuilder = null;

  const OptimizedListView.separated({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.separatorBuilder,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.cacheExtent = 250.0,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    if (separatorBuilder != null) {
      return ListView.separated(
        controller: controller,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        cacheExtent: cacheExtent,
        reverse: reverse,
        scrollDirection: scrollDirection,
        itemCount: itemCount,
        separatorBuilder: separatorBuilder!,
        itemBuilder: (context, index) {
          final item = itemBuilder(context, index);

          // Wrap item with RepaintBoundary for better performance
          if (addRepaintBoundaries) {
            return RepaintBoundary(
              key: ValueKey('optimized_item_$index'),
              child: item,
            );
          }

          return item;
        },
      );
    }

    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      cacheExtent: cacheExtent,
      reverse: reverse,
      scrollDirection: scrollDirection,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final item = itemBuilder(context, index);

        // Wrap item with RepaintBoundary for better performance
        if (addRepaintBoundaries) {
          return RepaintBoundary(
            key: ValueKey('optimized_item_$index'),
            child: item,
          );
        }

        return item;
      },
    );
  }
}

/// Optimized ListView with pagination support
class OptimizedPaginationListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool hasNextPage;
  final Widget? loadingIndicator;
  final VoidCallback? onLoadMore;
  final double loadMoreThreshold;

  const OptimizedPaginationListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.padding,
    this.separatorBuilder,
    this.shrinkWrap = false,
    this.physics,
    this.hasNextPage = false,
    this.loadingIndicator,
    this.onLoadMore,
    this.loadMoreThreshold = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    // Add scroll listener for pagination
    if (controller != null && onLoadMore != null) {
      controller!.addListener(() {
        if (!controller!.hasClients) return;

        final maxScroll = controller!.position.maxScrollExtent;
        final currentScroll = controller!.position.pixels;
        final threshold = maxScroll * loadMoreThreshold;

        if (currentScroll >= threshold && hasNextPage) {
          onLoadMore?.call();
        }
      });
    }

    final totalItemCount = itemCount + (hasNextPage ? 1 : 0);

    if (separatorBuilder != null) {
      return OptimizedListView.separated(
        itemCount: totalItemCount,
        controller: controller,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics,
        separatorBuilder: separatorBuilder!,
        itemBuilder: (context, index) {
          if (index >= itemCount) {
            // Show loading indicator at the end
            return loadingIndicator ??
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
          }

          return itemBuilder(context, index);
        },
      );
    }

    return OptimizedListView.builder(
      itemCount: totalItemCount,
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemBuilder: (context, index) {
        if (index >= itemCount) {
          // Show loading indicator at the end
          return loadingIndicator ??
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
        }

        return itemBuilder(context, index);
      },
    );
  }
}
