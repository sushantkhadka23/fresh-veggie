import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freshveggie/screens/otp_verification_screen.dart';
import 'package:freshveggie/services/auth_services.dart';
import 'package:freshveggie/services/navigation_service.dart';
import 'package:get_it/get_it.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _phoneNumberkey = GlobalKey<FormState>();
  PhoneNumber number = PhoneNumber();
  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;
  late AuthServices _authServices;

  @override
  void initState() {
    super.initState();
    _navigationService = _getIt.get<NavigationService>();
    _authServices = _getIt.get<AuthServices>();
  }

  void _sendOTPcode() async {
    if (_phoneNumberkey.currentState!.validate()) {
      String fullPhoneNumber = number.phoneNumber.toString();
      await _authServices.phoneNumberVerification(phoneNumber: fullPhoneNumber);
      _navigationService.push(
        MaterialPageRoute(
          builder: (context) =>
              OtpVerificationScreen(phoneNumber: fullPhoneNumber),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      body: _buildUI(theme),
    );
  }

  Widget _buildUI(ColorScheme theme) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _backButton(theme),
              const SizedBox(height: 32),
              _headerText(theme),
              const SizedBox(height: 48),
              _form(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backButton(ColorScheme theme) {
    return IconButton(
      icon: Icon(
        Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
        color: theme.onSurface,
      ),
      onPressed: () {
        _navigationService.goBack();
      },
    );
  }

  Widget _headerText(ColorScheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verify Your Phone',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: theme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "We'll send you a verification code to confirm your phone number.",
          style: TextStyle(
            fontSize: 16,
            color: theme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _form(ColorScheme theme) {
    return Form(
      key: _phoneNumberkey,
      child: Column(
        children: [
          InternationalPhoneNumberInput(
            onInputChanged: (PhoneNumber number) {
              this.number = number;
            },
            selectorConfig: const SelectorConfig(
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            ),
            ignoreBlank: false,
            autoValidateMode: AutovalidateMode.disabled,
            selectorTextStyle: TextStyle(color: theme.onSurfaceVariant),
            initialValue: PhoneNumber(isoCode: 'NP'),
            textFieldController: _phoneController,
            formatInput: true,
            keyboardType: const TextInputType.numberWithOptions(
              signed: true,
              decimal: true,
            ),
            inputDecoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  width: 1.5,
                  color: theme.onSurface,
                ),
              ),
              hintText: 'Phone Number',
              hintStyle:
                  TextStyle(color: theme.onSurfaceVariant.withOpacity(0.5)),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _sendOTPcode,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              'Get Verification Code',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.surface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
