import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentMethod { eSewa, fonepay, cashOnDelivery }

enum ProductStatus { processing, shipped, delivered, cancelled }

class OrderModel {
  final String orderId;
  final String userId;
  final String productId;
  final double quantity;
  final double totalPrice;
  final PaymentMethod paymentMethod;
  final ProductStatus status;
  final Timestamp orderDate;
  final String deliveryAddress;
  final String phoneNumber;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.totalPrice,
    required this.paymentMethod,
    required this.status,
    required this.orderDate,
    required this.deliveryAddress,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'productId': productId,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod.name,
      'status': status.name,
      'orderDate': orderDate,
      'deliveryAddress': deliveryAddress,
      'phoneNumber': phoneNumber,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'] ?? '',
      userId: map['userId'] ?? '',
      productId: map['productId'] ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == map['paymentMethod'],
        orElse: () => PaymentMethod.cashOnDelivery,
      ),
      status: ProductStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ProductStatus.processing,
      ),
      orderDate: map['orderDate'] as Timestamp,
      deliveryAddress: map['deliveryAddress'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }
}
