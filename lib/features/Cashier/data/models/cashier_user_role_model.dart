class CashierUserRoleModel {
  final int roleId;
  final String name;
  final String roleType;
  /// Same as login profile `city_id` — used as `x-tenant-id` when store has no city.
  final String cityId;
  final String cityName;
  final String stateLabel;

  CashierUserRoleModel({
    required this.roleId,
    required this.name,
    required this.roleType,
    required this.cityId,
    required this.cityName,
    required this.stateLabel,
  });

  factory CashierUserRoleModel.fromJson(Map<String, dynamic> json) {
    final rid = json['role_id'] ?? json['roleId'];
    return CashierUserRoleModel(
      roleId: rid is num ? rid.toInt() : int.tryParse(rid?.toString() ?? '') ?? 0,
      name: json['name'] as String,
      roleType: json['role_type'] as String,
      cityId: json['city_id'] as String? ?? json['cityId'] as String? ?? '',
      cityName: json['city_name'] as String? ?? json['cityName'] as String? ?? '',
      stateLabel: json['state_label'] as String? ?? json['stateLabel'] as String? ?? '',
    );
  }
}
