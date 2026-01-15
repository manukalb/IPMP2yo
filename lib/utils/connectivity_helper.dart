import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  static final Connectivity _connectivity = Connectivity();

  static Future<bool> hasConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi;
    } catch (e) {
      return false;
    }
  }

  static Stream<ConnectivityResult> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }

  static Future<bool> isMobileConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result == ConnectivityResult.mobile;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isWifiConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result == ConnectivityResult.wifi;
    } catch (e) {
      return false;
    }
  }
}
