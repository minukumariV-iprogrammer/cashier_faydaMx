import 'package:flutter/material.dart';

import '../../../../../core/utils/store_asset_url.dart';
import '../../../domain/entities/store_detail_entity.dart';

/// Left app bar: grey pill with store logo, then chevron opening store details.
class CashierStoreHeaderPill extends StatelessWidget {
  const CashierStoreHeaderPill({
    super.key,
    required this.store,
  });

  final StoreDetailEntity store;

  @override
  Widget build(BuildContext context) {
    final url = storeAssetUrl(store.storeLogoRelativePath);

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.only(left: 8, right: 4, top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StoreLogoChip(imageUrl: url, size: 32),
            const SizedBox(width: 10),
            PopupMenuButton<void>(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              offset: const Offset(0, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
              child: Icon(
                Icons.swap_vert,
                size: 22,
                color: Colors.grey.shade800,
              ),
              itemBuilder: (context) => [
                PopupMenuItem<void>(
                  enabled: false,
                  padding: EdgeInsets.zero,
                  child: _StoreDetailPopoverContent(store: store),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreLogoChip extends StatelessWidget {
  const _StoreLogoChip({
    required this.imageUrl,
    required this.size,
  });

  final String imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl.isEmpty
            ? ColoredBox(
                color: Colors.grey.shade400,
                child: Icon(Icons.store, size: size * 0.5, color: Colors.white),
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return ColoredBox(
                    color: Colors.grey.shade300,
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: Colors.grey.shade400,
                  child: Icon(Icons.store, size: size * 0.5, color: Colors.white),
                ),
              ),
      ),
    );
  }
}

class _StoreDetailPopoverContent extends StatelessWidget {
  const _StoreDetailPopoverContent({required this.store});

  final StoreDetailEntity store;

  @override
  Widget build(BuildContext context) {
    final url = storeAssetUrl(store.storeLogoRelativePath);
    final meta = '${store.storeDisplayId} • ${store.statusLabel}';

    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: 280,
        child: Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: url.isEmpty
                        ? ColoredBox(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.store),
                          )
                        : Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => ColoredBox(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.store),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.storeName.isNotEmpty ? store.storeName : '—',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        meta,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
