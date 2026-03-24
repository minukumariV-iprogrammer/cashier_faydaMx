import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/store_asset_url.dart';


class CustomNetworkImage extends StatelessWidget {
  final double height;
  final double width;
  final String? imageUrl;
  final bool isCircular;
  final BoxFit? boxFit;

  const CustomNetworkImage({
    required this.height,
    required this.width,
    super.key,
    this.imageUrl,
    this.isCircular = false,
    this.boxFit = BoxFit.cover,
    this.fallbackAsset = _defaultFallback,
  });

  /// Shown when URL is empty or network fails (default: [fashion_image.webp]).
  final String fallbackAsset;

  static const String _defaultFallback = 'assets/cashierrelated/fashion_image.webp';

  Widget _buildImage(Widget child) {
    if (isCircular) {
      return ClipOval(child: child);
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    var imagePath = '';
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildImage(
        Image.asset(fallbackAsset, height: height, width: width, fit: boxFit),
      );
    }else{
      if (imageUrl!.contains('https')) {
        imagePath = imageUrl ?? '';
      } else {
        final logoUrl = storeAssetUrl(imageUrl);
        imagePath = logoUrl;
      }
    }

    return _buildImage(
      ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Image.network(
          imagePath,
          height: height,
          width: width,
          fit: boxFit,
          errorBuilder: (context, error, stackTrace) => ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.asset(
              fallbackAsset,
              height: height,
              width: width,
              fit: boxFit,
            ),
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              height: height,
              width: width,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}
