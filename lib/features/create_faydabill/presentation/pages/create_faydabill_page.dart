import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/store_asset_url.dart';
import '../../../../core/utils/toast_utils.dart';
import '../../../Cashier/domain/entities/store_full_entity.dart';
import '../bloc/create_faydabill_bloc.dart';
import '../bloc/create_faydabill_event.dart';
import '../bloc/create_faydabill_state.dart';
import '../widgets/fayda_active_deals_section.dart';
import '../widgets/fayda_bill_app_bar.dart';
import '../widgets/fayda_bill_input_card.dart';
import '../widgets/fayda_product_details_section.dart';

class CreateFaydaBillPage extends StatefulWidget {
  const CreateFaydaBillPage({super.key});

  static const String route = AppRoutes.createFaydaBill;

  @override
  State<CreateFaydaBillPage> createState() => _CreateFaydaBillPageState();
}

class _CreateFaydaBillPageState extends State<CreateFaydaBillPage> {
  final _phoneController = TextEditingController();
  final _invoiceController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _invoiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateFaydaBillBloc, CreateFaydaBillState>(
      listenWhen: (p, c) =>
          c.customerStatus == CreateFaydaBillCustomerStatus.failure &&
          c.customerErrorMessage != null &&
          c.customerErrorMessage!.isNotEmpty,
      listener: (context, state) {
        ToastUtils.showErrorToast(message: state.customerErrorMessage!);
      },
      builder: (context, state) {
        if (state.storeStatus == CreateFaydaBillStoreStatus.loading ||
            state.storeStatus == CreateFaydaBillStoreStatus.initial) {
          return FaydaBillStatusBar(
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: FaydaBillAppBar(
                onMenuPressed: () => context.pop(),
              ),
              body: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (state.storeStatus == CreateFaydaBillStoreStatus.failure) {
          return FaydaBillStatusBar(
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: FaydaBillAppBar(
                onMenuPressed: () => context.pop(),
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.storeErrorMessage ?? 'Failed to load store',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => context
                            .read<CreateFaydaBillBloc>()
                            .add(const CreateFaydaBillStarted()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return FaydaBillStatusBar(
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: FaydaBillAppBar(
              onMenuPressed: () => context.pop(),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FaydaBillInputCard(
                          phoneController: _phoneController,
                          invoiceController: _invoiceController,
                          onPhoneChanged: (v) => context
                              .read<CreateFaydaBillBloc>()
                              .add(CreateFaydaBillPhoneChanged(v)),
                          onInvoiceChanged: (v) => context
                              .read<CreateFaydaBillBloc>()
                              .add(CreateFaydaBillInvoiceChanged(v)),
                        ),
                        if (state.customerStatus ==
                            CreateFaydaBillCustomerStatus.loading) ...[
                          const SizedBox(height: 24),
                          const LinearProgressIndicator(minHeight: 2),
                          const SizedBox(height: 8),
                          Text(
                            'Looking up customer…',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (state.showPostPhoneSection) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Divider(
                              height: 1, thickness: 1, color: Color(0xFFE8E8E8)),
                          const SizedBox(height: 16),
                          _MainTabs(
                            state: state,
                            onTabChanged: (i) => context
                                .read<CreateFaydaBillBloc>()
                                .add(CreateFaydaBillMainTabChanged(i)),
                          ),
                          const SizedBox(height: 16),
                          if (state.mainTabIndex == 0 && state.storeFull != null)
                            _CategorySection(
                              storeFull: state.storeFull!,
                              selectedCategoryId: state.selectedCategoryId,
                              selectedSubcategoryMappingId:
                                  state.selectedSubcategoryMappingId,
                              onCategorySelected: (id) => context
                                  .read<CreateFaydaBillBloc>()
                                  .add(CreateFaydaBillCategorySelected(id)),
                              onSubcategorySelected: (mappingId) => context
                                  .read<CreateFaydaBillBloc>()
                                  .add(CreateFaydaBillSubcategorySelected(
                                      mappingId)),
                            ),
                        ],
                      ),
                    ),
                    if (state.mainTabIndex == 0) ...[
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FaydaActiveDealsSection(state: state),
                      ),
                      const SizedBox(height: 20),
                      FaydaProductDetailsSection(state: state),
                    ] else
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        child: Text(
                          'Add other benefits — coming next.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MainTabs extends StatelessWidget {
  const _MainTabs({
    required this.state,
    required this.onTabChanged,
  });

  final CreateFaydaBillState state;
  final ValueChanged<int> onTabChanged;

  static const Color _inactive = Color(0xFF78909C);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => onTabChanged(0),
                child: Column(
                  children: [
                    Text(
                      'Add Products to Cart',
                      style: TextStyle(
                        fontWeight: state.mainTabIndex == 0
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 15,
                        color: state.mainTabIndex == 0
                            ? Colors.black
                            : _inactive,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 3,
                      color: state.mainTabIndex == 0
                          ? Colors.black
                          : Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () => onTabChanged(1),
                child: Column(
                  children: [
                    Text(
                      'Add Other Benefits',
                      style: TextStyle(
                        fontWeight: state.mainTabIndex == 1
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 15,
                        color: state.mainTabIndex == 1
                            ? Colors.black
                            : _inactive,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 3,
                      color: state.mainTabIndex == 1
                          ? Colors.black
                          : Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.storeFull,
    required this.selectedCategoryId,
    required this.selectedSubcategoryMappingId,
    required this.onCategorySelected,
    required this.onSubcategorySelected,
  });

  final StoreFullEntity storeFull;
  final int? selectedCategoryId;
  final String? selectedSubcategoryMappingId;
  final ValueChanged<int> onCategorySelected;
  final ValueChanged<String> onSubcategorySelected;

  static const _hangerAsset = 'assets/cashierrelated/hanger.webp';
  static const _bucketAsset = 'assets/cashierrelated/shopping_bucket.webp';

  @override
  Widget build(BuildContext context) {
    final categories = storeFull.productCategories;
    if (categories.isEmpty) {
      return const Text('No categories configured for this store.');
    }

    final idSet = categories.map((e) => e.id).toSet();
    final catId = (selectedCategoryId != null && idSet.contains(selectedCategoryId))
        ? selectedCategoryId!
        : categories.first.id;

    final subs = storeFull.subcategoriesForCategory(catId);
    final subIdSet = subs.map((s) => s.id).toSet();
    final effectiveSubId = (selectedSubcategoryMappingId != null &&
            subIdSet.contains(selectedSubcategoryMappingId))
        ? selectedSubcategoryMappingId
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              _hangerAsset,
              width: 22,
              height: 22,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, i) {
                    final c = categories[i];
                    final selected = c.id == catId;
                    return Padding(
                      padding: EdgeInsets.only(right: i == categories.length - 1 ? 0 : 8),
                      child: _FaydaPillChip(
                        selected: selected,
                        onTap: () => onCategorySelected(c.id),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _CategoryChipAvatar(logo: c.logo),
                            const SizedBox(width: 8),
                            Text(
                              c.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFE8E8E8)),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              _bucketAsset,
              width: 22,
              height: 22,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 40,
                child: subs.isEmpty
                    ? const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'No subcategories',
                          style: TextStyle(fontSize: 13, color: Color(0xFF78909C)),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: subs.length,
                        itemBuilder: (context, i) {
                          final m = subs[i];
                          final selected = m.id == effectiveSubId;
                          return Padding(
                            padding: EdgeInsets.only(right: i == subs.length - 1 ? 0 : 8),
                            child: _FaydaPillChip(
                              selected: selected,
                              onTap: () => onSubcategorySelected(m.id),
                              child: Text(
                                m.subcategoryCapping.subCategoryName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Shared pill: selected fill `#0040B8`, unselected white + grey border.
class _FaydaPillChip extends StatelessWidget {
  const _FaydaPillChip({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? AppColors.faydaBillChipSelected : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.faydaBillChipSelected
                  : const Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _CategoryChipAvatar extends StatelessWidget {
  const _CategoryChipAvatar({this.logo});

  final String? logo;

  static const _fallback = 'assets/cashierrelated/fashion_image.webp';

  @override
  Widget build(BuildContext context) {
    final url = storeAssetUrl(logo);
    if (url.isEmpty) {
      return ClipOval(
        child: Image.asset(
          _fallback,
          width: 24,
          height: 24,
          fit: BoxFit.cover,
        ),
      );
    }
    return ClipOval(
      child: Image.network(
        url,
        width: 24,
        height: 24,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          _fallback,
          width: 24,
          height: 24,
          fit: BoxFit.cover,
        ),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Image.asset(
            _fallback,
            width: 24,
            height: 24,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}

