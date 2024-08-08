import 'package:flutter/material.dart';
import 'package:freshveggie/pages/add_product_page.dart';
import 'package:freshveggie/pages/index.dart';
import 'package:freshveggie/pages/login_page.dart';
import 'package:freshveggie/screens/phone_verification_screen.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

  final Map<String, Widget Function(BuildContext)> routes = {
    '/login': (context) => const LoginPage(),
    '/index': (context) => const Index(),
    '/phoneverify': (context) => const PhoneVerificationScreen(),
    '/addproduct': (contex) => const AddProductPage(),
  };

  void pushNamed(String routeName) {
    navigationKey.currentState?.pushNamed(routeName);
  }

  void push(MaterialPageRoute route) {
    navigationKey.currentState?.push(route);
  }

  void pushReplacementNamed(String routeName) {
    navigationKey.currentState?.pushReplacementNamed(routeName);
  }

  void goBack() {
    navigationKey.currentState?.pop();
  }
}
