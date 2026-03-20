/// Cached user fields for profile drawer (persisted after login).
class CashierProfileSnapshot {
  const CashierProfileSnapshot({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.username,
    required this.locationLabel,
  });

  final String fullName;
  final String email;
  final String phone;
  final String username;
  final String locationLabel;

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'username': username,
        'locationLabel': locationLabel,
      };

  factory CashierProfileSnapshot.fromJson(Map<String, dynamic> j) {
    return CashierProfileSnapshot(
      fullName: j['fullName'] as String? ?? '',
      email: j['email'] as String? ?? '',
      phone: j['phone'] as String? ?? '',
      username: j['username'] as String? ?? '',
      locationLabel: j['locationLabel'] as String? ?? '',
    );
  }
}
