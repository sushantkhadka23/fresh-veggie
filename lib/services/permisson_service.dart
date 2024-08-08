import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Check and request location permission
  Future<bool> getLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permission;

    serviceEnabled = await Permission.locationWhenInUse.serviceStatus.isEnabled;
    if (!serviceEnabled) {
      return false;
    }

    permission = await Permission.locationWhenInUse.status;
    if (permission == PermissionStatus.denied) {
      permission = await Permission.locationWhenInUse.request();
      if (permission == PermissionStatus.denied) {
        return false;
      }
    }

    if (permission == PermissionStatus.permanentlyDenied) {
      return false;
    }

    return true;
  }

  Future<bool> handleLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      // You can show a dialog here explaining why you need the permission
      var result = await Permission.location.request();
      return result.isGranted;
    } else {
      // Handle other cases, like Permission permanently denied, restricted, etc.
      return false;
    }
  }

  // Check and request notification permission
  Future<bool> handleNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;

    if (status.isDenied) {
      status = await Permission.notification.request();
    }

    return status.isGranted;
  }

  // Check and request camera permission
  Future<bool> handleCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;

    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    return status.isGranted;
  }

  // Check and request microphone permission
  Future<bool> handleMicrophonePermission() async {
    PermissionStatus status = await Permission.microphone.status;

    if (status.isDenied) {
      status = await Permission.microphone.request();
    }

    return status.isGranted;
  }

  // Check and request storage permission
  Future<bool> handleStoragePermission() async {
    PermissionStatus status = await Permission.storage.status;

    if (status.isDenied) {
      status = await Permission.storage.request();
    }

    return status.isGranted;
  }

  // Check and request multiple permissions at once
  Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
      List<Permission> permissions) async {
    return await permissions.request();
  }

  // Open app settings
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  //some permission are used although they are created.
}
