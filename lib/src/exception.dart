part of mandatory_update;

class ManUpException implements Exception {
  final String msg;
  const ManUpException([this.msg]);

  @override
  String toString() => msg ?? 'ManUpException';
}
