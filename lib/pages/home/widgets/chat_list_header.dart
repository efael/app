import "package:flutter/material.dart";
import "package:messenger/constants.dart";

class ChatListHeader extends StatelessWidget {
  const ChatListHeader({
    super.key,
    this.tabs,
    required this.title,
    this.onSearch,
  });

  final List<Widget>? tabs;
  final String title;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: consts.colors.dominant.bgMediumContrast.dark,
      pinned: true,
      floating: true,
      title: Text(title, style: consts.typography.text1.copyWith(fontSize: 20)),
      actions: [
        IconButton(
          onPressed: onSearch,
          icon: Icon(
            Icons.search,
            color: consts.colors.content.mediumContrast.dark,
          ),
        ),
      ],
      bottom: (tabs?.isNotEmpty ?? false)
          ? TabBar(
              isScrollable: true,
              padding: EdgeInsets.zero,
              tabAlignment: TabAlignment.start,
              dividerColor: consts.colors.dominant.bgLowContrast.dark,
              labelStyle: consts.typography.text2.copyWith(fontSize: 14),
              tabs: tabs ?? [],
            )
          : null,
    );
  }
}
