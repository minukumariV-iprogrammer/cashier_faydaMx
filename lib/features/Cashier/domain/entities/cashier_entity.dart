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

  CashierAuthEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.username,
    required this.role,
    required this.storeId,
    required this.cityId,
  });
}
