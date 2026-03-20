import 'package:equatable/equatable.dart';

class StoreDetailEntity extends Equatable {
  const StoreDetailEntity({
    required this.storeName,
    required this.storeDisplayId,
    required this.storeLogoRelativePath,
    required this.statusRaw,
  });

  final String storeName;
  final String storeDisplayId;
  final String? storeLogoRelativePath;
  /// API value e.g. `active` / `inactive`.
  final String statusRaw;

  /// `Active` / `Inactive` / capitalized fallback.
  String get statusLabel {
    final s = statusRaw.trim().toLowerCase();
    if (s == 'active') return 'Active';
    if (s == 'inactive') return 'Inactive';
    if (statusRaw.isEmpty) return '—';
    return statusRaw[0].toUpperCase() +
        (statusRaw.length > 1 ? statusRaw.substring(1).toLowerCase() : '');
  }

  @override
  List<Object?> get props =>
      [storeName, storeDisplayId, storeLogoRelativePath, statusRaw];
}
