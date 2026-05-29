class ResponseDataList {
  final bool status;
  final String message;
  final List<dynamic>? data;
  final int? statusCode;

  ResponseDataList({
    required this.status,
    this.message = '', 
    this.data,
    this.statusCode,
  });

  factory ResponseDataList.fromJson(Map<String, dynamic> json) {
    return ResponseDataList(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] is List ? json['data'] : [],
      statusCode: json['status_code'],
    );
  }

  static ResponseDataList success({
    String message = 'Success',
    List<dynamic>? data,
  }) {
    return ResponseDataList(
      status: true,
      message: message,
      data: data,
    );
  }

  static ResponseDataList error({
    String message = 'Error',
    int? statusCode,
  }) {
    return ResponseDataList(
      status: false,
      message: message,
      statusCode: statusCode,
    );
  }
}