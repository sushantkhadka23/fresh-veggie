import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:freshveggie/services/navigation_service.dart';
import 'package:get_it/get_it.dart';

class AlertServices {
  late NavigationService _navigationServices;

  AlertServices() {
    _navigationServices = GetIt.instance<NavigationService>();
  }

  void showToast({
    required String message,
    IconData icondata = Icons.info,
    Color color = Colors.blueGrey,
  }) {
    try {
      final context = _navigationServices.navigationKey.currentContext;
      if (context != null) {
        DelightToastBar(
          autoDismiss: true,
          position: DelightSnackbarPosition.top,
          animationDuration: const Duration(seconds: 1),
          snackbarDuration: const Duration(seconds: 3),
          builder: (context) => ToastCard(
            color: Theme.of(context).colorScheme.primaryContainer,
            leading: Icon(
              icondata,
              size: 24,
              color: color,
            ),
            title: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ).show(context);
      } else {}
    } catch (e) {
      rethrow;
    }
  }
}
