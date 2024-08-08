import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freshveggie/services/alert_services.dart';
import 'package:freshveggie/services/auth_services.dart';
import 'package:get_it/get_it.dart';
import 'package:freshveggie/services/navigation_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GetIt _getIt = GetIt.instance;
  late AuthServices _authServices;
  late NavigationService _navigationService;
  late AlertServices _alertServices;

  @override
  void initState() {
    super.initState();
    _authServices = _getIt.get<AuthServices>();
    _navigationService = _getIt.get<NavigationService>();
    _alertServices = _getIt.get<AlertServices>();
  }

  void _continueWithPhoneNumber() {
    _navigationService.pushNamed('/phoneverify');
  }

  void _continueWithGoogle() async {
    try {
      bool isConnectGoogle = await _authServices.signInWithGoogle();
      if (isConnectGoogle) {
        _alertServices.showToast(
          message: 'Signed in with Google successfully!',
          icondata: Icons.check_circle,
          color: Colors.green,
        );
        _navigationService.pushReplacementNamed('/index');
      } else {
        _alertServices.showToast(
          message: 'Signed in with Google is unsuccessfully!',
          icondata: Icons.error,
          color: Colors.red,
        );
      }
    } catch (e) {
      _alertServices.showToast(
        message: e.toString(),
        icondata: Icons.error_outline,
        color: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/mobile-phone.png',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.primary.withOpacity(0.6),
                  theme.secondary.withOpacity(0.8),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  Text(
                    'Welcome to',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: theme.surface,
                    ),
                  ),
                  Text(
                    'FreshVeggie!',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: theme.surface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Get fresh vegetables delivered to your doorstep',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.surface,
                    ),
                  ),
                  const Spacer(),
                  _buildLoginButton(
                    icon: FontAwesomeIcons.phone,
                    label: 'Continue with Phone Number',
                    onPressed: _continueWithPhoneNumber,
                    iconColor: Colors.grey,
                    theme: theme,
                  ),
                  const SizedBox(height: 16),
                  _buildLoginButton(
                    icon: FontAwesomeIcons.google,
                    label: 'Continue with Google',
                    onPressed: _continueWithGoogle,
                    iconColor: Colors.red,
                    theme: theme,
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ColorScheme theme,
    Color? iconColor,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.surface,
        foregroundColor: theme.onSurface,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.4),
        ),
        elevation: 4,
      ),
      icon: FaIcon(icon, color: iconColor ?? theme.primary),
      onPressed: onPressed,
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
