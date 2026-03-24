import '../../domain/entities/store_detail_entity.dart';
import '../../domain/entities/store_full_entity.dart';

class ProductCategoryModel {
  ProductCategoryModel({
    required this.id,
    required this.name,
    this.logo,
  });

  final int id;
  final String name;
  final String? logo;

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      logo: json['logo']?.toString(),
    );
  }

  ProductCategoryEntity toEntity() => ProductCategoryEntity(
        id: id,
        name: name,
        logo: logo,
      );
}

class SubcategoryCappingModel {
  SubcategoryCappingModel({
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

  factory SubcategoryCappingModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryCappingModel(
      id: json['id']?.toString() ?? '',
      categoryMasterId: json['categoryMasterId']?.toString() ?? '',
      subCategoryMasterId: json['subCategoryMasterId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      subCategoryName: json['subCategoryName']?.toString() ?? '',
      logo: json['logo']?.toString(),
    );
  }

  SubcategoryCappingEntity toEntity() => SubcategoryCappingEntity(
        id: id,
        categoryMasterId: categoryMasterId,
        subCategoryMasterId: subCategoryMasterId,
        categoryName: categoryName,
        subCategoryName: subCategoryName,
        logo: logo,
      );
}

class StoreSubcategoryMappingModel {
  StoreSubcategoryMappingModel({
    required this.id,
    required this.status,
    required this.subcategoryCapping,
  });

  final String id;
  final String status;
  final SubcategoryCappingModel subcategoryCapping;

  factory StoreSubcategoryMappingModel.fromJson(Map<String, dynamic> json) {
    final cap = json['subcategoryCapping'];
    return StoreSubcategoryMappingModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      subcategoryCapping: cap is Map<String, dynamic>
          ? SubcategoryCappingModel.fromJson(cap)
          : SubcategoryCappingModel(
              id: '',
              categoryMasterId: '',
              subCategoryMasterId: '',
              categoryName: '',
              subCategoryName: '',
            ),
    );
  }

  StoreSubcategoryMappingEntity toEntity() => StoreSubcategoryMappingEntity(
        id: id,
        status: status,
        subcategoryCapping: subcategoryCapping.toEntity(),
      );
}

/// Parses GET `/api/store/{id}` `data` object (header fields + catalog).
class StoreFullDataModel {
  StoreFullDataModel({
    required this.storeName,
    required this.storeDisplayId,
    required this.storeLogo,
    required this.status,
    required this.productCategory,
    required this.storeSubcategoryMapping,
  });

  final String storeName;
  final String storeDisplayId;
  final String? storeLogo;
  final String status;
  final List<ProductCategoryModel> productCategory;
  final List<StoreSubcategoryMappingModel> storeSubcategoryMapping;

  factory StoreFullDataModel.fromJson(Map<String, dynamic> json) {
    final pc = json['productCategory'] as List<dynamic>?;
    final sm = json['storeSubcategoryMapping'] as List<dynamic>?;

    return StoreFullDataModel(
      storeName: json['storeName']?.toString() ?? '',
      storeDisplayId: json['storeDisplayId']?.toString() ?? '',
      storeLogo: json['storeLogo']?.toString(),
      status: json['status']?.toString() ?? '',
      productCategory: pc
              ?.map((e) => ProductCategoryModel.fromJson(
                    e as Map<String, dynamic>,
                  ))
              .toList() ??
          [],
      storeSubcategoryMapping: sm
              ?.map((e) => StoreSubcategoryMappingModel.fromJson(
                    e as Map<String, dynamic>,
                  ))
              .toList() ??
          [],
    );
  }

  StoreDetailEntity toDetailEntity() => StoreDetailEntity(
        storeName: storeName,
        storeDisplayId: storeDisplayId,
        storeLogoRelativePath: storeLogo,
        statusRaw: status,
      );

  StoreFullEntity toFullEntity() => StoreFullEntity(
        detail: toDetailEntity(),
        productCategories: productCategory.map((e) => e.toEntity()).toList(),
        subcategoryMappings:
            storeSubcategoryMapping.map((e) => e.toEntity()).toList(),
      );
}
