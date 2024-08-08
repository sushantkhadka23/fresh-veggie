import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freshveggie/models/product_model.dart';
import 'package:freshveggie/services/alert_services.dart';
import 'package:freshveggie/services/auth_services.dart';
import 'package:freshveggie/services/firebase_service.dart';
import 'package:freshveggie/services/navigation_service.dart';
import 'package:freshveggie/services/storage_services.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final GlobalKey<FormState> _productKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  ProductCategory? _selectedCategory;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;
  late AuthServices _authServices;
  late AlertServices _alertServices;
  late StorageServices _storageServices;
  late FirebaseService _firebaseService;

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _originController.dispose();
    _priceController.dispose();
    _stockController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _authServices = _getIt.get<AuthServices>();
    _navigationService = _getIt.get<NavigationService>();
    _alertServices = _getIt.get<AlertServices>();
    _storageServices = _getIt.get<StorageServices>();
    _firebaseService = _getIt.get<FirebaseService>();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _saveProduct() async {
    if (_productKey.currentState!.validate() && _selectedImage != null) {
      String? imageUrl;

      String productId = const Uuid().v4();
      imageUrl = await _storageServices.uploadProductPicture(
        file: _selectedImage!,
        productId: productId,
      );
      final productModel = ProductModel(
        productId: productId,
        name: _nameController.text,
        sellerId: _authServices.user!.uid,
        description: _descriptionController.text,
        origin: _originController.text,
        category: _selectedCategory!,
        imageUrl: imageUrl,
        pricePerKg: double.parse(_priceController.text),
        createdAt: Timestamp.now(),
        stock: int.parse(_stockController.text),
      );
      await _firebaseService.addProduct(productModel: productModel);
      _nameController.clear();
      _descriptionController.clear();
      _originController.clear();
      _priceController.clear();
      _stockController.clear();
      setState(() {
        _selectedImage = null;
      });

      _alertServices.showToast(
        message: 'Your product has been successfully added.',
        icondata: Icons.done,
        color: Colors.green,
      );
      _navigationService.goBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            _navigationService.goBack();
          },
          icon: Icon(
            Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
            color: theme.onSurface,
          ),
        ),
        title: Text(
          'Add Product',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.onSurface,
          ),
        ),
      ),
      body: _buildUI(theme),
    );
  }

  Widget _buildUI(ColorScheme theme) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildForm(theme),
            const SizedBox(height: 20),
            _formSubmitButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(ColorScheme theme) {
    return Form(
      key: _productKey,
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: theme.primary),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _selectedImage == null
                  ? const Center(child: Text('Tap to add product image'))
                  : Image.file(_selectedImage!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 10),
          _buildCategoryDropdown(theme),
          const SizedBox(height: 10),
          _buildCustomTextFormField(
            controller: _nameController,
            labelText: 'Product Name',
            prefixIcon: Icons.shopping_basket,
            theme: theme,
          ),
          const SizedBox(height: 10),
          _buildCustomTextFormField(
            controller: _priceController,
            labelText: 'Price (Rs.)',
            prefixIcon: Icons.money,
            keyboardType: TextInputType.number,
            theme: theme,
          ),
          const SizedBox(height: 10),
          _buildCustomTextFormField(
            controller: _originController,
            labelText: 'Origin',
            prefixIcon: Icons.location_on,
            theme: theme,
          ),
          const SizedBox(height: 10),
          _buildCustomTextFormField(
            controller: _stockController,
            labelText: 'Stock',
            prefixIcon: Icons.inventory,
            keyboardType: TextInputType.number,
            theme: theme,
          ),
          const SizedBox(height: 10),
          _buildCustomTextFormField(
            controller: _descriptionController,
            labelText: 'Description',
            prefixIcon: Icons.description,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(ColorScheme theme) {
    return DropdownButtonFormField<ProductCategory>(
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
      ),
      value: _selectedCategory,
      items: ProductCategory.values
          .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category == ProductCategory.fruits
                    ? 'Fruits'
                    : 'Vegetables'),
              ))
          .toList(),
      onChanged: (category) {
        setState(() {
          _selectedCategory = category;
        });
      },
      validator: (value) => value == null ? 'Please select a category' : null,
    );
  }

  Widget _buildCustomTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required ColorScheme theme,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: Icon(prefixIcon),
        filled: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a valid $labelText';
        }
        return null;
      },
    );
  }

  Widget _formSubmitButton(ColorScheme theme) {
    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size(double.infinity, 55),
        backgroundColor: theme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.3),
        ),
      ),
      onPressed: _saveProduct,
      child: Text(
        'Save Product',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: theme.surface,
        ),
      ),
    );
  }
}
