class NavItem {
  final String key;
  final String label;
  final String iconPath;
  final int? count;

  const NavItem({
    required this.key,
    required this.label,
    required this.iconPath,
    this.count,
  });
}
