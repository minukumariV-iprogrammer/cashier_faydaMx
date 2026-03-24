import 'package:equatable/equatable.dart';

import 'store_detail_entity.dart';

class ProductCategoryEntity extends Equatable {
  const ProductCategoryEntity({
    required this.id,
    required this.name,
    this.logo,
  });

  final int id;
  final String name;
  final String? logo;

  @override
  List<Object?> get props => [id, name, logo];
}

class SubcategoryCappingEntity extends Equatable {
  const SubcategoryCappingEntity({
    required this.id,
    required this.categoryMasterId,
    required this.subCategoryMasterId,
    required this.categoryName,
    required this.subCategoryName,
    this.logo,
  });

  final String id;
  final String categoryMasterId;
  final String subCategoryMasterId;
  final String categoryName;
  final String subCategoryName;
  final String? logo;

  @override
  List<Object?> get props =>
      [id, categoryMasterId, subCategoryMasterId, categoryName, subCategoryName, logo];
}

class StoreSubcategoryMappingEntity extends Equatable {
  const StoreSubcategoryMappingEntity({
    required this.id,
    required this.status,
    required this.subcategoryCapping,
  });

  final String id;
  final String status;
  final SubcategoryCappingEntity subcategoryCapping;

  @override
  List<Object?> get props => [id, status, subcategoryCapping];
}

/// Full store payload from GET `/api/store/{id}` (header + catalog).
class StoreFullEntity extends Equatable {
  const StoreFullEntity({
    required this.detail,
    required this.productCategories,
    required this.subcategoryMappings,
  });

  final StoreDetailEntity detail;
  final List<ProductCategoryEntity> productCategories;
  final List<StoreSubcategoryMappingEntity> subcategoryMappings;

  /// Subcategories where `categoryMasterId` matches [categoryId] (string compare).
  List<StoreSubcategoryMappingEntity> subcategoriesForCategory(int categoryId) {
    final idStr = categoryId.toString();
    return subcategoryMappings
        .where((m) => m.subcategoryCapping.categoryMasterId == idStr)
        .toList();
  }

  @override
  List<Object?> get props => [detail, productCategories, subcategoryMappings];
}
