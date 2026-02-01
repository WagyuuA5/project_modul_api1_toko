import 'package:intl/intl.dart'; 

class ResponseDataList {
  final bool status;
  final String message;
  final List<dynamic>? data;
  final int? statusCode;
  final Map<String, dynamic>? meta;
  final Map<String, dynamic>? errors;
  final Pagination? pagination;

  ResponseDataList({
    required this.status,
    required this.message,
    this.data,
    this.statusCode,
    this.meta,
    this.errors,
    this.pagination,
  });
  factory ResponseDataList.fromJson(Map<String, dynamic> json) {
    return ResponseDataList(
      status: json['status'] ?? false,
      message: json['message'] ?? json['error'] ?? '',
      data: json['data'] is List ? json['data'] : [],
      statusCode: json['status_code'] ?? json['code'],
      meta: json['meta'] ?? json['metadata'],
      errors: json['errors'],
      pagination: json['pagination'] != null 
          ? Pagination.fromJson(json['pagination']) 
          : json['meta'] != null 
              ? Pagination.fromJson(json['meta']) 
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
      'status_code': statusCode,
      'meta': meta,
      'errors': errors,
      'pagination': pagination?.toJson(),
    };
  }
  static ResponseDataList success({
    String message = 'Success',
    List<dynamic>? data,
    Map<String, dynamic>? meta,
    Pagination? pagination,
  }) {
    return ResponseDataList(
      status: true,
      message: message,
      data: data,
      meta: meta,
      pagination: pagination,
    );
  }
  static ResponseDataList error({
    String message = 'Error',
    List<dynamic>? data,
    Map<String, dynamic>? errors,
    int? statusCode,
  }) {
    return ResponseDataList(
      status: false,
      message: message,
      data: data,
      errors: errors,
      statusCode: statusCode,
    );
  }

  bool get hasData => data != null && data!.isNotEmpty;
  bool get hasErrors => errors != null && errors!.isNotEmpty;
  int get length => data?.length ?? 0;
  bool get isEmpty => data?.isEmpty ?? true;

  dynamic getItem(int index) {
    if (data == null || index < 0 || index >= data!.length) {
      return null;
    }
    return data![index];
  }
  List<T> map<T>(T Function(dynamic) converter) {
    if (data == null) return [];
    try {
      return data!.map((item) => converter(item)).toList();
    } catch (e) {
      print('Error mapping data: $e');
      return [];
    }
  }
  List<dynamic> where(bool Function(dynamic) test) {
    if (data == null) return [];
    return data!.where(test).toList();
  }
  dynamic get first => hasData ? data!.first : null;
  dynamic get last => hasData ? data!.last : null;

  String get errorMessages {
    if (!hasErrors) return message;
    
    final errorList = <String>[];
    errors!.forEach((key, value) {
      if (value is List) {
        errorList.addAll(value.map((e) => e.toString()));
      } else {
        errorList.add(value.toString());
      }
    });
    
    return errorList.join('\n');
  }
  static String formatCurrency(dynamic amount) {
    try {
      final value = amount is String ? double.tryParse(amount) : amount;
      if (value == null) return 'Rp 0';
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(value);
    } catch (e) {
      return 'Rp 0';
    }
  }


  static String formatDate(DateTime? date, {bool withTime = false}) {
    if (date == null) return '-';
    if (withTime) {
      return DateFormat('dd/MM/yyyy HH:mm').format(date); // Sama seperti transaksi
    }
    return DateFormat('dd/MM/yyyy').format(date); // Format tanggal biasa
  }
  static String formatDateId(DateTime? date, {bool withTime = false}) {
    if (date == null) return '-';
    if (withTime) {
      return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(date);
    }
    return DateFormat('dd MMM yyyy', 'id_ID').format(date); // Format Indonesia
  }
  static String getTimeAgo(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} tahun lalu';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} bulan lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }
}

class Pagination {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final int? from;
  final int? to;
  final String? nextPageUrl;
  final String? prevPageUrl;
  final String? firstPageUrl;
  final String? lastPageUrl;

  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    this.from,
    this.to,
    this.nextPageUrl,
    this.prevPageUrl,
    this.firstPageUrl,
    this.lastPageUrl,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? json['page'] ?? 1,
      perPage: json['per_page'] ?? json['limit'] ?? 10,
      total: json['total'] ?? json['count'] ?? 0,
      lastPage: json['last_page'] ?? json['pages'] ?? 1,
      from: json['from'],
      to: json['to'],
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
      firstPageUrl: json['first_page_url'],
      lastPageUrl: json['last_page_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'per_page': perPage,
      'total': total,
      'last_page': lastPage,
      'from': from,
      'to': to,
      'next_page_url': nextPageUrl,
      'prev_page_url': prevPageUrl,
      'first_page_url': firstPageUrl,
      'last_page_url': lastPageUrl,
    };
  }
  bool get hasNextPage => nextPageUrl != null && nextPageUrl!.isNotEmpty;
  bool get hasPrevPage => prevPageUrl != null && prevPageUrl!.isNotEmpty;

  int get nextPage => hasNextPage ? currentPage + 1 : currentPage;
  int get prevPage => hasPrevPage ? currentPage - 1 : currentPage;
  int get totalPages => lastPage;
  String get displayInfo {
    return 'Menampilkan ${from ?? 1}-${to ?? currentPage * perPage} dari $total';
  }
}