// ============================================================
// product_service.dart — Full Update Version
// Endpoint field: nama_barang, kategori, harga, stok, image
// Auth: Bearer token dari SharedPreferences
// ============================================================

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class ProductService {
  static const String _base = 'https://learn.smktelkom-mlg.sch.id/toko/api';

  // ── Ambil token ─────────────────────────────────────────────────────────────
  static Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token') ?? prefs.getString('token');
  }

  static Map<String, String> _authHeader(String token) => {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  };

  // ── GET semua produk ────────────────────────────────────────────────────────
  Future<List<TokoModel>> getProducts() async {
    try {
      final token = await _token();
      final res = await http
          .get(
            Uri.parse('$_base/user/getbarang'),
            headers: {
              'Accept': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('GET user/getbarang → ${res.statusCode}');

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final raw = (body is Map)
            ? (body['data'] ?? body['barang'] ?? body['products'] ?? [])
            : body;
        return (raw as List)
            .map((e) => TokoModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Gagal load produk (${res.statusCode})');
    } catch (e) {
      debugPrint('getProducts error: $e');
      rethrow;
    }
  }

  // ── POST tambah produk ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>> addProduct({
    required String namaBarang,
    required String kategori,
    required int harga,
    required int stok,
    File? imageFile, // dari galeri/kamera
    String? imageUrl, // dari URL network
  }) async {
    final token = await _token();
    if (token == null || token.isEmpty) {
      return {
        'status': false,
        'message': 'Belum login / token tidak ditemukan',
      };
    }

    final req =
        http.MultipartRequest('POST', Uri.parse('$_base/admin/insertbarang'))
          ..headers.addAll(_authHeader(token))
          ..fields['nama_barang'] = namaBarang
          ..fields['kategori'] = kategori
          ..fields['harga'] = harga.toString()
          ..fields['stok'] = stok.toString();

    if (imageFile != null) {
      req.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      req.fields['image_url'] = imageUrl;
    }

    return _sendAndParse(req, 'POST /admin/insertbarang');
  }

  // ── POST update produk ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>> updateProduct({
    required String id,
    required String namaBarang,
    required String kategori,
    required int harga,
    required int stok,
    File? imageFile,
    String? imageUrl,
  }) async {
    final token = await _token();
    if (token == null || token.isEmpty) {
      return {
        'status': false,
        'message': 'Belum login / token tidak ditemukan',
      };
    }

    final req =
        http.MultipartRequest(
            'POST',
            Uri.parse('$_base/admin/updatebarang/$id'),
          )
          ..headers.addAll(_authHeader(token))
          ..fields['nama_barang'] = namaBarang
          ..fields['kategori'] = kategori
          ..fields['harga'] = harga.toString()
          ..fields['stok'] = stok.toString();

    if (imageFile != null) {
      req.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      req.fields['image_url'] = imageUrl;
    }

    return _sendAndParse(req, 'POST /admin/updatebarang/$id');
  }

  // ── DELETE hapus produk ─────────────────────────────────────────────────────
  Future<Map<String, dynamic>> deleteProduct(String id) async {
    final token = await _token();
    if (token == null || token.isEmpty) {
      return {
        'status': false,
        'message': 'Belum login / token tidak ditemukan',
      };
    }

    final res = await http
        .delete(
          Uri.parse('$_base/admin/hapusbarang/$id'),
          headers: _authHeader(token),
        )
        .timeout(const Duration(seconds: 15));

    debugPrint('DELETE /admin/hapusbarang/$id → ${res.statusCode}');
    debugPrint(res.body);

    try {
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return {
          'status': data['status'] ?? true,
          'message': data['message'] ?? 'Berhasil hapus',
        };
      }
      return {
        'status': false,
        'message': data['message'] ?? 'Gagal hapus (${res.statusCode})',
      };
    } catch (_) {
      return {
        'status': res.statusCode == 200,
        'message': 'Selesai (${res.statusCode})',
      };
    }
  }

  // ── Helper: send multipart & parse response ─────────────────────────────────
  Future<Map<String, dynamic>> _sendAndParse(
    http.MultipartRequest req,
    String label,
  ) async {
    try {
      final streamed = await req.send().timeout(const Duration(seconds: 25));
      final body = await http.Response.fromStream(streamed);

      debugPrint('$label → ${streamed.statusCode}');
      debugPrint(body.body);

      final data = jsonDecode(body.body);
      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        return {
          'status': data['status'] ?? true,
          'message': data['message'] ?? 'Berhasil',
        };
      }
      return {
        'status': false,
        'message': data['message'] ?? 'Gagal (${streamed.statusCode})',
      };
    } catch (e) {
      return {'status': false, 'message': 'Error: $e'};
    }
  }
}
