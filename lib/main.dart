import 'package:messenger/application.dart';
import 'package:rinf/rinf.dart';
import 'src/bindings/bindings.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  /*
    TODO:
    Logging, notifications, cross platform, i18n
  */
  await initializeRust(assignRustSignal);
  runApp(const Application());
}

// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telegram Popup Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _showTelegramPopup(
    BuildContext context,
    Offset position,
    List<PopupMenuEntry<dynamic>> items,
  ) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final screenSize = overlay.size;

    // Dinamik popup razmerini hisoblash
    const double itemHeight = 48.0; // Har bir item balandligi
    const double verticalPadding = 16.0; // Popup ichidagi padding
    final double popupHeight = (items.length * itemHeight) + verticalPadding;
    final double popupWidth = 200.0; // Yoki bu ham dinamik bo'lishi mumkin

    showMenu(
      context: context,
      position: _calculatePopupPosition(position, screenSize, popupWidth, popupHeight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      items: items,
    );
  }

  List<PopupMenuEntry<dynamic>> _getMenuItems(BuildContext context) {
    return [
      _buildPopupItem(Icons.reply, 'Reply', () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reply bosildi')));
      }),
      _buildPopupItem(Icons.edit, 'Edit', () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit bosildi')));
      }),
      _buildPopupItem(Icons.copy, 'Copy', () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copy bosildi')));
      }),
      _buildPopupItem(Icons.forward, 'Forward', () {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Forward bosildi')));
      }),
      _buildPopupItem(Icons.delete, 'Delete', () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delete bosildi')));
      }, isDestructive: true),
    ];
  }

  PopupMenuItem _buildPopupItem(
    IconData icon,
    String text,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDestructive ? Colors.red : Colors.grey[700]),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(fontSize: 15, color: isDestructive ? Colors.red : Colors.black87),
          ),
        ],
      ),
    );
  }

  RelativeRect _calculatePopupPosition(
    Offset tapPosition,
    Size screenSize,
    double popupWidth,
    double popupHeight,
  ) {
    const double padding = 16;

    double left = tapPosition.dx;
    double top = tapPosition.dy;

    // O'ng tomonga joy tekshirish
    if (left + popupWidth > screenSize.width - padding) {
      left = screenSize.width - popupWidth - padding;
    }

    // Chap tomonga joy tekshirish
    if (left < padding) {
      left = padding;
    }

    // Pastga joy tekshirish
    if (top + popupHeight > screenSize.height - padding) {
      top = tapPosition.dy - popupHeight;
    }

    // Tepaga joy tekshirish
    if (top < padding) {
      top = padding;
    }

    return RelativeRect.fromLTRB(
      left,
      top,
      screenSize.width - left - popupWidth,
      screenSize.height - top - popupHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telegram Popup Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onLongPressStart: (details) {
          final Offset pos = details.globalPosition;
          print('Tap joylashuvi: $pos');
          _showTelegramPopup(context, details.globalPosition, _getMenuItems(context));
        },
        child: ListView.builder(
          itemCount: 20,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            return GestureDetector(
              onLongPressStart: (details) {
                _showTelegramPopup(context, details.globalPosition, _getMenuItems(context));
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.blue, child: Text('${index + 1}')),
                  title: Text('Xabar ${index + 1}'),
                  subtitle: const Text('Bu yerda xabar matni bor...'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
