class Category {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final List<String> parentCategories;
  final List<String> hierarchies;
  bool selected;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.parentCategories = const [],
    this.hierarchies = const [],
    this.selected = false,
  });

  // Factory for JSON deserialization
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      name: json['nom'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      parentCategories: List<String>.from(json['parentCategories'] ?? []),
      hierarchies: List<String>.from(json['hierarchies'] ?? []),
      selected: false,
    );
  }

  // Method for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nom': name,
      'description': description,
      'imageUrl': imageUrl,
      'parentCategories': parentCategories,
      'hierarchies': hierarchies,
    };
  }
}
