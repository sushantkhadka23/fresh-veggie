// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fonepay_flutter/fonepay_flutter.dart';
import 'package:flutter/material.dart';
import 'package:esewa_flutter/esewa_flutter.dart';
import 'package:freshveggie/models/order_model.dart';
import 'package:freshveggie/models/product_model.dart';
import 'package:freshveggie/models/user_model.dart';
import 'package:freshveggie/services/auth_services.dart';
import 'package:freshveggie/services/firebase_service.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

class ProductOrderPage extends StatefulWidget {
  final ProductModel productModel;

  const ProductOrderPage({
    super.key,
    required this.productModel,
  });

  @override
  State<ProductOrderPage> createState() => _ProductOrderPageState();
}

class _ProductOrderPageState extends State<ProductOrderPage> {
  final int _currentStep = 1;
  String? _selectedPaymentMethod;
  double _quantity = 1.0;
  final double _deliveryFee = 50.0;

  UserModel? userModel;

  final GetIt _getIt = GetIt.instance;
  late AuthServices _authServices;
  late FirebaseService _firebaseService;

  @override
  void initState() {
    super.initState();
    _authServices = _getIt.get<AuthServices>();
    _firebaseService = _getIt.get<FirebaseService>();
    getUserDetails();
  }

  Future<void> getUserDetails() async {
    String userId = _authServices.user!.uid;
    UserModel? user = await _firebaseService.getUserDetails(userId);
    setState(() {
      userModel = user;
    });
  }

  void _placeOrder() async {
    double totalPrice =
        widget.productModel.pricePerKg * _quantity + _deliveryFee;
    PaymentMethod paymentMethod;
    ProductStatus status = ProductStatus.processing;

    if (_selectedPaymentMethod == 'eSewa') {
      paymentMethod = PaymentMethod.eSewa;
    } else if (_selectedPaymentMethod == 'Fonepay') {
      paymentMethod = PaymentMethod.fonepay;
    } else {
      paymentMethod = PaymentMethod.cashOnDelivery;
    }

    // process the order first
    _processOrder(totalPrice, paymentMethod, status);

    // thenn initiate payment
    if (_selectedPaymentMethod == 'eSewa') {
      _initiateESewaPayment();
    } else if (_selectedPaymentMethod == 'Fonepay') {
      _initiateFonepayPayment();
    } else {
      //will work on that later
    }
  }

  void _initiateESewaPayment() async {
    double totalPrice = widget.productModel.pricePerKg * _quantity +
        _deliveryFee; // Include delivery fee
    //this is just dummy since i donot have merchant account for esewa couldnt work in time for me
    //update later maybe not sure
    final result = await Esewa.i.init(
      context: context,
      eSewaConfig: ESewaConfig.dev(
        su: 'https://example.com/success',
        amt: totalPrice,
        fu: 'https://example.com/failure',
        pid:
            'PROD-${widget.productModel.name}-${DateTime.now().millisecondsSinceEpoch}',
        scd: 'EPAYTEST', //merachant code here but no merchant id
      ),
    );

    if (result.hasData) {
      final response = result.data!;
      // print('Payment Success: ${response.refId}');
    } else {
      // print('Payment Failure: ${result.error}');
    }
  }

  void _initiateFonepayPayment() async {
    double totalPrice =
        widget.productModel.pricePerKg * _quantity + _deliveryFee;
    final result = await FonePay.i.init(
      context: context,
      fonePayConfig: FonePayConfig.dev(
        amt: totalPrice,
        r2: 'https://example.com/success',
        ru: 'https://example.com/failure',
        r1: 'test',
        prn:
            'PROD-${widget.productModel.name}-${DateTime.now().millisecondsSinceEpoch}',
      ),
    );

    if (result.hasData) {
      final response = result.data!;
      // print('Payment Success: ${response.uid}');
    } else {
      // print('Payment Failure: ${result.error}');
    }
  }

  void _processOrder(
    double totalPrice,
    PaymentMethod paymentMethod,
    ProductStatus status,
  ) async {
    final orderId = const Uuid().v4();
    final userId = _authServices.user!.uid;
    final productId = widget.productModel.productId;

    final orderModel = OrderModel(
      orderId: orderId,
      userId: userId,
      productId: productId,
      quantity: _quantity,
      totalPrice: totalPrice,
      paymentMethod: paymentMethod,
      status: status,
      orderDate: Timestamp.now(),
      deliveryAddress: userModel!.location,
      phoneNumber: userModel!.phoneNumber,
    );

    await _firebaseService.placeOrder(orderModel: orderModel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //will be using timeline if i get time to submit
            _buildOrderTimeline(),
            _buildOrderDetails(),
            _buildDeliveryLocation(),
            _buildPaymentMethod(),
            _buildOrderSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTimeline() {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          _buildTimelineStep(
              1, 'Processing', Icons.shopping_cart, _currentStep >= 1),
          _buildLine(_currentStep >= 2),
          _buildTimelineStep(
              2, 'Shipping', Icons.local_shipping, _currentStep >= 2),
          _buildLine(_currentStep >= 3),
          _buildTimelineStep(3, 'Delivery', Icons.home, _currentStep >= 3),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
      int step, String title, IconData icon, bool isActive) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.green : Colors.grey,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.green : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLine(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      color: isActive ? Colors.green : Colors.grey,
    );
  }

  Widget _buildOrderDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListTile(
            leading: Image.network(widget.productModel.imageUrl,
                width: 50, height: 50),
            title: Text(widget.productModel.name),
            subtitle: Text('Rs ${widget.productModel.pricePerKg}/kg'),
            trailing: SizedBox(
              width: 100,
              child: TextFormField(
                initialValue: _quantity.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity (kg)',
                ),
                onChanged: (value) {
                  setState(() {
                    _quantity = double.tryParse(value) ?? 1.0;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryLocation() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Delivery Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(userModel?.location ?? 'Loading...'),
            subtitle: Text(userModel?.phoneNumber ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _buildListTile('eSewa', 'assets/images/esewa.png', 'eSewa'),
          _buildListTile('Fonepay', 'assets/images/fonepay.png', 'Fonepay'),
          _buildListTile('Cash on Delivery',
              'assets/images/cash_on_delivery.jpg', 'Cash on Delivery'),
        ],
      ),
    );
  }

  Widget _buildListTile(String value, String imagePath, String title) {
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            width: 30,
            height: 30,
          ),
          Radio<String>(
            value: value,
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value;
              });
            },
          ),
        ],
      ),
      title: Text(title),
    );
  }

  Widget _buildOrderSummary() {
    double itemTotal = widget.productModel.pricePerKg * _quantity;
    double totalPrice = itemTotal + _deliveryFee; // Include delivery fee

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListTile(
            title: const Text('Item Total'),
            trailing: Text('Rs $itemTotal'),
          ),
          ListTile(
            title: const Text('Delivery Fee'),
            trailing: Text('Rs $_deliveryFee'),
          ),
          const Divider(),
          ListTile(
            title: const Text('Total Price',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            trailing: Text('Rs $totalPrice',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(
                    double.infinity, MediaQuery.of(context).size.height * 0.06),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed:
                  _selectedPaymentMethod != null ? () => _placeOrder() : null,
              child: Text(
                'Place Order',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
