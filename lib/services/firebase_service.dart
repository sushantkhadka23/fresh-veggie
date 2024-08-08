import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freshveggie/models/bag_model.dart';
import 'package:freshveggie/models/order_model.dart';
import 'package:freshveggie/models/product_model.dart';
import 'package:freshveggie/models/user_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Creating collection for user's profile
  Future<void> addUser({
    required UserModel userModel,
  }) async {
    DocumentReference<Map<String, dynamic>> users =
        _firestore.collection('users').doc(userModel.userId);
    await users.set(userModel.toJson());
  }

  // Get users details
  Future<UserModel?> getUserDetails(String userId) async {
    DocumentReference docRef = _firestore.collection('users').doc(userId);
    DocumentSnapshot docSnapShot = await docRef.get();
    if (docSnapShot.exists) {
      return UserModel.fromJson(docSnapShot.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  // To add products
  Future<void> addProduct({
    required ProductModel productModel,
  }) async {
    DocumentReference<Map<String, dynamic>> products =
        _firestore.collection('products').doc(productModel.productId);
    await products.set(productModel.toJson());
  }

  // Get product details by ID
  Future<ProductModel?> getProductDetails(
    String productId,
  ) async {
    DocumentReference<Map<String, dynamic>> docRef =
        _firestore.collection('products').doc(productId);
    DocumentSnapshot<Map<String, dynamic>> docSnapShot = await docRef.get();
    if (docSnapShot.exists) {
      return ProductModel.fromJson(docSnapShot.data()!);
    } else {
      return null;
    }
  }

  //get product only of seller
  Future<List<ProductModel>> getUserProducts({
    required String sellerId,
  }) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .get();
      return querySnapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  // Get all product details but not of seller
  Future<List<ProductModel>> getAllProductDetails({
    required String sellerId,
  }) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
        .collection('products')
        .where('sellerId', isNotEqualTo: sellerId)
        .get();
    return querySnapshot.docs
        .map((doc) => ProductModel.fromJson(doc.data()))
        .toList();
  }

  // To place order
  Future<void> placeOrder({
    required OrderModel orderModel,
  }) async {
    DocumentReference<Map<String, dynamic>> orders =
        _firestore.collection('orders').doc(orderModel.orderId);
    await orders.set(orderModel.toJson());
  }

  // Get order details
  Future<OrderModel?> getOrderDetails({
    required String orderId,
  }) async {
    DocumentReference<Map<String, dynamic>> docRef =
        _firestore.collection('orders').doc(orderId);
    DocumentSnapshot<Map<String, dynamic>> docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      return OrderModel.fromJson(docSnapshot.data()!);
    } else {
      return null;
    }
  }

  // Get all orders for a user
  Future<List<OrderModel>> getUserOrders({
    required String userId,
  }) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .get();
    return querySnapshot.docs
        .map((doc) => OrderModel.fromJson(doc.data()))
        .toList();
  }

  // Update order status
  Future<void> updateOrderStatus({
    required String orderId,
    required ProductStatus newStatus,
  }) async {
    DocumentReference<Map<String, dynamic>> docRef =
        _firestore.collection('orders').doc(orderId);
    await docRef.update({
      'status': newStatus.toString().split('.').last,
    });
  }

  // Delete an order
  Future<void> deleteOrder({
    required String orderId,
  }) async {
    DocumentReference<Map<String, dynamic>> docRef =
        _firestore.collection('orders').doc(orderId);
    await docRef.delete();
  }

  Future<bool> checkItemExist({
    required BagModel bagModel,
    required String userId,
  }) async {
    CollectionReference<Map<String, dynamic>> bags =
        _firestore.collection('bags');

    // Query to check if the product already exists in the bag for the given user
    QuerySnapshot<Map<String, dynamic>> existingBagItems =
        await bags.where('productId', isEqualTo: bagModel.productId).get();

    // If product already exists, return true; otherwise, return false
    return existingBagItems.docs.isNotEmpty;
  }

  Future<void> addToBag({
    required String userId,
    required BagModel bagModel,
  }) async {
    bool itemExists = await checkItemExist(
      bagModel: bagModel,
      userId: userId,
    );

    // If the item does not exist, add it to the bag
    if (!itemExists) {
      CollectionReference<Map<String, dynamic>> bags =
          _firestore.collection('bags');

      // Add the new item to the bag with userId as part of the document
      await bags.add(bagModel.toJson());
    }
  }

  Future<List<BagModel>> getUserBags(String userId) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
        .collection('bags')
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs
        .map((doc) => BagModel.fromJson(doc.data()))
        .toList();
  }

  Future<void> removeFromBag(String userId, String productId) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
        .collection('bags')
        .where('userId', isEqualTo: userId)
        .where('productId', isEqualTo: productId)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }
}
