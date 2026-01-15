import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/exceptions.dart';
import '../utils/connectivity_helper.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const Duration timeout = Duration(seconds: 10);

  Future<dynamic> get(String endpoint) async {
    await _checkConnectivity();
    
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'))
          .timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    await _checkConnectivity();
    
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    await _checkConnectivity();
    
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> delete(String endpoint) async {
    await _checkConnectivity();
    
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl$endpoint'))
          .timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> _checkConnectivity() async {
    final isConnected = await ConnectivityHelper.hasConnection();
    if (!isConnected) {
      throw NetworkException('No hay conexión a internet');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw NotFoundException();
    } else if (response.statusCode >= 500) {
      throw ServerException();
    } else {
      throw ServerException('Error: ${response.statusCode}');
    }
  }

  AppException _handleError(dynamic error) {
    if (error is AppException) {
      return error;
    }
    return NetworkException('Error de red: $error');
  }
}
