
class Category {
  final String id;
  final String name;
  final int icon;
  bool selected;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    this.selected = false,
  });
}
