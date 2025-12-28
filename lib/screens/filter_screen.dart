import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/property_provider.dart';
import '../models/property.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late PropertyFilter _filter;
  late List<String> _availableLayouts;
  late List<String> _availableStations;

  @override
  void initState() {
    super.initState();
    final provider = context.read<PropertyProvider>();
    _filter = provider.currentFilter;
    _availableLayouts = provider.getAvailableLayouts();
    _availableStations = provider.getAvailableStations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('フィルター'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filter = PropertyFilter();
              });
            },
            child: const Text('リセット'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 賃料フィルター
          _buildRentFilter(),
          const SizedBox(height: 24),
          
          // 間取りフィルター
          _buildLayoutFilter(),
          const SizedBox(height: 24),
          
          // 駅徒歩時間フィルター
          _buildWalkingTimeFilter(),
          const SizedBox(height: 24),
          
          // 広さフィルター
          _buildAreaFilter(),
          const SizedBox(height: 24),
          
          // 駅フィルター
          _buildStationFilter(),
          const SizedBox(height: 24),
          
          // お気に入りフィルター
          _buildFavoritesFilter(),
          const SizedBox(height: 32),
          
          // 適用ボタン
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                context.read<PropertyProvider>().applyFilter(_filter);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'フィルターを適用',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRentFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '賃料',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: '最低賃料',
                  suffix: Text('万円'),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                  text: _filter.minRent?.toString() ?? '',
                ),
                onChanged: (value) {
                  setState(() {
                    _filter = _filter.copyWith(
                      minRent: double.tryParse(value),
                    );
                  });
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('〜'),
            ),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: '最高賃料',
                  suffix: Text('万円'),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                  text: _filter.maxRent?.toString() ?? '',
                ),
                onChanged: (value) {
                  setState(() {
                    _filter = _filter.copyWith(
                      maxRent: double.tryParse(value),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLayoutFilter() {
    final selectedLayouts = _filter.layouts ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '間取り',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableLayouts.map((layout) {
            final isSelected = selectedLayouts.contains(layout);
            return FilterChip(
              label: Text(layout),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final newLayouts = List<String>.from(selectedLayouts);
                  if (selected) {
                    newLayouts.add(layout);
                  } else {
                    newLayouts.remove(layout);
                  }
                  _filter = _filter.copyWith(
                    layouts: newLayouts.isEmpty ? null : newLayouts,
                  );
                });
              },
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue.shade700,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWalkingTimeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '駅徒歩時間',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_filter.maxWalkingMinutes != null)
              Text(
                '${_filter.maxWalkingMinutes}分以内',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        Slider(
          value: _filter.maxWalkingMinutes?.toDouble() ?? 30,
          min: 1,
          max: 30,
          divisions: 29,
          label: '${_filter.maxWalkingMinutes ?? 30}分',
          onChanged: (value) {
            setState(() {
              _filter = _filter.copyWith(
                maxWalkingMinutes: value.toInt(),
              );
            });
          },
        ),
        if (_filter.maxWalkingMinutes != null)
          TextButton(
            onPressed: () {
              setState(() {
                _filter = _filter.copyWith(maxWalkingMinutes: null);
              });
            },
            child: const Text('制限を解除'),
          ),
      ],
    );
  }

  Widget _buildAreaFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '専有面積',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(
            labelText: '最低面積',
            suffix: Text('㎡'),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          controller: TextEditingController(
            text: _filter.minArea?.toString() ?? '',
          ),
          onChanged: (value) {
            setState(() {
              _filter = _filter.copyWith(
                minArea: double.tryParse(value),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildStationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '最寄駅',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '駅を選択',
          ),
          value: _filter.station,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('すべて'),
            ),
            ..._availableStations.map((station) {
              return DropdownMenuItem<String>(
                value: station,
                child: Text(station),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _filter = _filter.copyWith(station: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildFavoritesFilter() {
    return SwitchListTile(
      title: const Text(
        'お気に入りのみ表示',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: const Text('お気に入りに追加した物件だけを表示します'),
      value: _filter.favoritesOnly ?? false,
      onChanged: (value) {
        setState(() {
          _filter = _filter.copyWith(favoritesOnly: value);
        });
      },
      activeColor: Colors.blue,
      contentPadding: EdgeInsets.zero,
    );
  }
}
