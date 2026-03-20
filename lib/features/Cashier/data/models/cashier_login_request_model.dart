class CashierLoginRequestModel {
  final String username;
  final String password;
  final String portal;

  CashierLoginRequestModel({
    required this.username,
    required this.password,
    this.portal = 'merchant',
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'portal': portal,
    };
  }
}
