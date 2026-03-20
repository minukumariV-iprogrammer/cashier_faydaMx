/// In-memory city id for Dio interceptors (sync `x-tenant-id` header).
class TenantHolder {
  String? _tenantId;

  String? get tenantId => _tenantId;

  void setTenantId(String? value) {
    _tenantId = value;
  }

  void clear() {
    _tenantId = null;
  }
}
