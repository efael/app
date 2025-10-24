import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsCardBlock extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const SettingsCardBlock({super.key, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12),
              Text(title!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        Card(
          color: Color(0xFF212F3F),
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Theme(
            data: Theme.of(context).copyWith(splashColor: Colors.transparent),
            child: ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, i) => children[i],
              separatorBuilder: (BuildContext context, int index) {
                return Divider(color: theme.scaffoldBackgroundColor, height: 1, thickness: 1);
              },
              itemCount: children.length,
            ),
          ),
        ),
      ],
    );
  }
}

class SettingsInfoTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? icon;
  final Widget? trailing;
  final GestureTapCallback? onTap;
  final Color color;
  final SettingsSwitchTileType? switcher;

  const SettingsInfoTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
    this.color = Colors.white,
    this.switcher,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: (onTap == null) ? .8 : 1,
      child: ListTile(
        title: Text(title, style: TextStyle(fontSize: 14, color: color)),
        subtitle: (subtitle != null)
            ? Text(subtitle!, style: TextStyle(fontSize: 12, color: Colors.blueGrey))
            : null,
        leading: (icon != null)
            ? SvgPicture.asset(icon!, colorFilter: ColorFilter.mode(color, BlendMode.srcIn))
            : null,
        onTap: (switcher != null)
            ? () {
                switcher!.onChanged(!switcher!.value);
                if (onTap != null) onTap!();
              }
            : onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        minTileHeight: 0,
        trailing: (switcher != null)
            ? Transform.scale(
                scale: 0.8,
                alignment: Alignment.centerRight,
                child: Switch(value: switcher!.value, onChanged: switcher!.onChanged),
              )
            : trailing,
      ),
    );
  }
}

class SettingsSwitchTileType {
  final bool value;
  final ValueChanged<bool> onChanged;

  SettingsSwitchTileType({required this.value, required this.onChanged});
}
