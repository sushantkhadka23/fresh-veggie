import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductCategory {
  fruits,
  vegetables,
}

class ProductModel {
  final String productId;
  final String name;
  final double pricePerKg;
  final String description;
  final String sellerId;
  final ProductCategory category;
  final String origin;
  final String imageUrl;
  final Timestamp createdAt;
  final int stock;

  ProductModel({
    required this.productId,
    required this.name,
    required this.sellerId,
    required this.description,
    required this.origin,
    required this.category,
    required this.imageUrl,
    required this.pricePerKg,
    required this.createdAt,
    required this.stock,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'pricePerKg': pricePerKg,
      'description': description,
      'sellerId': sellerId,
      'category': category == ProductCategory.fruits ? 'fruits' : 'vegetables',
      'origin': origin,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'stock': stock,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['productId'],
      name: json['name'],
      sellerId: json['sellerId'],
      description: json['description'],
      origin: json['origin'],
      category: json['category'] == 'fruits'
          ? ProductCategory.fruits
          : ProductCategory.vegetables,
      imageUrl: json['imageUrl'],
      pricePerKg: json['pricePerKg'],
      createdAt: json['createdAt'],
      stock: json['stock'],
    );
  }
}
