/// API base URLs and endpoints. Values can be overridden per flavor.
class ApiConstants {
  ApiConstants._();

  static String get baseUrl => _baseUrl;
  static String _baseUrl = '';

  static void setBaseUrl(String url) {
    _baseUrl = url;
  }

  static const String login = '/auth/login';
  static const String cashierLogin = '/api/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String dashboard = '/dashboard';
  static const String createFaydaBill = '/faydabill/create';

  /// GET `/api/store/{storeId}/summary` — cashier dashboard metrics.
  static String storeSummary(String storeId) => '/api/store/$storeId/summary';

  /// GET `/api/cities/seasons/eligible/{storeId}` — eligible seasons.
  static String eligibleSeasons(String storeId) =>
      '/api/cities/seasons/eligible/$storeId';

  /// Cashier API headers (from backend contract).
  static const String cashierAppScope = 'x-app-scope';
  static const String cashierAppScopeValue = 'android';
  /// Header name; value is profile `cityId` / `city_id` from login (not a fixed UUID).
  static const String cashierTenantId = 'x-tenant-id';

  /// Sent on requests after an active season is resolved (login).
  static const String cashierSeasonIdHeader = 'x-season-id';
}
