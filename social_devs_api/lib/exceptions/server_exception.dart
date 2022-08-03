class ServerException implements Exception {
  final int statusCode;
  final String error;

  ServerException(this.statusCode, this.error);
}
