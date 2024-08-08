import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freshveggie/firebase_options.dart';
import 'package:freshveggie/services/auth_services.dart';
import 'package:freshveggie/services/navigation_service.dart';
import 'package:freshveggie/theme.dart';
import 'package:freshveggie/utils.dart';
import 'package:get_it/get_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupLocator();
  runApp(FreshVeggieApp());
}

// ignore: must_be_immutable
class FreshVeggieApp extends StatelessWidget {
  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;
  late AuthServices _authServices;

  FreshVeggieApp({
    super.key,
  }) {
    _navigationService = _getIt.get<NavigationService>();
    _authServices = _getIt.get<AuthServices>();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigationService.navigationKey,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: _authServices.user != null ? '/index' : '/login',
      routes: _navigationService.routes,
    );
  }
}
