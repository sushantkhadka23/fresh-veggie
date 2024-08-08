import 'package:flutter/material.dart';
import 'package:freshveggie/models/bag_model.dart';
import 'package:freshveggie/models/product_model.dart';
import 'package:freshveggie/pages/product_order_page.dart';
import 'package:freshveggie/services/alert_services.dart';
import 'package:freshveggie/services/auth_services.dart';
import 'package:freshveggie/services/firebase_service.dart';
import 'package:freshveggie/services/navigation_service.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class BagTab extends StatefulWidget {
  const BagTab({super.key});

  @override
  State<BagTab> createState() => _BagTabState();
}

class _BagTabState extends State<BagTab> {
  final GetIt _getIt = GetIt.instance;

  late AuthServices _authServices;
  late FirebaseService _firebaseService;
  late AlertServices _alertServices;
  late NavigationService _navigationService;

  @override
  void initState() {
    super.initState();
    _authServices = _getIt.get<AuthServices>();
    _firebaseService = _getIt.get<FirebaseService>();
    _alertServices = _getIt.get<AlertServices>();
    _navigationService = _getIt.get<NavigationService>();
  }

  Future<ProductModel?> _getProductDetails(String productId) {
    return _firebaseService.getProductDetails(productId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Bag',
          style: TextStyle(
            color: theme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.surface,
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return FutureBuilder<List<BagModel>>(
      future: _firebaseService.getUserBags(_authServices.user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Your bag is empty',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add some fresh products to your bag!',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        } else {
          final bags = snapshot.data!;
          return ListView.builder(
            itemCount: bags.length,
            itemBuilder: (context, index) {
              final bag = bags[index];
              return FutureBuilder<ProductModel?>(
                future: _getProductDetails(bag.productId),
                builder: (context, productSnapshot) {
                  if (productSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const ListTile(
                      title: CircularProgressIndicator.adaptive(),
                    );
                  } else if (productSnapshot.hasError) {
                    return Center(
                      child: Text('Error: ${productSnapshot.error}'),
                    );
                  } else if (!productSnapshot.hasData) {
                    return const Center(
                      child: Text('Product details not available'),
                    );
                  } else {
                    final product = productSnapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            _navigationService.push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductOrderPage(productModel: product),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.imageUrl,
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${product.category.toString().split('.').last.capitalize()} from ${product.origin}',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Rs.${product.pricePerKg.toStringAsFixed(2)} per kg',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Added on ${DateFormat('MMM d, yyyy').format(bag.dateOfPlaceToBag.toDate())}',
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () async {
                                    await _firebaseService.removeFromBag(
                                      _authServices.user!.uid,
                                      bag.productId,
                                    );
                                    _alertServices.showToast(
                                      message:
                                          '${product.name} is removed from bag!',
                                      icondata: Icons.done_all,
                                      color: Colors.green,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        }
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
