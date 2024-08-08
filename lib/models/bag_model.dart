import 'package:cloud_firestore/cloud_firestore.dart';

class BagModel {
  final String productId;
  final String userId;
  final Timestamp dateOfPlaceToBag;

  BagModel({
    required this.productId,
    required this.userId,
    required this.dateOfPlaceToBag,
  });

  factory BagModel.fromJson(Map<String, dynamic> json) {
    return BagModel(
      productId: json['productId'] as String,
      userId: json['userId'] as String,
      dateOfPlaceToBag: json['dateOfPlaceToBag'] != null
          ? json['dateOfPlaceToBag'] as Timestamp
          : Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'userId': userId,
      'dateOfPlaceToBag': dateOfPlaceToBag,
    };
  }
}
