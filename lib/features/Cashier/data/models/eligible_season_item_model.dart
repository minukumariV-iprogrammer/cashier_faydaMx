class EligibleSeasonItemModel {
  EligibleSeasonItemModel({
    required this.id,
    required this.name,
    required this.isActive,
    required this.sequence,
    required this.isUpcoming,
    required this.isPast,
    required this.startDate,
    required this.endDate,
    required this.storeStatus,
  });

  final String id;
  final String name;
  final bool isActive;
  final int sequence;
  final bool isUpcoming;
  final bool isPast;
  final String startDate;
  final String endDate;
  final String storeStatus;

  factory EligibleSeasonItemModel.fromJson(Map<String, dynamic> json) {
    return EligibleSeasonItemModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
      sequence: (json['sequence'] as num?)?.toInt() ?? 0,
      isUpcoming: json['isUpcoming'] as bool? ?? false,
      isPast: json['isPast'] as bool? ?? false,
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      storeStatus: json['storeStatus'] as String? ?? '',
    );
  }
}
