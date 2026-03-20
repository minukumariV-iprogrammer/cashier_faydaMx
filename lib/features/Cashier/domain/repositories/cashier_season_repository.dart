abstract class CashierSeasonRepository {
  /// Returns the [id] of the season where `isActive` is true.
  Future<String> resolveActiveSeasonId(String storeId);
}
