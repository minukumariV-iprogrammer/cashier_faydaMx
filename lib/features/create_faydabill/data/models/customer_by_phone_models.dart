import '../../domain/entities/customer_by_phone_entity.dart';

int? _i(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

String? _s(dynamic v) => v?.toString();

class CustomerModel {
  CustomerModel({
    required this.id,
    required this.phone,
    this.referralCode,
    this.referredById,
    required this.name,
    this.title,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.gender,
    this.profilePicture,
    this.dateOfAnniversary,
    this.occupation,
    this.address,
    this.address2,
    this.email,
    this.pan,
    this.kycStatus,
    this.zipCode,
    this.cityId,
    this.roleId,
    this.platform,
    this.isActive,
    this.isDeleted,
    this.lastShoppingDate,
    this.deviceBindingInfo,
    this.enkashCardId,
    this.enkashUserId,
    this.enkashCardAccountId,
    this.enkashToken,
    this.deleteAccountReason,
    this.kycVerificationDate,
  });

  final String id;
  final String phone;
  final String? referralCode;
  final String? referredById;
  final String name;
  final String? title;
  final String? firstName;
  final String? lastName;
  final String? dateOfBirth;
  final String? gender;
  final String? profilePicture;
  final String? dateOfAnniversary;
  final String? occupation;
  final String? address;
  final String? address2;
  final String? email;
  final String? pan;
  final int? kycStatus;
  final String? zipCode;
  final String? cityId;
  final int? roleId;
  final String? platform;
  final int? isActive;
  final int? isDeleted;
  final String? lastShoppingDate;
  final dynamic deviceBindingInfo;
  final String? enkashCardId;
  final String? enkashUserId;
  final String? enkashCardAccountId;
  final String? enkashToken;
  final String? deleteAccountReason;
  final String? kycVerificationDate;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: _s(json['id']) ?? '',
      phone: _s(json['phone']) ?? '',
      referralCode: _s(json['referral_code']),
      referredById: _s(json['referred_by_id']),
      name: _s(json['name']) ?? '',
      title: _s(json['title']),
      firstName: _s(json['firstName']),
      lastName: _s(json['lastName']),
      dateOfBirth: _s(json['date_of_birth']),
      gender: _s(json['gender']),
      profilePicture: _s(json['profile_picture']),
      dateOfAnniversary: _s(json['date_of_anniversary']),
      occupation: _s(json['occupation']),
      address: _s(json['address']),
      address2: _s(json['address2']),
      email: _s(json['email']),
      pan: _s(json['pan']),
      kycStatus: _i(json['kycStatus']),
      zipCode: _s(json['zipCode']),
      cityId: _s(json['cityId']),
      roleId: _i(json['role_id']),
      platform: _s(json['platform']),
      isActive: _i(json['is_active']),
      isDeleted: _i(json['is_deleted']),
      lastShoppingDate: _s(json['lastShoppingDate']),
      deviceBindingInfo: json['deviceBindingInfo'],
      enkashCardId: _s(json['enkashCardId']),
      enkashUserId: _s(json['enkashUserId']),
      enkashCardAccountId: _s(json['enkashCardAccountId']),
      enkashToken: _s(json['enkashToken']),
      deleteAccountReason: _s(json['deleteAccountReason']),
      kycVerificationDate: _s(json['kycVerificationDate']),
    );
  }

  CustomerEntity toEntity() => CustomerEntity(
        id: id,
        phone: phone,
        referralCode: referralCode,
        referredById: referredById,
        name: name,
        title: title,
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        gender: gender,
        profilePicture: profilePicture,
        dateOfAnniversary: dateOfAnniversary,
        occupation: occupation,
        address: address,
        address2: address2,
        email: email,
        pan: pan,
        kycStatus: kycStatus,
        zipCode: zipCode,
        cityId: cityId,
        roleId: roleId,
        platform: platform,
        isActive: isActive,
        isDeleted: isDeleted,
        lastShoppingDate: lastShoppingDate,
        deviceBindingInfo: deviceBindingInfo,
        enkashCardId: enkashCardId,
        enkashUserId: enkashUserId,
        enkashCardAccountId: enkashCardAccountId,
        enkashToken: enkashToken,
        deleteAccountReason: deleteAccountReason,
        kycVerificationDate: kycVerificationDate,
      );
}

class CustomerByPhoneDataModel {
  CustomerByPhoneDataModel({
    required this.customer,
    required this.currentStoreVisitCount,
    required this.allStoreVisit,
    required this.id,
    required this.cityId,
    required this.totalLuckyCoupons,
    required this.totalCoins,
  });

  final CustomerModel customer;
  final int currentStoreVisitCount;
  final int allStoreVisit;
  final String id;
  final String cityId;
  final int totalLuckyCoupons;
  final int totalCoins;

  factory CustomerByPhoneDataModel.fromJson(Map<String, dynamic> json) {
    final c = json['customer'];
    return CustomerByPhoneDataModel(
      customer: c is Map<String, dynamic>
          ? CustomerModel.fromJson(c)
          : CustomerModel(id: '', phone: '', name: ''),
      currentStoreVisitCount: _i(json['currentStoreVisitCount']) ?? 0,
      allStoreVisit: _i(json['allStoreVisit']) ?? 0,
      id: _s(json['id']) ?? '',
      cityId: _s(json['cityId']) ?? '',
      totalLuckyCoupons: _i(json['totalLuckyCoupons']) ?? 0,
      totalCoins: _i(json['totalCoins']) ?? 0,
    );
  }

  CustomerByPhoneSessionEntity toEntity() => CustomerByPhoneSessionEntity(
        customer: customer.toEntity(),
        recordId: id,
        cityId: cityId,
        currentStoreVisitCount: currentStoreVisitCount,
        allStoreVisit: allStoreVisit,
        totalLuckyCoupons: totalLuckyCoupons,
        totalCoins: totalCoins,
      );
}

class CustomerByPhoneApiResponseModel {
  CustomerByPhoneApiResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final CustomerByPhoneDataModel data;

  factory CustomerByPhoneApiResponseModel.fromJson(Map<String, dynamic> json) {
    return CustomerByPhoneApiResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: CustomerByPhoneDataModel.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
