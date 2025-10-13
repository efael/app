import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:messenger/constants.dart';
import 'package:messenger/widgets/userpic.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final bool isHaveAvatar;
  final bool isOnline;
  final bool isSecret;
  final bool isWrite;
  const ProfileHeaderWidget({
    super.key,
    required this.name,
    this.avatarUrl = '',
    this.isHaveAvatar = false,
    this.isOnline = false,
    this.isSecret = false,
    this.isWrite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(color: consts.colors.dominant.bgMediumContrast),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              iconButtonTheme: IconButtonThemeData(
                style: Theme.of(context).iconButtonTheme.style?.copyWith(
                  padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
                ),
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: consts.colors.content.highContrast, size: 24),
              onPressed: () {},
            ),
          ),

          SizedBox(width: 4),

          SizedBox(
            height: 48,
            child: Row(
              children: [
                Builder(
                  builder: (context) {
                    if (isHaveAvatar) {
                      return ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(24),
                        child: Image.asset(avatarUrl, width: 48, height: 48),
                      );
                    } else {
                      return Userpic(name: name, size: UserpicSize.medium);
                    }
                  },
                ),

                const SizedBox(width: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: .45),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (isSecret)
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Image.asset(
                                'assets/icons/ic_secret_chat_header_card.png',
                                width: 16,
                                height: 16,
                              ),
                            ),

                          if (isSecret) const SizedBox(width: 4),

                          Text(
                            name,
                            style: consts.typography.text2.copyWith(
                              fontSize: 20,
                              color: consts.colors.content.highContrast,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Builder(
                        builder: (context) {
                          if (isWrite) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Печатает",
                                  style: consts.typography.text2.copyWith(
                                    height: .18,
                                    color: consts.colors.accent.bluePrimary,
                                  ),
                                ),
                              ],
                            );
                          } else if (!isOnline) {
                            return Text(
                              "был недавно",
                              style: consts.typography.text2.copyWith(height: .18),
                            );
                          } else {
                            return Text(
                              "был в сети",
                              style: consts.typography.text2.copyWith(
                                height: .18,
                                color: consts.colors.accent.bluePrimary,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Spacer(),

          Theme(
            data: Theme.of(context).copyWith(
              iconButtonTheme: IconButtonThemeData(
                style: Theme.of(context).iconButtonTheme.style?.copyWith(
                  padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
                ),
              ),
            ),
            child: IconButton(
              icon: Icon(
                CupertinoIcons.search,
                color: consts.colors.content.mediumContrast,
                size: 24,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
