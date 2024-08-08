import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:freshveggie/services/auth_services.dart';
import 'package:freshveggie/services/alert_services.dart';
import 'package:freshveggie/services/navigation_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final GetIt _getIt = GetIt.instance;
  late AuthServices _authServices;
  late AlertServices _alertServices;
  late NavigationService _navigationService;

  final TextEditingController _otpController = TextEditingController();

  late String currentText;

  @override
  void initState() {
    super.initState();
    _authServices = _getIt.get<AuthServices>();
    _alertServices = _getIt.get<AlertServices>();
    _navigationService = _getIt.get<NavigationService>();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
    _resendOTP();
  }

  void _verifyOTP() async {
    String smsCode = _otpController.text.trim();
    if (smsCode.length == 6) {
      try {
        bool isVerify = await _authServices.verifyOtp(smsCode: smsCode);
        if (isVerify) {
          await _authServices.verifyOtp(smsCode: smsCode);
          _alertServices.showToast(
            message: "Phone number verified successfully!",
            color: Colors.green,
            icondata: Icons.check_circle,
          );
          _navigationService.pushNamed('/index');
        } else {
          _alertServices.showToast(
            message: "Code verification was unsuccessful. Please try again.",
            color: Colors.red,
            icondata: Icons.error,
          );
        }
      } catch (e) {
        _alertServices.showToast(
          message: e.toString(),
          color: Colors.red,
          icondata: Icons.error,
        );
      }
    } else {
      _alertServices.showToast(
        message: "Please enter a valid 6-digit OTP",
        color: Colors.orange,
        icondata: Icons.warning,
      );
    }
  }

  void _resendOTP() async {
    try {
      await _authServices.resendCode(
        phoneNumber: widget.phoneNumber,
        verificationFailed: (e) {
          _alertServices.showToast(
            message: 'Resend Verification Failed: ${e.message}',
            color: Colors.red,
            icondata: Icons.error,
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          _alertServices.showToast(
            message: 'Code Resent to ${widget.phoneNumber}',
            color: Colors.green,
            icondata: Icons.check_circle,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      _alertServices.showToast(
        message: 'Error: $e',
        color: Colors.red,
        icondata: Icons.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
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
                _otpForm(theme),
                const SizedBox(height: 24),
                _verifyButton(theme),
                const SizedBox(height: 16),
                _notifyText(theme),
                const SizedBox(height: 16),
                _resendButton(theme),
              ],
            ),
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
          'Enter OTP',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Please enter the 6-digit code sent to ${widget.phoneNumber}',
          style: TextStyle(
            fontSize: 16,
            color: theme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _otpForm(ColorScheme theme) {
    return PinCodeTextField(
      appContext: context,
      length: 6,
      obscureText: false,
      animationType: AnimationType.fade,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(10),
        fieldHeight: 50,
        fieldWidth: 50,
      ),
      animationDuration: const Duration(milliseconds: 300),
      controller: _otpController,
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          currentText = value;
        });
      },
    );
  }

  Widget _verifyButton(ColorScheme theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _verifyOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Verify OTP',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.surface,
          ),
        ),
      ),
    );
  }

  Widget _notifyText(ColorScheme theme) {
    return Center(
      child: Text(
        "Didn't receive code?",
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _resendButton(ColorScheme theme) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: _resendOTP,
        style: TextButton.styleFrom(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Resend Code',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.primary,
          ),
        ),
      ),
    );
  }
}
