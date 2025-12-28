import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/property_provider.dart';
import '../models/property.dart';
import '../widgets/property_card.dart';
import 'filter_screen.dart';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SUUMO家探し',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // マップビューボタン
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapScreen()),
              );
            },
            tooltip: '地図で表示',
          ),
          // フィルターボタン
          Consumer<PropertyProvider>(
            builder: (context, provider, child) {
              final hasFilters = provider.hasActiveFilters;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FilterScreen(),
                        ),
                      );
                    },
                    tooltip: 'フィルター',
                  ),
                  if (hasFilters)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 8,
                          minHeight: 8,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<PropertyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.initialize();
                    },
                    child: const Text('再試行'),
                  ),
                ],
              ),
            );
          }

          if (provider.properties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    '条件に一致する物件が見つかりませんでした',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  if (provider.hasActiveFilters) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        provider.clearFilter();
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('フィルターをクリア'),
                    ),
                  ],
                ],
              ),
            );
          }

          return Column(
            children: [
              // ヘッダー情報
              _buildHeader(provider),
              // ソートバー
              _buildSortBar(provider),
              // 物件リスト
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.initialize(),
                  child: ListView.builder(
                    itemCount: provider.properties.length,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemBuilder: (context, index) {
                      final property = provider.properties[index];
                      return PropertyCard(
                        property: property,
                        onFavoriteToggle: () {
                          provider.toggleFavorite(property.id);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(PropertyProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${provider.propertyCount}件の物件',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (provider.hasActiveFilters)
                  Text(
                    'フィルター適用中',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                    ),
                  ),
              ],
            ),
          ),
          if (provider.hasActiveFilters)
            TextButton.icon(
              onPressed: () {
                provider.clearFilter();
              },
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('クリア'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSortBar(PropertyProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text(
              '並び替え:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            _buildSortChip(provider, SortType.totalScore, 'スコア順'),
            _buildSortChip(provider, SortType.rent, '賃料'),
            _buildSortChip(provider, SortType.area, '広さ'),
            _buildSortChip(provider, SortType.walkingTime, '駅徒歩'),
            _buildSortChip(provider, SortType.kawasakiTime, '川崎駅'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip(
    PropertyProvider provider,
    SortType sortType,
    String label,
  ) {
    final isSelected = provider.currentSort == sortType;
    final isAscending = provider.sortAscending;

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
              ),
            ],
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          provider.changeSort(sortType);
        },
        selectedColor: Colors.blue.shade100,
        checkmarkColor: Colors.blue.shade700,
      ),
    );
  }
}
