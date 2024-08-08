import 'package:freshveggie/services/alert_services.dart';
import 'package:freshveggie/services/auth_services.dart';
import 'package:freshveggie/services/firebase_service.dart';
import 'package:freshveggie/services/navigation_service.dart';
import 'package:freshveggie/services/permisson_service.dart';
import 'package:freshveggie/services/storage_services.dart';
import 'package:get_it/get_it.dart';

Future<void> setupLocator() async {
  final GetIt getIt = GetIt.instance;

  getIt.registerSingleton<NavigationService>(
    NavigationService(),
  );

  getIt.registerSingleton<AuthServices>(
    AuthServices(),
  );

  getIt.registerSingleton<AlertServices>(
    AlertServices(),
  );

  getIt.registerSingleton<FirebaseService>(
    FirebaseService(),
  );

  getIt.registerSingleton<PermissionService>(
    PermissionService(),
  );

  getIt.registerSingleton<StorageServices>(
    StorageServices(),
  );
}
