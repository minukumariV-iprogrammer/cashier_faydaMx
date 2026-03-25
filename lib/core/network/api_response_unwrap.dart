/// Unwraps nested `data` from encrypted/stage API responses.
///
/// When the backend nests twice:
/// `data: { success, message, data: { seasons | accessToken | ... } }`,
/// returns the inner payload. If `data` is already the payload (e.g. `{ seasons }`),
/// returns it unchanged.
Map<String, dynamic> unwrapApiDataPayload(Map<String, dynamic> json) {
  final outer = json['data'];
  if (outer is! Map<String, dynamic>) {
    return {};
  }
  final inner = outer['data'];
  if (inner is Map<String, dynamic> &&
      outer.containsKey('success') &&
      outer.containsKey('message')) {
    return inner;
  }
  return outer;
}
