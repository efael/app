import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:messenger/constants.dart";
import "package:messenger/rinf/bindings/signals/signals.dart";

class UserAvatar extends StatelessWidget {
  final RoomPreviewAvatar avatar;
  final double size;

  const UserAvatar({super.key, required this.avatar, this.size = 56});

  Widget get drawAvatar {
    switch (avatar) {
      case RoomPreviewAvatarText(value: final value):
        return CircleAvatar(
          backgroundColor: Colors.transparent,
          child: FittedBox(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                value,
                style: TextStyle(
                  color: consts.colors.accent.white.dark,
                  fontWeight: FontWeight.bold,
                  fontSize: 64,
                ),
              ),
            ),
          ),
        );
      case RoomPreviewAvatarImage(value: final value):
        return CircleAvatar(
          backgroundImage: MemoryImage(Uint8List.fromList(value)),
        );
    }

    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(180, 147, 248, 1),
            Color.fromRGBO(111, 99, 224, 1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: drawAvatar,
    );
  }
}
