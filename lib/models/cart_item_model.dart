import 'product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  int get subtotal =>
      product.finalPrice * quantity;

  String get productName =>
      product.name;

  int get price =>
      product.finalPrice;

  int? get productId =>
      product.id;
}

// class Product {
//   final String id;
//   final String name;
//   final int price;
//   final int? discountPrice;
//   final int stock;
//   final String? image;
//   final String category;

//   Product({
//     required this.id,
//     required this.name,
//     required this.price,
//     this.discountPrice,
//     required this.stock,
//     this.image,
//     required this.category,
//   });

//   int get finalPrice => discountPrice ?? price;
  
//   bool get hasDiscount => discountPrice != null && discountPrice != price;
// }