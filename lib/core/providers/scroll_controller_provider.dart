import 'package:flutter/material.dart';

/// Makes the page [ScrollController] available to any descendant widget
/// without prop-drilling. Used by [SectionWrapper] to listen for scroll
/// events and trigger entrance animations.
class ScrollControllerProvider extends InheritedWidget {
  const ScrollControllerProvider({
    super.key,
    required this.scrollController,
    required super.child,
  });

  final ScrollController scrollController;

  /// Returns the nearest [ScrollController] from the widget tree.
  /// Returns null if no provider is found above.
  static ScrollController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ScrollControllerProvider>()
        ?.scrollController;
  }

  @override
  bool updateShouldNotify(ScrollControllerProvider old) =>
      old.scrollController != scrollController;
}