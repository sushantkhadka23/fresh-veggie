import 'dart:io';
import 'package:flutter/material.dart';
import 'package:freshveggie/const.dart';
import 'package:freshveggie/models/order_model.dart';
import 'package:freshveggie/models/product_model.dart';
import 'package:freshveggie/models/user_model.dart';
import 'package:freshveggie/services/alert_services.dart';
import 'package:freshveggie/services/auth_services.dart';
import 'package:freshveggie/services/firebase_service.dart';
import 'package:freshveggie/services/navigation_service.dart';
import 'package:freshveggie/services/permisson_service.dart';
import 'package:freshveggie/services/storage_services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _locationController = TextEditingController();

  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  final GetIt _getIt = GetIt.instance;
  late AuthServices _authServices;
  late PermissionService _permissionService;
  late FirebaseService _firebaseService;
  late StorageServices _storageServices;
  late AlertServices _alertServices;
  late NavigationService _navigationService;

  @override
  void initState() {
    super.initState();
    _authServices = _getIt.get<AuthServices>();
    _permissionService = _getIt.get<PermissionService>();
    _firebaseService = _getIt.get<FirebaseService>();
    _storageServices = _getIt.get<StorageServices>();
    _alertServices = _getIt.get<AlertServices>();
    _navigationService = _getIt.get<NavigationService>();
  }

  @override
  void dispose() {
    super.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _locationController.dispose();
  }

  void _getPicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _getLocation() async {
    bool isAllowed = await _permissionService.handleLocationPermission();
    if (isAllowed) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          setState(() {
            _locationController.text =
                '${place.locality}, ${place.street} ,${place.name}';
          });
        }
      } catch (e) {
        setState(() {
          _locationController.text = 'Location name not available';
        });
      }
    } else {
      setState(() {
        _locationController.text = '';
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      String? photoUrl;
      //first upload profile picture and get its url
      if (_selectedImage != null) {
        photoUrl = await _storageServices.uploadProfilePicture(
          file: _selectedImage!,
          uid: _authServices.user!.uid,
        );
      }

      final userModel = UserModel(
        userId: _authServices.user!.uid,
        fullName: _fullNameController.text,
        location: _locationController.text,
        phoneNumber: _phoneNumberController.text,
        email: _emailController.text,
        photoUrl: photoUrl ?? '',
      );
      await _firebaseService.addUser(userModel: userModel);
      _fullNameController.clear();
      _emailController.clear();
      _phoneNumberController.clear();
      _locationController.clear();
      setState(() {
        _selectedImage = null;
      });
      _alertServices.showToast(
        message: 'Your profile has been successfully updated',
        icondata: Icons.done,
        color: Colors.green,
      );
    }
  }

  Future<List<OrderModel>> _getUserOrders() async {
    return await _firebaseService.getUserOrders(
        userId: _authServices.user!.uid);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            _showEditProfileBottomSheet(context, theme);
          },
          icon: const Icon(Icons.edit),
        ),
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await _authServices.signOut();
              _navigationService.pushNamed('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    final theme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: _showUserDetails(theme),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _showUserDetails(ColorScheme theme) {
    return FutureBuilder(
      future: _firebaseService.getUserDetails(_authServices.user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Profile not set up yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the edit button to add your details!',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        } else {
          final UserModel user = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                CircleAvatar(
                  radius: MediaQuery.of(context).size.height * 0.08,
                  backgroundColor: theme.onSurface.withOpacity(0.4),
                  backgroundImage: user.photoUrl.isNotEmpty
                      ? NetworkImage(user.photoUrl)
                      : null,
                  child: user.photoUrl.isEmpty
                      ? Icon(Icons.person, size: 50, color: theme.onSurface)
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  user.fullName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                _buildListTile(
                  theme: theme,
                  icondata: Icons.email,
                  title: user.email,
                ),
                _buildListTile(
                  theme: theme,
                  icondata: Icons.phone,
                  title: user.phoneNumber,
                ),
                _buildListTile(
                  theme: theme,
                  icondata: Icons.location_on,
                  title: user.location,
                ),
                const SizedBox(height: 20),
                Text(
                  'Order History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.onSurface,
                  ),
                ),
                _buildOrderHistory(),
                Text(
                  'Your Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.onSurface,
                  ),
                ),
                _buildUserProducts(theme),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildOrderHistory() {
    return FutureBuilder<List<OrderModel>>(
      future: _getUserOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No order history available.'));
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              OrderModel order = snapshot.data![index];
              return ListTile(
                title: Text('Order #${order.orderId.substring(0, 8)}'),
                subtitle: Text('Status: ${order.status}'),
                trailing: Text('Rs.${order.totalPrice.toStringAsFixed(2)}'),
                onTap: () {
                  //  navigate to a detailed order page here
                },
              );
            },
          );
        }
      },
    );
  }

  Widget _buildListTile({
    required ColorScheme theme,
    required IconData icondata,
    required String title,
  }) {
    return ListTile(
      leading: Icon(
        icondata,
        color: theme.onSurface,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: theme.onSurface,
        ),
      ),
    );
  }

  void _showEditProfileBottomSheet(BuildContext context, ColorScheme theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          _getPicture();
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : null,
                          child: _selectedImage == null
                              ? const Icon(Icons.add_a_photo, size: 40)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildCustomTextFormField(
                        controller: _fullNameController,
                        labelText: 'Full Name',
                        prefixIcon: Icons.person,
                        regExp: fullNameRegEXP,
                        theme: theme,
                      ),
                      const SizedBox(height: 15),
                      _buildCustomTextFormField(
                        controller: _emailController,
                        labelText: 'Email',
                        prefixIcon: Icons.email,
                        regExp: emailRegEXP,
                        theme: theme,
                      ),
                      const SizedBox(height: 15),
                      _buildCustomTextFormField(
                        controller: _phoneNumberController,
                        labelText: 'Phone Number',
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        regExp: phoneRegEXP,
                        theme: theme,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCustomTextFormField(
                              controller: _locationController,
                              labelText: 'Location',
                              prefixIcon: Icons.location_on,
                              regExp: RegExp(
                                  r'^.+$'), // this alllows any non-empty string
                              theme: theme,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.my_location),
                            onPressed: () {
                              _getLocation();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          _saveChanges();
                          Navigator.of(context).pop();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.surface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserProducts(ColorScheme theme) {
    return FutureBuilder<List<ProductModel>>(
      future: _firebaseService.getUserProducts(
        sellerId: _authServices.user!.uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('You haven\'t added any products yet.'));
        } else {
          return SizedBox(
            height: 250, // Adjust height as needed
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                ProductModel product = snapshot.data![index];
                return Container(
                  width: 200, // Adjust width as needed
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(10)),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rs. ${product.pricePerKg.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: theme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Stock: ${product.stock} kg',
                                style: TextStyle(
                                  color: theme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildCustomTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required RegExp regExp,
    required ColorScheme theme,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    );
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: border,
        prefixIcon: Icon(prefixIcon),
        filled: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty || !regExp.hasMatch(value)) {
          return 'Please Enter valid $labelText';
        }
        return null;
      },
    );
  }
}
