import 'package:takeoff_lib/src/domain/cloud_provider.dart';

/// Defines the interface of the authentication controllers for each Cloud Provider
abstract class AuthController<T extends CloudProvider> {
  Future<bool> authenticate(String email);
  Future<String> getCurrentAccount();
}
