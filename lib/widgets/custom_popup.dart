import 'package:flutter/material.dart';

class CustomPopover {
  static OverlayEntry? _entry;

  static void show({
    required BuildContext context,
    required Widget child,
    required GlobalKey targetKey,
    bool showAbove = false,
    double width = 150,
    double aboveValue = 10,
    double moveToLeft = 0,
  }) {
    // Agar eski popover ochiq bo'lsa yopamiz
    hide();

    final overlay = Overlay.of(context);
    final renderBox = targetKey.currentContext!.findRenderObject() as RenderBox;
    final targetPosition = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;

    _entry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Background bosilganda yopish
            GestureDetector(
              onTap: hide,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
            Positioned(
              left: targetPosition.dx - moveToLeft,
              top: showAbove
                  ? targetPosition.dy - aboveValue // yuqoriga chiqish
                  : targetPosition.dy + targetSize.height,
              child: Material(
                color: Colors.transparent,
                child: AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    width: width,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.20),
                          offset: const Offset(0, 0),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}
