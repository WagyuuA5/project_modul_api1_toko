// ============================================================
// product_provider.dart — FIXED VERSION
// Endpoint: /admin/getbarang (bukan /admin/barang)
// Return: List<TokoModel> dengan field nama_barang, kategori, dll
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  // ⚠️ FIXED: endpoint /user/getbarang
  static const _base = 'https://learn.smktelkom-mlg.sch.id/toko/api';

  List<TokoModel> _products  = [];
  bool            _isLoading = false;
  String?         _error;

  List<TokoModel> get products  => List.unmodifiable(_products);
  bool            get isLoading => _isLoading;
  String?         get error     => _error;

  static Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token')
        ?? prefs.getString('token')
        ?? prefs.getString('auth_token');
  }

  Future<void> fetchProducts({bool forceRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _token();
      debugPrint('ProductProvider: token = ${token != null && token.length > 15 ? token.substring(0, 15) : token}...');
      debugPrint('ProductProvider: GET $_base/user/getbarang');

      final res = await http.get(
        Uri.parse('$_base/user/getbarang'),
        headers: {
          'Accept'       : 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('ProductProvider: status = ${res.statusCode}');

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        if (body['status'] == true) {
          final raw = body['data'] as List;
          _products = raw.map((e) => TokoModel.fromJson(e)).toList();
          _error = null;
          debugPrint('ProductProvider: loaded ${_products.length} items');
        } else {
          _error = body['message']?.toString() ?? 'Gagal load produk';
        }
      } else if (res.statusCode == 401) {
        _error = 'Sesi login kadaluarsa, silakan login ulang (401)';
      } else if (res.statusCode == 404) {
        _error = 'Endpoint tidak ditemukan (404)\nCek URL: $_base/user/getbarang';
      } else {
        _error = 'Server error: ${res.statusCode}';
      }
    } catch (e) {
      _error = 'Gagal koneksi: $e';
      debugPrint('ProductProvider error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => fetchProducts(forceRefresh: true);

  void removeById(String id) {
    _products.removeWhere((p) => p.id?.toString() == id);
    notifyListeners();
  }
}