import 'package:equatable/equatable.dart';

/// Customer row from `data.customer`.
class CustomerEntity extends Equatable {
  const CustomerEntity({
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

  @override
  List<Object?> get props => [id, phone, name, email];
}

/// Full `data` object from customer-by-phone API.
class CustomerByPhoneSessionEntity extends Equatable {
  const CustomerByPhoneSessionEntity({
    required this.customer,
    required this.recordId,
    required this.cityId,
    required this.currentStoreVisitCount,
    required this.allStoreVisit,
    required this.totalLuckyCoupons,
    required this.totalCoins,
  });

  final CustomerEntity customer;
  final String recordId;
  final String cityId;
  final int currentStoreVisitCount;
  final int allStoreVisit;
  final int totalLuckyCoupons;
  final int totalCoins;

  @override
  List<Object?> get props =>
      [customer, recordId, cityId, currentStoreVisitCount, allStoreVisit, totalLuckyCoupons, totalCoins];
}
