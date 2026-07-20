/// Exception CHỈ được ném ra ở tầng Data (DataSource).
/// RepositoryImpl sẽ bắt nó và đổi thành [Failure] trước khi đẩy lên trên.
class ServerException implements Exception {
  final String message;
  const ServerException({required this.message});
}
