import 'cashier_user_role_model.dart';
import 'cashier_store_model.dart';

class CashierProfileModel {
  final String userId;
  final String phone;
  final String username;
  final String email;
  final String fullName;
  final List<CashierUserRoleModel> userRoles;
  final List<CashierStoreModel> storeList;

  CashierProfileModel({
    required this.userId,
    required this.phone,
    required this.username,
    required this.email,
    required this.fullName,
    required this.userRoles,
    required this.storeList,
  });

  factory CashierProfileModel.fromJson(Map<String, dynamic> json) {
    final roles = json['user_roles'] ?? json['userRoles'];
    final stores = json['storeList'] ?? json['store_list'];
    return CashierProfileModel(
      userId: json['userId']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString() ??
          json['fullName']?.toString() ??
          '',
      userRoles: (roles is List ? roles : const [])
          .map((e) => CashierUserRoleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      storeList: (stores is List ? stores : const [])
          .map((e) => CashierStoreModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
