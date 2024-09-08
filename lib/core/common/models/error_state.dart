class ErrorState<T> {
  final Object error;
  final StackTrace? stackTrace;

  // final MessageResponse? message;
  T? data;

  ErrorState({
    required this.error,
    this.stackTrace,
    this.data,
  });

  String get errorMessage => error.toString();

  @override
  String toString() => '$error, data: $data';
}