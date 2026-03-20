class CashierAuthEntity {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String username;
  final String role;
  /// First store in `profile.storeList` — used for `/api/store/{storeId}/summary`.
  final String storeId;

  /// City id from `storeList[].cityId` or `user_roles[].city_id` — `x-tenant-id` header.
  final String cityId;

  final String fullName;
  final String email;
  final String phone;
  /// e.g. `Jamnagar, GJ` from first role `city_name` + `state_label`.
  final String locationLabel;

  CashierAuthEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.username,
    required this.role,
    required this.storeId,
    required this.cityId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.locationLabel,
  });
}
