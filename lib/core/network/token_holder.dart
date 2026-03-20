/// In-memory access token for Dio interceptors (sync).
class TokenHolder {
  String? _token;

  String? get token => _token;

  void setToken(String? value) {
    _token = value;
  }

  void clear() {
    _token = null;
  }
}
