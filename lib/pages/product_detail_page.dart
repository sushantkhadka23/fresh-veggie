import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freshveggie/models/bag_model.dart';
import 'package:freshveggie/models/product_model.dart';
import 'package:freshveggie/pages/product_order_page.dart';
import 'package:freshveggie/services/alert_services.dart';
import 'package:freshveggie/services/auth_services.dart';
import 'package:freshveggie/services/firebase_service.dart';
import 'package:freshveggie/services/navigation_service.dart';
import 'package:get_it/get_it.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel productModel;
  const ProductDetailPage({
    super.key,
    required this.productModel,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;
  late FirebaseService _firebaseService;
  late AlertServices _alertServices;
  late AuthServices _authServices;

  @override
  void initState() {
    super.initState();
    _navigationService = _getIt.get<NavigationService>();
    _firebaseService = _getIt.get<FirebaseService>();
    _alertServices = _getIt.get<AlertServices>();
    _authServices = _getIt.get<AuthServices>();
  }

  void _addToBag() async {
    final userId = _authServices.user!.uid;
    final bagModel = BagModel(
      productId: widget.productModel.productId,
      dateOfPlaceToBag: Timestamp.now(),
      userId: userId,
    );

    await _firebaseService.addToBag(
      bagModel: bagModel,
      userId: userId,
    );
    _alertServices.showToast(
      message: '${widget.productModel.name} added to bag!',
      icondata: Icons.shop,
      color: Colors.green,
    );
    _navigationService.goBack();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      // backgroundColor: _dominantColor,
      appBar: _buildAppBar(theme),
      body: _buildUI(),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  AppBar _buildAppBar(ColorScheme theme) {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(
          Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
          color: theme.onSurface,
        ),
      ),
      title: Text(
        widget.productModel.name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.onSurface,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildUI() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),
          _buildProductInfo(),
          _buildDescription(),
          _buildOrigin(),
          _buildStock(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(widget.productModel.imageUrl),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.productModel.name,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.productModel.category
                      .toString()
                      .split('.')
                      .last
                      .toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Rs ${widget.productModel.pricePerKg.toStringAsFixed(2)}/kg',
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.productModel.description,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildOrigin() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            'Origin: ${widget.productModel.origin}',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildStock() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Icon(Icons.inventory, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            'In Stock: ${widget.productModel.stock} kg',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ColorScheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _addToBag,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary.withOpacity(0.8),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Add to Bag',
                style: TextStyle(
                  color: theme.surface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _navigationService.push(
                  MaterialPageRoute(
                    builder: (context) => ProductOrderPage(
                      productModel: widget.productModel,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.secondary.withOpacity(0.6),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Proceed to buy',
                style: TextStyle(
                  color: theme.surface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
