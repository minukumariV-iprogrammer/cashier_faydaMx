/// Extra for [AppRoutes.update] (GoRouter `state.extra`).
class UpdateRouteExtra {
  const UpdateRouteExtra({
    required this.isForceUpdate,
    required this.storeUrl,
    required this.skipAllowed,
  });

  final bool isForceUpdate;
  final String storeUrl;
  final bool skipAllowed;
}
