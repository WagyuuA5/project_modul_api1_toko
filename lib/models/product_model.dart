import 'package:intl/intl.dart';

class TokoModel {
  int? id;
  String? nama_barang;
  String? deskripsi;
  int? stok;
  int? harga;
  String? image;
  String? kategori;
  double? rating;
  int? terjual;

  TokoModel({
    this.id,
    this.nama_barang,
    this.deskripsi,
    this.stok,
    this.harga,
    this.image,
    this.kategori,
    this.rating,
    this.terjual,
  });

  TokoModel.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);
    nama_barang = json['nama_barang']?.toString();
    deskripsi = json['deskripsi']?.toString();
    stok = _toInt(json['stok']);
    harga = _toInt(json['harga']);
    image = json['image']?.toString();
    kategori = json['kategori']?.toString();
    rating = _toDouble(json['rating']);
    terjual = _toInt(json['terjual']);
    image = _buildImageUrl(json['image']?.toString());
  }

  static String? _buildImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('http')) return path; // Jika sudah full URL dari API

    // Jika path dari API hanya "17192.jpg" atau "images/17192.jpg",
    // kita gabungkan dengan alamat server public:
    const prefix = 'https://learn.smktelkom-mlg.sch.id/toko/public/';
    
    if (path.startsWith('/')) return '$prefix${path.substring(1)}';
    return '$prefix$path';
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return num.tryParse(value)?.toInt();
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return num.tryParse(value)?.toDouble();
    return null;
  }

  String get name => nama_barang ?? '';

  String get category => kategori ?? '';

  int get stock => stok ?? 0;

  int get finalPrice => harga ?? 0;

  bool get hasDiscount => false;

  double get discountPercent => 0;

  int get originalPrice => finalPrice;

  bool get isOutOfStock => stock <= 0;

  bool get isLowStock =>
      stock > 0 && stock <= 10;

  String get formattedPrice =>
      formatRupiah(finalPrice);

  String get formattedOriginal =>
      formatRupiah(originalPrice);

  static String formatRupiah(
      int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  dynamic operator [](String key) {
    switch (key) {
      case 'id':
        return id;

      case 'nama_barang':
        return nama_barang;

      case 'deskripsi':
        return deskripsi;

      case 'stok':
        return stok;

      case 'harga':
        return harga;

      case 'image':
        return image;

      case 'kategori':
        return kategori;

      case 'rating':
        return rating;

      case 'terjual':
        return terjual;

      default:
        return null;
    }
  }
}

typedef ProductModel = TokoModel;