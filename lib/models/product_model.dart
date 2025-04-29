import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String desc;
  final String category;
  final List<String> images;
  final double newPrice;
  final double oldPrice;
  final int quantity;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.desc,
    required this.category,
    required this.images,
    required this.newPrice,
    required this.oldPrice,
    required this.quantity,
    required this.createdAt,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      desc: data['desc'] ?? '',
      category: data['category'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      newPrice: (data['new_price'] ?? 0).toDouble(),
      oldPrice: (data['old_price'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 0,
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  // Added a complete toMap method
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'desc': desc,
      'category': category,
      'images': images,
      'new_price': newPrice,
      'old_price': oldPrice,
      'quantity': quantity,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}