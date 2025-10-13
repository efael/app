import 'package:flutter/material.dart';

class MessagePopupMenu extends StatelessWidget {
  final bool haveShare;
  final bool haveCopy;
  final bool haveDelete;
  final bool haveEdit;
  final bool havePin;
  const MessagePopupMenu({
    super.key,
    this.haveShare = true,
    this.haveCopy = true,
    this.haveDelete = true,
    this.haveEdit = true,
    this.havePin = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        if (haveShare) _BuildItem(onTap: () {}, icon: Icons.share, text: "Uzatish")
      ],
    );
  }
}


class _BuildItem extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String text;
  const _BuildItem({required this.onTap, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }
}