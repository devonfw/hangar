import 'package:takeoff_lib/src/domain/cloud_provider.dart';

abstract class AuthController<T extends CloudProvider> {
  Future<bool> authenticate(String email);
}
