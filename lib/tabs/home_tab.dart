import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freshveggie/models/bag_model.dart';
import 'package:freshveggie/pages/product_detail_page.dart';
import 'package:freshveggie/services/alert_services.dart';
import 'package:freshveggie/services/auth_services.dart';
import 'package:freshveggie/services/navigation_service.dart';
import 'package:freshveggie/services/firebase_service.dart';
import 'package:freshveggie/models/product_model.dart';
import 'package:get_it/get_it.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;
  late FirebaseService _firebaseService;
  late AuthServices _authServices;
  late AlertServices _alertServices;

  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _navigationService = _getIt.get<NavigationService>();
    _firebaseService = _getIt.get<FirebaseService>();
    _authServices = _getIt.get<AuthServices>();
    _alertServices = _getIt.get<AlertServices>();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    String sellerId = _authServices.user!.uid;
    final products = await _firebaseService.getAllProductDetails(
      sellerId: sellerId,
    );
    setState(() {
      _products = products;
      _filteredProducts = products;
    });
  }

  void _filterProducts(String query) {
    setState(() {
      _filteredProducts = _products.where((product) {
        final isMatch =
            product.name.toLowerCase().contains(query.toLowerCase());
        final isCategoryMatch = _selectedCategory == 'All' ||
            product.category.toString().split('.').last.toLowerCase() ==
                _selectedCategory.toLowerCase();
        return isMatch && isCategoryMatch;
      }).toList();
    });
  }

  void _addToBag(ProductModel productModel) async {
    final userId = _authServices.user!.uid;

    final bagModel = BagModel(
      productId: productModel.productId,
      dateOfPlaceToBag: Timestamp.now(),
      userId: userId,
    );

    await _firebaseService.addToBag(
      bagModel: bagModel,
      userId: userId,
    );

    _alertServices.showToast(
      message: '${productModel.name} added to bag!',
      icondata: Icons.done,
      color: Colors.teal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Column(
        children: [
          _buildSearchBar(),
          _buildCategories(),
          Expanded(
            child: _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.secondary,
        width: 2,
      ),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: Colors.transparent,
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Autocomplete<ProductModel>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<ProductModel>.empty();
          }
          return _products.where((ProductModel product) {
            return product.name
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase());
          });
        },
        displayStringForOption: (ProductModel option) {
          return option.name;
        },
        onSelected: (ProductModel selection) {
          _searchController.text = selection.name;
          _filterProducts(selection.name);
        },
        fieldViewBuilder: (BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted) {
          return TextFormField(
            controller: textEditingController,
            focusNode: focusNode,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.secondary,
              ),
              hintText: 'Search for a product',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: border,
              focusedBorder: focusedBorder,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (value) {
              _filterProducts(value);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip('All'),
          _buildCategoryChip('Fruits'),
          _buildCategoryChip('Vegetables'),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(
          category,
        ),
        selected: _selectedCategory == category,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
            _filterProducts(_searchController.text);
          });
        },
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        selectedColor: Colors.green,
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildProductCard(_filteredProducts[index]);
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () {
        _navigationService.push(
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(productModel: product),
          ),
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(product.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs. ${product.pricePerKg.toStringAsFixed(2)} / kg',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _addToBag(product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        'Add to Bag',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        _navigationService.pushNamed('/addproduct');
      },
      backgroundColor: Theme.of(context).colorScheme.secondary,
      child: FaIcon(
        FontAwesomeIcons.basketShopping,
        color: Theme.of(context).colorScheme.onSecondary,
      ),
    );
  }
}
