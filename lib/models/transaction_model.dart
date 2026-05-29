import 'package:intl/intl.dart';

class TransactionModel {
  final String id;
  final String orderId;
  final DateTime date;
  final List<TransactionItem> items;
  final int totalAmount;
  final String paymentMethod;
  final String status;
  final String shippingAddress;
  final int shippingCost;

  TransactionModel({
    required this.id,
    required this.orderId,
    required this.date,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.shippingAddress,
    required this.shippingCost,
  });

  String get formattedTotal {
    return 'Rp ${NumberFormat('#,###', 'id_ID').format(totalAmount)}';
  }

  int get totalQuantity {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderId': orderId,
    'date': date.toIso8601String(),
    'items': items.map((i) => i.toJson()).toList(),
    'totalAmount': totalAmount,
    'paymentMethod': paymentMethod,
    'status': status,
    'shippingAddress': shippingAddress,
    'shippingCost': shippingCost,
  };

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      orderId: json['orderId'],
      date: DateTime.parse(json['date']),
      items: (json['items'] as List)
          .map((i) => TransactionItem.fromJson(i))
          .toList(),
      totalAmount: json['totalAmount'],
      paymentMethod: json['paymentMethod'],
      status: json['status'],
      shippingAddress: json['shippingAddress'] ?? '',
      shippingCost: json['shippingCost'] ?? 0,
    );
  }
}

class TransactionItem {
  final String productName;
  final int quantity;
  final int price;
  final String? imageUrl; // ← ADDED

  TransactionItem({
    required this.productName,
    required this.quantity,
    required this.price,
    this.imageUrl, // ← ADDED (nullable, backward-compatible)
  });

  int get subtotal => price * quantity;

  String get formattedPrice =>
      'Rp ${NumberFormat('#,###', 'id_ID').format(price)}';

  String get formattedSubtotal =>
      'Rp ${NumberFormat('#,###', 'id_ID').format(subtotal)}';

  Map<String, dynamic> toJson() => {
    'productName': productName,
    'quantity': quantity,
    'price': price,
    'imageUrl': imageUrl, // ← ADDED
  };

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      productName: json['productName'],
      quantity: json['quantity'],
      price: json['price'],
      imageUrl: json['imageUrl'], // ← ADDED (null-safe)
    );
  }
}
