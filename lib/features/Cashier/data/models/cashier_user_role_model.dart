class CashierUserRoleModel {
  final int roleId;
  final String name;
  final String roleType;
  /// Same as login profile `city_id` — used as `x-tenant-id` when store has no city.
  final String cityId;

  CashierUserRoleModel({
    required this.roleId,
    required this.name,
    required this.roleType,
    required this.cityId,
  });

  factory CashierUserRoleModel.fromJson(Map<String, dynamic> json) {
    return CashierUserRoleModel(
      roleId: (json['role_id'] as num).toInt(),
      name: json['name'] as String,
      roleType: json['role_type'] as String,
      cityId: json['city_id'] as String? ?? json['cityId'] as String? ?? '',
    );
  }
}
