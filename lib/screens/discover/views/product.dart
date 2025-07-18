class Product {
  final int id;
  final String name;
  final double price;
  final double? originalPrice;
  final String? discount;
  final String discountType;
  final double rating;
  final int reviewCount;
  final String image;
  final String category;
  final String brand;
  final String description;


  Product({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    this.discount,
    required this.discountType,
    required this.rating,
    required this.reviewCount,
    required this.image,
    required this.category,
    required this.brand,
    required this.description,

  });
}

