/// In-memory active season id for Dio interceptors (sync `x-season-id` header).
class SeasonHolder {
  String? _seasonId;

  String? get seasonId => _seasonId;

  void setSeasonId(String? value) {
    _seasonId = value;
  }

  void clear() {
    _seasonId = null;
  }
}
