import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/models/user_login.dart';
import 'package:flutter_application_1/models/response_data_map.dart';
import 'package:flutter_application_1/services/url.dart';

class UserService {
  Future<ResponseDataMap> registerUser(Map<String, dynamic> data) async {
    try {
      print('Registering user with data: $data');
      
      final uri = Uri.parse('$BaseUrl/auth/register');
      final response = await http.post(
        uri,
        body: data,
        headers: {
          'Accept': 'application/json',
        },
      );

      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['status'] == true) {
          return ResponseDataMap(
            status: true,
            message: responseData['message'] ?? 'Registration successful',
            data: responseData,
          );
        } else {
          String errorMessage = 'Registration failed';
          if (responseData.containsKey('message')) {
            if (responseData['message'] is Map) {
              errorMessage = '';
              responseData['message'].forEach((key, value) {
                if (value is List) {
                  errorMessage += '${value.join(", ")}\n';
                } else {
                  errorMessage += '$value\n';
                }
              });
            } else {
              errorMessage = responseData['message'].toString();
            }
          }
          return ResponseDataMap(
            status: false,
            message: errorMessage,
            data: responseData,
          );
        }
      } else {
        return ResponseDataMap(
          status: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in registerUser: $e');
      return ResponseDataMap(
        status: false,
        message: 'Network error: $e',
      );
    }
  }
  Future<ResponseDataMap> loginUser(Map<String, dynamic> data) async {
    try {
      print('Logging in with data: $data');
      
      final uri = Uri.parse('$BaseUrl/auth/login');
      final response = await http.post(
        uri,
        body: data,
        headers: {
          'Accept': 'application/json',
        },
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['status'] == true) {
          UserLogin userLogin = UserLogin(
            nama: responseData['user']?['nama'] ?? 
                  responseData['user']?['nama_user'] ?? 
                  responseData['user']?['name'] ?? 
                  responseData['data']?['name'] ?? '',
            email: responseData['user']?['email'] ?? responseData['data']?['email'] ?? '',
            role: responseData['user']?['role'] ?? responseData['data']?['role'] ?? 'user',
          );

          // Save to shared preferences
          await userLogin.saveToPrefs();
          print('User saved to preferences: ${userLogin.nama}');
          
          return ResponseDataMap(
            status: true,
            message: responseData['message'] ?? 'Login successful',
            data: responseData,
          );
        } else {
          return ResponseDataMap(
            status: false,
            message: responseData['message'] ?? 'Invalid credentials',
            data: responseData,
          );
        }
      } else if (response.statusCode == 401) {
        return ResponseDataMap(
          status: false,
          message: 'Invalid email or password',
        );
      } else if (response.statusCode == 422) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        String errorMessage = 'Validation failed';
        if (responseData.containsKey('errors')) {
          responseData['errors'].forEach((key, value) {
            if (value is List) {
              errorMessage += '\n$key: ${value.join(', ')}';
            }
          });
        }
        return ResponseDataMap(
          status: false,
          message: errorMessage,
          data: responseData,
        );
      } else {
        return ResponseDataMap(
          status: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in loginUser: $e');
      return ResponseDataMap(
        status: false,
        message: 'Network error: $e',
      );
    }
  }
}