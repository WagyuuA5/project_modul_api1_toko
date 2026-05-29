// ============================================================
// product_management.dart — FIXED VERSION
// Fix: endpoint /admin/getbarang (bukan /admin/barang)
// Fix: image URL = baseUrl/storage/ + path dari API
// Fix: insert /admin/insertbarang, delete /admin/deletebarang/:id
// ============================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ── Konstanta ─────────────────────────────────────────────────────────────────
// ⚠️ BASE URL tanpa slash di akhir
const String kBaseUrl = 'https://learn.smktelkom-mlg.sch.id/toko/api';

// ⚠️ Prefix untuk gambar — sesuaikan jika server pakai /storage/
// Coba salah satu:
//   Option A: '$kBaseUrl/storage/'       → jika Laravel pakai storage link
//   Option B: '$kBaseUrl/'               → jika path sudah lengkap dari root
//   Option C: 'https://learn.smktelkom-mlg.sch.id/' → tanpa /api
const String kImagePrefix = 'https://learn.smktelkom-mlg.sch.id/';

// ── Warna ─────────────────────────────────────────────────────────────────────
const _kGreen     = Color(0xFF2E7D32);
const _kSoftGreen = Color(0xFFE8F5E9);
const _kBg        = Color(0xFFF8FAF8);
const _kTextDark  = Color(0xFF1B1B1B);
const _kTextGrey  = Color(0xFF9E9E9E);

// ── Format Rupiah ─────────────────────────────────────────────────────────────
String _fmtRp(int v) =>
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(v);

int _parseHarga(String s) =>
    int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

class _RupiahFmt extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    final digits = n.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return n.copyWith(text: '');
    final fmt = NumberFormat('#,###', 'id_ID').format(int.parse(digits));
    return TextEditingValue(
        text: fmt, selection: TextSelection.collapsed(offset: fmt.length));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HELPER: build full image URL dari path API
// API return: "images/1778208109-xxx.jpg"
// Kita butuh: "https://learn.smktelkom-mlg.sch.id/images/1778208109-xxx.jpg"
// ══════════════════════════════════════════════════════════════════════════════
String buildImageUrl(String? path) {
  if (path == null || path.trim().isEmpty) return '';
  // Kalau sudah full URL, langsung pakai
  if (path.startsWith('http')) return path;
  // Gabungkan prefix + path
  return '$kImagePrefix$path';
}

// ══════════════════════════════════════════════════════════════════════════════
// MODEL
// ══════════════════════════════════════════════════════════════════════════════
class BarangModel {
  final int    id;
  final String namaBarang;
  final int    harga;
  final int    stok;
  final String? imagePath;   // path mentah dari API, misal "images/xxx.jpg"
  final String? deskripsi;
  final String? kategori;

  BarangModel({
    required this.id,
    required this.namaBarang,
    required this.harga,
    required this.stok,
    this.imagePath,
    this.deskripsi,
    this.kategori,
  });

  // Full URL gambar siap dipakai Image.network
  String get imageUrl => buildImageUrl(imagePath);

  String get formattedHarga => _fmtRp(harga);
  bool get isLowStock   => stok > 0 && stok < 10;
  bool get isOutOfStock => stok <= 0;

  factory BarangModel.fromJson(Map<String, dynamic> j) => BarangModel(
    id         : _toInt(j['id']) ?? 0,
    namaBarang : j['nama_barang']?.toString() ?? '',
    harga      : _toInt(j['harga']) ?? 0,
    stok       : _toInt(j['stok'])  ?? 0,
    imagePath  : j['image']?.toString(),
    deskripsi  : j['deskripsi']?.toString(),
    kategori   : j['kategori']?.toString(),
  );

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString());
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// API SERVICE — semua endpoint di satu tempat
// ══════════════════════════════════════════════════════════════════════════════
class BarangApiService {

  // ── Ambil token dari SharedPreferences ─────────────────────────────────────
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    // Coba semua kemungkinan key yang pernah dipakai
    return prefs.getString('user_token')
        ?? prefs.getString('token')
        ?? prefs.getString('auth_token');
  }

  static Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Accept'       : 'application/json',
  };

  // ════════════════════════════════════════════════════════════════════════════
  // GET /admin/getbarang   ← FIXED endpoint (bukan /admin/barang)
  // ════════════════════════════════════════════════════════════════════════════
  static Future<List<BarangModel>> getBarang() async {
    final token = await _getToken();

    debugPrint('═══ GET BARANG ═══');
    debugPrint('URL   : $kBaseUrl/admin/getbarang');
    debugPrint('Token : ${token?.substring(0, 20)}...');

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan — silakan login ulang');
    }

    final res = await http.get(
      Uri.parse('$kBaseUrl/admin/getbarang'),   // ← FIXED
      headers: _headers(token),
    ).timeout(const Duration(seconds: 15));

    debugPrint('Status : ${res.statusCode}');
    debugPrint('Body   : ${res.body.substring(0, res.body.length.clamp(0, 200))}');

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['status'] == true) {
        final raw = body['data'] as List;
        return raw.map((e) => BarangModel.fromJson(e)).toList();
      }
      throw Exception(body['message'] ?? 'Gagal load barang');
    } else if (res.statusCode == 401) {
      throw Exception('Token kadaluarsa — silakan login ulang (401)');
    } else if (res.statusCode == 404) {
      throw Exception('Endpoint tidak ditemukan (404) — cek URL API');
    } else {
      throw Exception('Gagal load barang (${res.statusCode})');
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // POST /admin/insertbarang  (multipart/form-data)
  // ════════════════════════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> insertBarang({
    required String namaBarang,
    required String kategori,
    required int    harga,
    required int    stok,
    String?         deskripsi,
    File?           imageFile,   // dari galeri/kamera
    String?         imageUrl,    // dari URL network
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return {'status': false, 'message': 'Token tidak ditemukan'};
    }

    debugPrint('═══ INSERT BARANG ═══');
    debugPrint('URL : $kBaseUrl/admin/insertbarang');

    final req = http.MultipartRequest(
      'POST',
      Uri.parse('$kBaseUrl/admin/insertbarang'),
    )
      ..headers.addAll(_headers(token))
      ..fields['nama_barang'] = namaBarang
      ..fields['kategori']    = kategori
      ..fields['harga']       = harga.toString()
      ..fields['stok']        = stok.toString();

    if (deskripsi != null && deskripsi.isNotEmpty) {
      req.fields['deskripsi'] = deskripsi;
    }

    // Prioritas: file asli > URL
    if (imageFile != null) {
      req.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      debugPrint('Image : file ${imageFile.path}');
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      req.fields['image_url'] = imageUrl;
      debugPrint('Image : url $imageUrl');
    }

    return _sendAndParse(req, 'insertbarang');
  }

  // ════════════════════════════════════════════════════════════════════════════
  // POST /admin/updatebarang/:id  (multipart/form-data)
  // ════════════════════════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> updateBarang({
    required int    id,
    required String namaBarang,
    required String kategori,
    required int    harga,
    required int    stok,
    String?         deskripsi,
    File?           imageFile,
    String?         imageUrl,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return {'status': false, 'message': 'Token tidak ditemukan'};
    }

    debugPrint('═══ UPDATE BARANG $id ═══');

    final req = http.MultipartRequest(
      'POST',
      Uri.parse('$kBaseUrl/admin/updatebarang/$id'),
    )
      ..headers.addAll(_headers(token))
      ..fields['nama_barang'] = namaBarang
      ..fields['kategori']    = kategori
      ..fields['harga']       = harga.toString()
      ..fields['stok']        = stok.toString();

    if (deskripsi != null && deskripsi.isNotEmpty) {
      req.fields['deskripsi'] = deskripsi;
    }
    if (imageFile != null) {
      req.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      req.fields['image_url'] = imageUrl;
    }

    return _sendAndParse(req, 'updatebarang/$id');
  }

  // ════════════════════════════════════════════════════════════════════════════
  // DELETE /admin/deletebarang/:id  ← coba juga /hapusbarang/:id
  // ════════════════════════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> deleteBarang(int id) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return {'status': false, 'message': 'Token tidak ditemukan'};
    }

    debugPrint('═══ DELETE BARANG $id ═══');

    // Coba endpoint deletebarang dulu, fallback ke hapusbarang
    final endpoints = [
      '$kBaseUrl/admin/deletebarang/$id',
      '$kBaseUrl/admin/hapusbarang/$id',
    ];

    for (final url in endpoints) {
      debugPrint('Trying DELETE $url');
      try {
        final res = await http.delete(
          Uri.parse(url),
          headers: _headers(token),
        ).timeout(const Duration(seconds: 15));

        debugPrint('Status: ${res.statusCode}  Body: ${res.body}');

        if (res.statusCode == 200 || res.statusCode == 201) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          return {'status': data['status'] ?? true, 'message': data['message'] ?? 'Berhasil dihapus'};
        } else if (res.statusCode == 404) {
          // Endpoint ini 404, coba yang berikutnya
          continue;
        } else {
          return {'status': false, 'message': 'Gagal hapus (${res.statusCode})'};
        }
      } catch (_) {
        continue;
      }
    }

    return {'status': false, 'message': 'Endpoint hapus tidak ditemukan'};
  }

  // ── Helper: kirim multipart & parse response ────────────────────────────────
  static Future<Map<String, dynamic>> _sendAndParse(
      http.MultipartRequest req, String label) async {
    try {
      final streamed = await req.send().timeout(const Duration(seconds: 25));
      final body     = await http.Response.fromStream(streamed);

      debugPrint('$label → ${streamed.statusCode}');
      debugPrint(body.body);

      final data = jsonDecode(body.body) as Map<String, dynamic>;

      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        return {'status': data['status'] ?? true, 'message': data['message'] ?? 'Berhasil'};
      }
      return {'status': false, 'message': data['message'] ?? 'Gagal (${streamed.statusCode})'};
    } catch (e) {
      return {'status': false, 'message': 'Network error: $e'};
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HALAMAN UTAMA
// ══════════════════════════════════════════════════════════════════════════════
class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});
  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  List<BarangModel> _products  = [];
  bool              _loading   = false;
  String?           _error;

  final TextEditingController _search = TextEditingController();
  String _cat    = 'Semua';
  String _sortBy = 'Terbaru';

  final _cats  = ['Semua', 'Makanan', 'Minuman', 'Elektronik', 'Kebutuhan Rumah'];
  final _sorts = ['Terbaru', 'Harga Terendah', 'Harga Tertinggi', 'Stok Terbanyak', 'Nama A-Z'];

  // ── Filter + sort ────────────────────────────────────────────────────────────
  List<BarangModel> get _filtered {
    var list = _products.toList();
    final q  = _search.text.toLowerCase();

    if (q.isNotEmpty) {
      list = list.where((p) =>
          p.namaBarang.toLowerCase().contains(q) ||
          (p.kategori ?? '').toLowerCase().contains(q)).toList();
    }
    if (_cat != 'Semua') {
      list = list.where((p) => p.kategori == _cat).toList();
    }
    switch (_sortBy) {
      case 'Harga Terendah':  list.sort((a, b) => a.harga.compareTo(b.harga));           break;
      case 'Harga Tertinggi': list.sort((a, b) => b.harga.compareTo(a.harga));           break;
      case 'Stok Terbanyak':  list.sort((a, b) => b.stok.compareTo(a.stok));             break;
      case 'Nama A-Z':        list.sort((a, b) => a.namaBarang.compareTo(b.namaBarang)); break;
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
    _loadData();
  }

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  // ── Load data dari API ────────────────────────────────────────────────────────
  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await BarangApiService.getBarang();
      setState(() => _products = list);
    } catch (e) {
      setState(() => _error = e.toString());
      debugPrint('Load error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  // ── Buka form tambah / edit ───────────────────────────────────────────────────
  void _openForm({BarangModel? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BarangFormSheet(
        existing: existing,
        onSaved : _loadData,
      ),
    );
  }

  // ── Dialog konfirmasi hapus ───────────────────────────────────────────────────
  void _confirmDelete(BarangModel p) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        // Icon hapus
        title: Row(children: [
          Container(width: 36, height: 36,
              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.delete_outline_rounded, color: Colors.red[500], size: 20)),
          const SizedBox(width: 10),
          const Text('Hapus Produk', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ]),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: _kTextDark, height: 1.5),
            children: [
              const TextSpan(text: 'Apakah kamu yakin ingin menghapus\n'),
              TextSpan(
                text: '"${p.namaBarang}"',
                style: const TextStyle(fontWeight: FontWeight.w800, color: _kGreen),
              ),
              const TextSpan(text: '?\n\nTindakan ini tidak dapat dibatalkan.'),
            ],
          ),
        ),
        actions: [
          // Tombol batal
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Batal', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
          ),
          // Tombol hapus
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _toast('Menghapus ${p.namaBarang}...');

              final result = await BarangApiService.deleteBarang(p.id);

              if (result['status'] == true) {
                _toast('✅ ${p.namaBarang} berhasil dihapus');
                _loadData(); // refresh dari API
              } else {
                _toast('❌ Gagal hapus: ${result['message']}');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[500],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 0,
            ),
            child: const Text('Ya, Hapus!', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: _kGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(milliseconds: 2200),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: const Text('Kelola Produk',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: _kGreen, foregroundColor: Colors.white, elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loading ? null : _loadData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, size: 28),
            onPressed: () => _openForm(),
            tooltip: 'Tambah',
          ),
        ],
      ),
      body: Column(children: [
        // ── Stat bar ──────────────────────────────────────────────────────────
        Container(
          color: _kGreen,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Row(children: [
            _statChip('${_products.length}', 'Total', Icons.inventory_2_rounded),
            const SizedBox(width: 8),
            _statChip('${_products.where((p) => p.stok > 0).length}', 'Tersedia', Icons.check_circle_rounded),
            const SizedBox(width: 8),
            _statChip('${_products.where((p) => p.isLowStock).length}', 'Menipis', Icons.warning_amber_rounded),
            const SizedBox(width: 8),
            _statChip('${_products.where((p) => p.isOutOfStock).length}', 'Habis', Icons.cancel_rounded),
          ]),
        ),

        // ── Search + filter ────────────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            // Search bar
            Container(
              height: 46,
              decoration: BoxDecoration(
                color: _kBg, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kSoftGreen, width: 1.5),
              ),
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: 'Cari produk...',
                  hintStyle: const TextStyle(color: _kTextGrey, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: _kTextGrey, size: 20),
                  suffixIcon: _search.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () { _search.clear(); setState(() {}); })
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Kategori chips
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _cats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final on = _cat == _cats[i];
                  return GestureDetector(
                    onTap: () => setState(() => _cat = _cats[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: on ? _kGreen : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_cats[i], style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: on ? Colors.white : Colors.grey[600])),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Sort
            Row(children: [
              const Icon(Icons.sort_rounded, size: 16, color: _kTextGrey),
              const SizedBox(width: 6),
              const Text('Urutkan:', style: TextStyle(fontSize: 12, color: _kTextGrey)),
              const SizedBox(width: 8),
              Expanded(child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: _sorts.map((s) {
                  final on = _sortBy == s;
                  return GestureDetector(
                    onTap: () => setState(() => _sortBy = s),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: on ? _kSoftGreen : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: on ? _kGreen : Colors.grey[300]!),
                      ),
                      child: Text(s, style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: on ? _kGreen : Colors.grey[500])),
                    ),
                  );
                }).toList()),
              )),
            ]),
          ]),
        ),

        // ── List produk ────────────────────────────────────────────────────────
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: _kGreen))
              : _error != null
                  ? _errorState()
                  : list.isEmpty
                      ? _emptyState()
                      : RefreshIndicator(
                          color: _kGreen,
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(14),
                            itemCount: list.length,
                            itemBuilder: (_, i) => _BarangTile(
                              item    : list[i],
                              onEdit  : () => _openForm(existing: list[i]),
                              onDelete: () => _confirmDelete(list[i]),
                            ),
                          ),
                        ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: _kGreen, foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Produk', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _statChip(String v, String lbl, IconData ic) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Icon(ic, color: Colors.white, size: 16),
        const SizedBox(height: 2),
        Text(v, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
        Text(lbl, style: const TextStyle(color: Colors.white70, fontSize: 9)),
      ]),
    ),
  );

  Widget _emptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 80, height: 80,
        decoration: const BoxDecoration(color: _kSoftGreen, shape: BoxShape.circle),
        child: const Icon(Icons.inventory_2_rounded, size: 40, color: _kGreen)),
    const SizedBox(height: 16),
    const Text('Tidak ada produk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _kTextDark)),
    const SizedBox(height: 6),
    const Text('Tap + untuk menambah produk baru', style: TextStyle(fontSize: 13, color: _kTextGrey)),
  ]));

  Widget _errorState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Icon(Icons.wifi_off_rounded, size: 56, color: _kTextGrey),
    const SizedBox(height: 16),
    const Text('Gagal memuat data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _kTextDark)),
    const SizedBox(height: 8),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(_error ?? '', style: const TextStyle(fontSize: 12, color: _kTextGrey),
            textAlign: TextAlign.center)),
    const SizedBox(height: 20),
    ElevatedButton.icon(
      onPressed: _loadData,
      icon: const Icon(Icons.refresh_rounded),
      label: const Text('Coba Lagi'),
      style: ElevatedButton.styleFrom(backgroundColor: _kGreen, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    ),
  ]));
}

// ══════════════════════════════════════════════════════════════════════════════
// TILE produk
// ══════════════════════════════════════════════════════════════════════════════
class _BarangTile extends StatelessWidget {
  final BarangModel item;
  final VoidCallback onEdit, onDelete;
  const _BarangTile({required this.item, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final p  = item;
    final lo = p.isLowStock;
    final ou = p.isOutOfStock;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: ou ? Border.all(color: Colors.red[200]!, width: 1.5)
               : lo ? Border.all(color: Colors.orange[200]!, width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        // ── Gambar produk — pakai buildImageUrl ──────────────────────────────
        ClipRRect(
          borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
          child: SizedBox(
            width: 90, height: 90,
            child: _BarangImage(imageUrl: p.imageUrl, kategori: p.kategori),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Badge kategori
            if (p.kategori != null && p.kategori!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: _kSoftGreen, borderRadius: BorderRadius.circular(6)),
                child: Text(p.kategori!, style: const TextStyle(fontSize: 10, color: _kGreen, fontWeight: FontWeight.w700)),
              ),
            Text(p.namaBarang, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kTextDark),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(p.formattedHarga, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _kGreen)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: ou ? Colors.red[50] : lo ? Colors.orange[50] : _kSoftGreen,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ou ? Colors.red[200]! : lo ? Colors.orange[200]! : _kSoftGreen),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(ou ? Icons.cancel_rounded : lo ? Icons.warning_amber_rounded : Icons.inventory_2_rounded,
                    size: 12, color: ou ? Colors.red[700] : lo ? Colors.orange[700] : _kGreen),
                const SizedBox(width: 4),
                Text(ou ? 'Stok Habis' : lo ? 'Sisa ${p.stok} ⚠️' : 'Stok: ${p.stok}',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                        color: ou ? Colors.red[700] : lo ? Colors.orange[700] : _kGreen)),
              ]),
            ),
          ]),
        )),
        // ── Menu ───────────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: _kTextGrey),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Row(children: [
                Icon(Icons.edit_rounded, size: 18, color: _kGreen), SizedBox(width: 10), Text('Edit Produk')])),
              PopupMenuItem(value: 'del', child: Row(children: [
                Icon(Icons.delete_rounded, size: 18, color: Colors.red), SizedBox(width: 10),
                Text('Hapus', style: TextStyle(color: Colors.red))])),
            ],
            onSelected: (v) { if (v == 'edit') onEdit(); if (v == 'del') onDelete(); },
          ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Widget gambar produk — Image.network dengan full URL
// ══════════════════════════════════════════════════════════════════════════════
class _BarangImage extends StatelessWidget {
  final String  imageUrl;   // sudah full URL dari buildImageUrl()
  final String? kategori;
  final double  iconSize;

  const _BarangImage({
    required this.imageUrl,
    this.kategori,
    this.iconSize = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        // Loading placeholder
        loadingBuilder: (_, child, prog) =>
            prog == null ? child : _ph(loading: true),
        // Error placeholder (URL tidak bisa diakses)
        errorBuilder: (_, err, __) {
          debugPrint('Image load error: $err\nURL: $imageUrl');
          return _ph();
        },
      );
    }
    return _ph();
  }

  Widget _ph({bool loading = false}) {
    const map = {
      'Makanan': Icons.lunch_dining_rounded,
      'Minuman': Icons.local_drink_rounded,
      'Elektronik': Icons.devices_rounded,
      'Kebutuhan Rumah': Icons.cleaning_services_rounded,
    };
    return Container(
      color: _kSoftGreen,
      child: Center(
        child: loading
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: _kGreen))
            : Icon(map[kategori] ?? Icons.inventory_2_rounded,
                size: iconSize, color: const Color(0xFF81C784)),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FORM SHEET — tambah & edit barang
// ══════════════════════════════════════════════════════════════════════════════
enum _ImgMode { none, file, url }

class _BarangFormSheet extends StatefulWidget {
  final BarangModel? existing;
  final VoidCallback onSaved;
  const _BarangFormSheet({this.existing, required this.onSaved});

  @override
  State<_BarangFormSheet> createState() => _BarangFormSheetState();
}

class _BarangFormSheetState extends State<_BarangFormSheet>
    with SingleTickerProviderStateMixin {

  final _nameCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _urlCtrl   = TextEditingController();

  String   _kat      = 'Makanan';
  _ImgMode _imgMode  = _ImgMode.none;
  File?    _imgFile;
  Uint8List? _imgBytes;
  String?  _imgUrl;
  bool     _urlLoading = false;
  bool     _picking    = false;
  bool     _saving     = false;

  late final TabController _tab;
  final _cats = ['Makanan', 'Minuman', 'Elektronik', 'Kebutuhan Rumah'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);

    if (widget.existing != null) {
      final p          = widget.existing!;
      _nameCtrl.text   = p.namaBarang;
      _stockCtrl.text  = p.stok.toString();
      _descCtrl.text   = p.deskripsi ?? '';
      if (_cats.contains(p.kategori)) _kat = p.kategori!;
      if (p.harga > 0) {
        _priceCtrl.text = NumberFormat('#,###', 'id_ID').format(p.harga);
      }
      if (p.imageUrl.isNotEmpty) {
        _imgUrl  = p.imageUrl;
        _imgMode = _ImgMode.url;
        _urlCtrl.text = p.imageUrl;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _priceCtrl.dispose();
    _stockCtrl.dispose(); _descCtrl.dispose(); _urlCtrl.dispose();
    _tab.dispose();
    super.dispose();
  }

  bool get _valid =>
      _nameCtrl.text.trim().isNotEmpty &&
      _parseHarga(_priceCtrl.text) > 0 &&
      int.tryParse(_stockCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) != null;

  // ── Pick gambar ─────────────────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource src) async {
    try {
      setState(() => _picking = true);
      final xf = await ImagePicker().pickImage(source: src, imageQuality: 85);
      if (xf == null) { setState(() => _picking = false); return; }
      final bytes = await xf.readAsBytes();
      setState(() {
        _imgFile  = File(xf.path);
        _imgBytes = bytes;
        _imgMode  = _ImgMode.file;
        _imgUrl   = null;
        _urlCtrl.clear();
        _picking  = false;
      });
    } catch (e) {
      setState(() => _picking = false);
      _toast('Error: $e');
    }
  }

  // ── Terapkan URL ────────────────────────────────────────────────────────────
  Future<void> _applyUrl() async {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) { _toast('Masukkan URL gambar'); return; }
    if (!url.startsWith('http')) { _toast('URL harus diawali http://'); return; }

    setState(() { _urlLoading = true; });
    try {
      await http.head(Uri.parse(url)).timeout(const Duration(seconds: 5));
    } catch (_) {}

    setState(() {
      _urlLoading = false;
      _imgUrl  = url;
      _imgMode = _ImgMode.url;
      _imgFile = null; _imgBytes = null;
    });
    _toast('URL gambar diterapkan ✅');
  }

  // ── Simpan ke API ───────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_valid) { _toast('Lengkapi semua field yang wajib diisi!'); return; }
    setState(() => _saving = true);

    final nama  = _nameCtrl.text.trim();
    final harga = _parseHarga(_priceCtrl.text);
    final stok  = int.parse(_stockCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));
    final desc  = _descCtrl.text.trim();
    final isEdit = widget.existing != null;

    final fileToSend = _imgMode == _ImgMode.file ? _imgFile : null;
    final urlToSend  = _imgMode == _ImgMode.url  ? _imgUrl  : null;

    Map<String, dynamic> result;

    if (isEdit) {
      result = await BarangApiService.updateBarang(
        id: widget.existing!.id,
        namaBarang: nama, kategori: _kat, harga: harga, stok: stok,
        deskripsi: desc.isEmpty ? null : desc,
        imageFile: fileToSend, imageUrl: urlToSend,
      );
    } else {
      result = await BarangApiService.insertBarang(
        namaBarang: nama, kategori: _kat, harga: harga, stok: stok,
        deskripsi: desc.isEmpty ? null : desc,
        imageFile: fileToSend, imageUrl: urlToSend,
      );
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (result['status'] == true) {
      _toast(isEdit ? '✅ Produk diperbarui' : '🎉 Produk ditambahkan');
      Navigator.pop(context);
      widget.onSaved();
    } else {
      _toast('❌ Gagal: ${result['message']}');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: _kGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),

          Row(children: [
            Container(width: 40, height: 40,
                decoration: BoxDecoration(color: _kSoftGreen, borderRadius: BorderRadius.circular(12)),
                child: Icon(isEdit ? Icons.edit_rounded : Icons.add_rounded, color: _kGreen, size: 20)),
            const SizedBox(width: 12),
            Text(isEdit ? 'Edit Produk' : 'Tambah Produk Baru',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 20),

          // ── Section gambar ─────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: [
              // Tab header
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: TabBar(
                  controller: _tab,
                  onTap: (_) => setState(() {}),
                  indicatorColor: _kGreen,
                  labelColor: _kGreen,
                  unselectedLabelColor: _kTextGrey,
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  tabs: const [
                    Tab(icon: Icon(Icons.photo_library_rounded, size: 16), text: 'Galeri/Kamera'),
                    Tab(icon: Icon(Icons.link_rounded, size: 16), text: 'URL Gambar'),
                  ],
                ),
              ),
              // Preview gambar
              Container(
                height: 160, width: double.infinity,
                color: _kSoftGreen,
                child: ClipRRect(child: _buildPreview()),
              ),
              // Tab body
              SizedBox(
                height: 120,
                child: TabBarView(
                  controller: _tab,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                  // Tab 0: Galeri / Kamera
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      Expanded(child: _ImgBtn(
                        icon: Icons.photo_library_rounded,
                        label: 'Galeri',
                        onTap: _picking ? null : () => _pickImage(ImageSource.gallery),
                      )),
                      const SizedBox(width: 10),
                      if (!kIsWeb) Expanded(child: _ImgBtn(
                        icon: Icons.camera_alt_rounded,
                        label: 'Kamera',
                        onTap: _picking ? null : () => _pickImage(ImageSource.camera),
                      )),
                      if (_imgMode == _ImgMode.file) ...[
                        const SizedBox(width: 10),
                        Expanded(child: _ImgBtn(
                          icon: Icons.delete_rounded,
                          label: 'Hapus',
                          color: Colors.red,
                          onTap: () => setState(() { _imgFile = null; _imgBytes = null; _imgMode = _ImgMode.none; }),
                        )),
                      ],
                    ]),
                  ),
                  // Tab 1: URL
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(children: [
                      Row(children: [
                        Expanded(
                          child: TextField(
                            controller: _urlCtrl,
                            onSubmitted: (_) => _applyUrl(),
                            decoration: InputDecoration(
                              hintText: 'https://example.com/gambar.jpg',
                              hintStyle: TextStyle(fontSize: 11, color: Colors.grey[400]),
                              prefixIcon: const Icon(Icons.image_rounded, color: _kGreen, size: 18),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey[300]!)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: _kGreen, width: 1.5)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _urlLoading ? null : _applyUrl,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: _kGreen, foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                          child: _urlLoading
                              ? const SizedBox(width: 14, height: 14,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Terapkan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ]),
                      if (_imgMode == _ImgMode.url) ...[
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.check_circle_rounded, size: 14, color: _kGreen),
                          const SizedBox(width: 4),
                          const Text('URL gambar diterapkan', style: TextStyle(fontSize: 11, color: _kGreen, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => setState(() { _imgUrl = null; _imgMode = _ImgMode.none; _urlCtrl.clear(); }),
                            child: const Text('Hapus', style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w700)),
                          ),
                        ]),
                      ],
                    ]),
                  ),
                ],
              ),
              ),
            ]),
          ),
          const SizedBox(height: 14),

          // ── Fields ─────────────────────────────────────────────────────────
          _Fld(ctrl: _nameCtrl, label: 'Nama Barang *', icon: Icons.inventory_2_rounded, hint: 'Contoh: Indomie Goreng'),
          const SizedBox(height: 12),
          _Fld(ctrl: _descCtrl, label: 'Deskripsi', icon: Icons.description_rounded, hint: 'Deskripsi singkat (opsional)'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _kat,
            decoration: InputDecoration(
              labelText: 'Kategori',
              prefixIcon: const Icon(Icons.category_rounded, color: _kGreen, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _kGreen, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            items: _cats.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _kat = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, _RupiahFmt()],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Harga (Rp) *', hintText: '3.500',
              prefixIcon: const Icon(Icons.payments_rounded, color: _kGreen, size: 20),
              prefixText: 'Rp ', prefixStyle: const TextStyle(color: _kGreen, fontWeight: FontWeight.w700),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _kGreen, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              helperText: _priceCtrl.text.isNotEmpty ? 'Nilai: ${_fmtRp(_parseHarga(_priceCtrl.text))}' : null,
              helperStyle: const TextStyle(color: _kGreen, fontSize: 11),
            ),
          ),
          const SizedBox(height: 12),
          _Fld(ctrl: _stockCtrl, label: 'Stok *', icon: Icons.numbers_rounded, hint: '100', type: TextInputType.number),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton.icon(
              onPressed: (_picking || _saving) ? null : _save,
              icon: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Icon(isEdit ? Icons.save_rounded : Icons.add_circle_rounded, size: 20),
              label: Text(_saving ? 'Menyimpan...' : isEdit ? 'Simpan Perubahan' : 'Tambah Produk',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen, foregroundColor: Colors.white, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildPreview() {
    if (_picking) return const Center(child: CircularProgressIndicator(color: _kGreen));

    if (_imgMode == _ImgMode.file && _imgBytes != null) {
      return Stack(fit: StackFit.expand, children: [
        Image.memory(_imgBytes!, fit: BoxFit.cover),
        Positioned(top: 8, left: 8, child: _badge('📱 Foto baru', Colors.green[800]!)),
      ]);
    }

    if (_imgMode == _ImgMode.url && _imgUrl != null) {
      return Stack(fit: StackFit.expand, children: [
        Image.network(_imgUrl!, fit: BoxFit.cover,
            loadingBuilder: (_, child, prog) => prog == null ? child
                : const Center(child: CircularProgressIndicator(color: _kGreen, strokeWidth: 2)),
            errorBuilder: (_, __, ___) => _noImg(label: 'URL tidak dapat dimuat')),
        Positioned(top: 8, left: 8, child: _badge('🌐 URL', Colors.blue[700]!)),
      ]);
    }

    return _noImg();
  }

  Widget _badge(String t, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: bg.withOpacity(0.88), borderRadius: BorderRadius.circular(8)),
    child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
  );

  Widget _noImg({String label = 'Tap tab untuk pilih gambar'}) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.add_photo_alternate_rounded, size: 40, color: _kGreen.withOpacity(0.5)),
      const SizedBox(height: 6),
      Text(label, style: TextStyle(color: _kGreen.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600)),
    ],
  );
}

class _ImgBtn extends StatelessWidget {
  final IconData icon; final String label;
  final VoidCallback? onTap; final Color color;
  const _ImgBtn({required this.icon, required this.label, this.onTap, this.color = _kGreen});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: onTap == null ? Colors.grey[100] : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: onTap == null ? Colors.grey[300]! : color.withOpacity(0.3)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: onTap == null ? Colors.grey : color, size: 20),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: onTap == null ? Colors.grey : color)),
      ]),
    ),
  );
}

class _Fld extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint; final IconData icon; final TextInputType type;
  const _Fld({required this.ctrl, required this.label, required this.icon, required this.hint, this.type = TextInputType.text});

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl, keyboardType: type,
    decoration: InputDecoration(
      labelText: label, hintText: hint,
      prefixIcon: Icon(icon, color: _kGreen, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _kGreen, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    ),
  );
}