import 'cashier_user_role_model.dart';
import 'cashier_store_model.dart';

class CashierProfileModel {
  final String userId;
  final String phone;
  final String username;
  final String email;
  final List<CashierUserRoleModel> userRoles;
  final List<CashierStoreModel> storeList;

  CashierProfileModel({
    required this.userId,
    required this.phone,
    required this.username,
    required this.email,
    required this.userRoles,
    required this.storeList,
  });

  factory CashierProfileModel.fromJson(Map<String, dynamic> json) {
    final roles = json['user_roles'] ?? json['userRoles'];
    final stores = json['storeList'] ?? json['store_list'];
    return CashierProfileModel(
      userId: json['userId'] as String,
      phone: json['phone'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      userRoles: (roles as List)
          .map((e) => CashierUserRoleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      storeList: (stores as List)
          .map((e) => CashierStoreModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
