class JsonResponse {
  final String? title, message, error;
  final Map<String, dynamic>? data;

  JsonResponse({
    this.title,
    this.message,
    this.data,
    this.error,
  });

  Map<String, dynamic> get toMap => {
        "title": title,
        "message": message,
        "data": data,
        "error": error,
      };
}
