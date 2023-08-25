class MethodResponse {
  final bool isSuccess;
  final String? message;
  final dynamic error;

  MethodResponse({
    required this.isSuccess,
    this.message,
    this.error,
  });

  @override
  String toString() {
    return 'MethodResponse{isSuccess: $isSuccess, '
        'message: $message, error: $error}';
  }
}
