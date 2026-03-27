# Cashier Migration Backup: Rooted Device + App Version + Maintenance Flow

This document captures the current implementation pattern from `fmx-app` so it can be reused in the cashier project.

## 1) Rooted/Jailbroken Device Logic (all environments)

### Core service
- File: `lib/core/security/security_service.dart`
- Service: `SecurityService`
- Detection package: `flutter_jailbreak_detection`
- Checks:
  - `jailbroken`
  - `developerMode`
- Compromised if either is true.

### Behavior by environment
- **Production/Staging**
  - Device compromised => treat as unsafe.
  - Security check failure/exception => fail-safe as compromised.
- **Development**
  - Compromised device is logged as warning but app may continue.

### Main entry wiring
- Files:
  - `lib/main_dev.dart`
  - `lib/main_stage.dart`
  - `lib/main_prod.dart`
- Startup calls:
  1. `initializeDependencies()`
  2. `sl.allReady()`
  3. `sl<SecurityService>().initialize()`
  4. Continue boot

## 2) Rooted Device UI on Splash

### Splash security gate
- File: `lib/features/onboarding/presentation/screens/splash_page.dart`
- State variables:
  - `_isDeviceCompromised`
  - `_compromisedMessage`
- `_checkDeviceSecurity()`:
  - Uses `sl<SecurityService>()`
  - If compromised => sets `_isDeviceCompromised = true`
  - Displays blocking card:
    - "Security Alert"
    - Compromised message from `getSecurityStatusMessage()`
    - "Close App" button -> `SystemNavigator.pop()`
- Navigation is blocked in `_navigateToNextScreen()` when compromised.

### Important note for cashier project
- In a `StatefulWidget` with lifecycle observer, use:
  - `WidgetsBinding.instance.addObserver(this)` in `initState`
  - `WidgetsBinding.instance.removeObserver(this)` in `dispose`
- In this app, splash currently calls `removeObserver` in `initState`; do **not** copy that pattern.

## 3) App Version API Flow

### API contract
- Endpoint constant:
  - `ApiConstants.appVersion = "/api/masters/app-version"`
- Request model:
  - `AppInitRequestModel { platform, currentVersion }`
- Entity:
  - `AppInitEntity { status, minimumSupportedVersion, latestVersion, termAndConditionsUrl }`
- Repository/usecase chain:
  - `AuthRemoteDataSource.getAppInit()`
  - `AuthRepository.getAppInit()`
  - `GetAppInit` use case
  - `AppIntiCubit.getAppInitData()`

### Status handling in Splash
- In `_checkForInAppUpdate(AppInitEntity appInitData)`:
  - `MAINTENANCE_MODE` -> `context.go(AppRoutes.downtime)`
  - `FORCE_UPDATE` -> `context.go(AppRoutes.update, extra: {... isForceUpdate: true ...})`
  - `SOFT_UPDATE` -> `context.go(AppRoutes.update, extra: {... isForceUpdate: false ...})`
  - Else -> continue normal navigation

### Environment policy
- Current app skips update check outside production:
  - `if (!FlavorConfig.isProduction()) { _navigateToNextScreen(); }`
- For cashier app, decide explicitly if staging should also enforce update.

## 4) Update Screen

### Route
- `AppRoutes.update = '/update'`
- Router builder expects `state.extra` map:
  - `isForceUpdate`
  - `storeUrl`
  - `skipAllowed`

### UI behavior
- File: `lib/features/onboarding/presentation/widgets/update_screen.dart`
- Force update:
  - Shows update CTA only
  - No skip
- Soft update:
  - Shows update CTA + "Skip for now"
  - Skip navigates to dashboard/login depending on token presence
- Launches store URL via `url_launcher`.

## 5) Maintenance Screen

### Route
- `AppRoutes.downtime = '/downtime'`
- Screen file:
  - `lib/features/onboarding/presentation/widgets/downtime_screen.dart`

### Trigger paths
1. **App version status** = `MAINTENANCE_MODE` on splash.
2. **Runtime API failures** with HTTP 503 via interceptor:
   - File: `lib/core/network/interceptors/maintenance_interceptor.dart`
   - On 503 -> `AppRouter.router.go(AppRoutes.downtime)`

## 6) Router Prerequisites

- Router must include:
  - Splash route
  - Update route
  - Downtime route
- Current app allows update route through redirect logic.

## 7) Cashier Project Implementation Checklist

1. Copy/adapt `SecurityService` + register in DI.
2. Initialize security in all cashier mains (dev/stage/prod).
3. Add splash gate UI for compromised device + hard stop action.
4. Add app-version request/response models and status mapping.
5. Add `AppInitCubit` and call on splash.
6. Add routes:
   - `/update`
   - `/downtime`
7. Add update screen with force/soft behavior.
8. Add downtime screen.
9. Add maintenance interceptor for 503 handling.
10. Verify env policy (prod-only vs stage+prod).
11. Add localization keys for update/maintenance/security texts in cashier app.

## 8) Pitfalls to Avoid

- Do not depend only on startup version check; keep 503 interceptor too.
- Ensure splash does not navigate further when compromised.
- Ensure lifecycle observer is wired correctly (`addObserver`/`removeObserver`).
- Keep route redirects from blocking `/update` and `/downtime`.

## 9) Quick Reference Paths in this app

- Security service: `lib/core/security/security_service.dart`
- Splash logic: `lib/features/onboarding/presentation/screens/splash_page.dart`
- App init cubit: `lib/features/onboarding/presentation/cubit/app_inti_cubit.dart`
- App version datasource call: `lib/features/onboarding/data/datasource/auth_remote_data_source.dart`
- Update screen: `lib/features/onboarding/presentation/widgets/update_screen.dart`
- Downtime screen: `lib/features/onboarding/presentation/widgets/downtime_screen.dart`
- Routes: `lib/core/navigation/app_routers.dart`
- Maintenance interceptor: `lib/core/network/interceptors/maintenance_interceptor.dart`

