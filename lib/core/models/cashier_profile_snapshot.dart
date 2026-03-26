/// Cached user fields for profile drawer (persisted after login).
class CashierProfileSnapshot {
  const CashierProfileSnapshot({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.username,
    required this.locationLabel,
    this.userId = '',
    this.roleId = 0,
  });

  final String fullName;
  final String email;
  final String phone;
  final String username;
  final String locationLabel;
  /// Platform user id from login `data.profile.userId` — `/api/platform-users/{id}`.
  final String userId;
  /// First role from login `user_roles` — required for profile update body.
  final int roleId;

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'username': username,
        'locationLabel': locationLabel,
        'userId': userId,
        'roleId': roleId,
      };

  factory CashierProfileSnapshot.fromJson(Map<String, dynamic> j) {
    final rid = j['roleId'];
    return CashierProfileSnapshot(
      fullName: j['fullName'] as String? ?? '',
      email: j['email'] as String? ?? '',
      phone: j['phone'] as String? ?? '',
      username: j['username'] as String? ?? '',
      locationLabel: j['locationLabel'] as String? ?? '',
      userId: j['userId'] as String? ?? '',
      roleId: rid is int
          ? rid
          : rid is num
              ? rid.toInt()
              : int.tryParse(rid?.toString() ?? '') ?? 0,
    );
  }
}
