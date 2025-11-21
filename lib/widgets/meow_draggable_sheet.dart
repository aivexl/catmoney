import 'package:flutter/material.dart';

/// Draggable Bottom Sheet dengan unlimited scroll up capability
class MeowDraggableSheet extends StatefulWidget {
  final Widget? child;
  final ScrollableWidgetBuilder? builder;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final Color? backgroundColor;
  final double borderRadius;

  const MeowDraggableSheet({
    Key? key,
    this.child,
    this.builder,
    this.initialChildSize = 0.7,
    this.minChildSize = 0.7,
    this.maxChildSize = 1.0,
    this.backgroundColor,
    this.borderRadius = 24.0,
  }) : super(key: key);

  @override
  State<MeowDraggableSheet> createState() => _MeowDraggableSheetState();
}

class _MeowDraggableSheetState extends State<MeowDraggableSheet> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      builder: (context, scrollController) {
        return ListenableBuilder(
          listenable: _sheetController,
          builder: (context, child) {
            // Dynamic border radius: 0 when fully expanded, normal otherwise
            final currentSize = _sheetController.isAttached
                ? _sheetController.size
                : widget.initialChildSize;
            final isFullyExpanded = currentSize >= widget.maxChildSize - 0.01;
            final currentRadius = isFullyExpanded ? 0.0 : widget.borderRadius;

            return Container(
              decoration: BoxDecoration(
                color: widget.backgroundColor ??
                    Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(currentRadius),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  final double screenHeight =
                      MediaQuery.of(context).size.height;
                  final double delta = details.primaryDelta! / screenHeight;
                  final double newSize = (_sheetController.size - delta).clamp(
                    widget.minChildSize,
                    widget.maxChildSize,
                  );
                  _sheetController.jumpTo(newSize);
                },
                onVerticalDragEnd: (details) {
                  // Snap to nearest position
                  final double currentSize = _sheetController.size;
                  final double midPoint =
                      (widget.minChildSize + widget.maxChildSize) / 2;
                  final double targetSize = currentSize >= midPoint
                      ? widget.maxChildSize
                      : widget.minChildSize;
                  _sheetController.animateTo(
                    targetSize,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                  );
                },
                behavior: HitTestBehavior.translucent,
                child: Column(
                  children: [
                    // Paw handle
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 30,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              Icons.pets,
                              size: 20,
                              color: Colors.grey[400],
                            ),
                          ),
                          Container(
                            width: 30,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Expanded(
                      child: widget.builder != null
                          ? widget.builder!(context, scrollController)
                          : ListView(
                              controller: scrollController,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              children: [
                                widget.child ?? const SizedBox(),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Wrapper untuk MeowDraggableSheet
class MeowPageWithSheet extends StatelessWidget {
  final Widget background;
  final Widget? sheetContent;
  final ScrollableWidgetBuilder? sheetBuilder;
  final double initialSize;
  final double minSize;
  final double maxSize;
  final Color? sheetColor;
  final Widget? floatingActionButton;

  const MeowPageWithSheet({
    Key? key,
    required this.background,
    this.sheetContent,
    this.sheetBuilder,
    this.initialSize = 0.7,
    this.minSize = 0.7,
    this.maxSize = 1.0,
    this.sheetColor,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          background,
          MeowDraggableSheet(
            initialChildSize: initialSize,
            minChildSize: minSize,
            maxChildSize: maxSize,
            backgroundColor: sheetColor,
            child: sheetContent,
            builder: sheetBuilder,
          ),
        ],
      ),
    );
  }
}
