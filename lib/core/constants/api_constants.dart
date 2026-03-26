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

  /// POST `/api/auth/forgot-password` — request OTP for password reset.
  static const String forgotPassword = '/api/auth/forgot-password';

  /// POST `/api/auth/verify-forgot-password-otp` — verify OTP & set new password.
  static const String verifyForgotPasswordOtp =
      '/api/auth/verify-forgot-password-otp';

  /// POST `/api/auth/reset-password` — change password (cashier).
  static const String resetPassword = '/api/auth/reset-password';

  /// PATCH `/api/platform-users/{userId}` — update profile (fullName, email, phone, …).
  static String platformUser(String userId) => '/api/platform-users/$userId';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String dashboard = '/dashboard';
  static const String createFaydaBill = '/faydabill/create';

  /// GET `/api/store/{storeId}` — store profile (logo, name, status, …).
  static String storeById(String storeId) => '/api/store/$storeId';

  /// POST `/api/customers/by-phone/{phone}` — body `{ "storeId": "..." }`.
  static String customerByPhone(String phone) =>
      '/api/customers/by-phone/$phone';

  /// POST `/api/promotions/list` — live promotions for store + subcategory.
  static const String promotionsList = '/api/promotions/list';

  /// POST `/api/store/calculate-gift-voucher` — GV + coins for line inputs.
  static const String calculateGiftVoucher = '/api/store/calculate-gift-voucher';

  /// POST `/api/cashier-transactions/preview-summary` — cart preview.
  static const String previewCartSummary = '/api/cashier-transactions/preview-summary';

  /// POST `/api/cashier-transactions` — submit bill (PIN + cart).
  static const String cashierTransactions = '/api/cashier-transactions';

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
