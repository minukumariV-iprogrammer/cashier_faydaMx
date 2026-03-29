class CashierLoginRequestModel {
  final String username;
  final String password;
  final String portal;
  final String projectId;
  final String? fcmToken;
  final String platform;

  CashierLoginRequestModel({
    required this.username,
    required this.password,
    this.portal = 'merchant',
    required this.projectId,
    this.fcmToken,
    required this.platform,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'portal': portal,
      'projectId': projectId,
      'fcmToken': fcmToken ?? '',
      'platform': platform,
    };
  }
}
