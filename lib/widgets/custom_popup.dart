import 'package:flutter/material.dart';
import 'package:messenger/constants.dart';

class CustomPopupMenu extends StatefulWidget {
  final Widget child;
  final List<MyPopupMenuItem> items;
  final Offset offset;

  const CustomPopupMenu({
    super.key,
    required this.child,
    required this.items,
    this.offset = Offset.zero,
  });

  @override
  State<CustomPopupMenu> createState() => _CustomPopupMenuState();
}

class _CustomPopupMenuState extends State<CustomPopupMenu> with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _showOverlay(BuildContext context) {
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
    final Size screenSize = overlay.size;

    final Offset buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
    double dx = buttonPosition.dx + widget.offset.dx;
    double dy = buttonPosition.dy + button.size.height + widget.offset.dy;

    const double popupWidth = 200;
    const double popupHeight = 48 * 3;

    // Right swipe amount
    const double horizontalShift = 12.0;
    dx += horizontalShift;

    // Don't cross the border.
    if (dx + popupWidth > screenSize.width) {
      dx = screenSize.width - popupWidth - 8;
    }
    if (dx < 8) {
      dx = 8; // Don't even go out from the left side.
    }

    if (dy + popupHeight > screenSize.height) {
      dy = screenSize.height - popupHeight - 8;
    }

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            //Background — closes when clicked
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeOverlay,
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              left: dx,
              top: dy,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  alignment: Alignment.topLeft,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Material(
                      color: consts.colors.dominant.bgMediumContrast,
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: popupWidth),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: widget.items.map((item) {
                            return InkWell(
                              onTap: () {
                                item.onTap?.call();
                                _removeOverlay();
                              },
                              child: item,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    _overlayEntry = entry;
    Overlay.of(context).insert(entry);
    _controller.forward(from: 0);
  }

  void _removeOverlay() {
    _controller.reverse();
    Future.delayed(const Duration(milliseconds: 100), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (_overlayEntry == null) {
          _showOverlay(context);
        } else {
          _removeOverlay();
        }
      },
      child: widget.child,
    );
  }
}

class MyPopupMenuItem extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final VoidCallback? onTap;
  final TextStyle? titleStyle;

  const MyPopupMenuItem({
    super.key,
    required this.leading,
    required this.title,
    this.onTap,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: title,
      dense: true,
      onTap: onTap,
      visualDensity: VisualDensity.compact,
      // titleTextStyle: titleStyle ?? consts.typography.text2.copyWith(color: Colors.white),
    );
  }
}