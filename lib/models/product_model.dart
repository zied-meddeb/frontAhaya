// For demo only



class ProductModel {
  final String image, brandName, title,description,id;
  final double price;
  final double? priceAfetDiscount;
  final int? dicountpercent;
  final String? categoryId;
  final String? categoryName;


  ProductModel({
    required this.id,
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
     required this.description,
    this.priceAfetDiscount,
    this.dicountpercent,
    this.categoryId,
    this.categoryName,
  });
}



List<ProductModel>  demoFlashSaleProducts= [
  ProductModel(
    id: "1",
    image: "https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
    brandName: "Sony",
    title: "Wireless Controller for PS4™",
    price: 64.99,
    description: "Wireless Controller for PS4™",
    categoryId: "1",
    categoryName: "Electronics",
  )
];


List<ProductModel> demoPopularProducts = [
  ProductModel(
    id: "1",
    image: "https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
    brandName: "Sony",
    title: "Wireless Controller for PS4™",
    price: 64.99,
    description: "Wireless Controller for PS4™",
    categoryId: "1",
    categoryName: "Electronics",
  )
];
List<ProductModel> demoBestSellersProducts = [
  ProductModel(
    id: "1",
    image: "https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
    brandName: "Sony",
    title: "Wireless Controller for PS4™",
    price: 64.99,
    description: "Wireless Controller for PS4™",
    categoryId: "1",
    categoryName: "Electronics",
  )
];
List<ProductModel> kidsProducts = [
  ProductModel(
    id: "1",
    image: "https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60",
    brandName: "Sony",
    title: "Wireless Controller for PS4™",
    price: 64.99,
    description: "Wireless Controller for PS4™",
    categoryId: "1",
    categoryName: "Electronics",
  )
];
