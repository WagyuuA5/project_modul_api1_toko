
class ResponseDataMap {
  final bool status;
  final String message;
  final Map<String, dynamic>? data;

  ResponseDataMap({
    required this.status,
    required this.message,
    this.data,
  });

  factory ResponseDataMap.fromJson(Map<String, dynamic> json) {
    return ResponseDataMap(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] ?? json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }
}

