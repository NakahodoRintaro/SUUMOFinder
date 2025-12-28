import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/property.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PropertyService {
  static PropertyService? _instance;
  List<Property> _allProperties = [];
  Set<String> _favoriteIds = {};
  
  PropertyService._();
  
  static PropertyService get instance {
    _instance ??= PropertyService._();
    return _instance!;
  }

  /// データを初期化
  Future<void> initialize() async {
    await _loadFavorites();
    await _loadProperties();
  }

  /// お気に入りをローカルストレージから読み込み
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesList = prefs.getStringList('favorites') ?? [];
      _favoriteIds = Set.from(favoritesList);
    } catch (e) {
      print('お気に入り読み込みエラー: $e');
    }
  }

  /// 物件データを読み込み
  Future<void> _loadProperties() async {
    try {
      // assetsからJSONデータを読み込み
      final jsonString = await rootBundle.loadString('assets/data/properties.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      
      _allProperties = jsonData.map((json) {
        final property = Property.fromJson(json);
        // お気に入り状態を反映
        return property.copyWith(isFavorite: _favoriteIds.contains(property.id));
      }).toList();
      
      // 総合スコアでソート
      _allProperties.sort((a, b) => b.totalScore.compareTo(a.totalScore));
      
    } catch (e) {
      print('物件データ読み込みエラー: $e');
      // エラー時はサンプルデータを使用
      _loadSampleData();
    }
  }

  /// サンプルデータを読み込み
  void _loadSampleData() {
    _allProperties = [
      Property(
        id: 'jnc_000101612985',
        url: 'https://suumo.jp/chintai/jnc_000101612985/',
        name: '川崎区小田６丁目計画 202号室',
        address: '神奈川県川崎市川崎区小田6丁目',
        nearestStation: '川崎駅',
        walkingMinutes: 12,
        area: 25.8,
        layout: '1LDK',
        rent: 10.9,
        managementFee: 0.5,
        latitude: 35.509168,
        longitude: 139.706346,
        kawasakiTime: 12,
        kawasakiScore: 88.5,
        shibuyaTime: 25,
        shibuyaScore: 75.0,
        shinbashiTime: 20,
        shinbashiScore: 80.0,
        shinjukuTime: 22,
        shinjukuScore: 78.0,
        walkingScore: 65.0,
        areaScore: 51.6,
        totalScore: 77.8,
        rank: 1,
        isFavorite: _favoriteIds.contains('jnc_000101612985'),
      ),
      Property(
        id: 'jnc_000101397703',
        url: 'https://suumo.jp/chintai/jnc_000101397703/',
        name: 'グランリーオ',
        address: '神奈川県川崎市川崎区砂子2丁目',
        nearestStation: '川崎駅',
        walkingMinutes: 6,
        area: 32.1,
        layout: '1LDK',
        rent: 12.8,
        managementFee: 1.0,
        latitude: 35.5310,
        longitude: 139.6975,
        kawasakiTime: 6,
        kawasakiScore: 94.0,
        shibuyaTime: 22,
        shibuyaScore: 78.0,
        shinbashiTime: 18,
        shinbashiScore: 82.0,
        shinjukuTime: 20,
        shinjukuScore: 80.0,
        walkingScore: 90.0,
        areaScore: 64.2,
        totalScore: 82.5,
        rank: 2,
        isFavorite: _favoriteIds.contains('jnc_000101397703'),
      ),
      Property(
        id: 'jnc_000101488641',
        url: 'https://suumo.jp/chintai/jnc_000101488641/',
        name: 'Line Silk',
        address: '東京都渋谷区代々木1丁目',
        nearestStation: 'JR新宿駅',
        walkingMinutes: 15,
        area: 41.2,
        layout: '1LDK',
        rent: 18.5,
        managementFee: 1.2,
        latitude: 35.6870,
        longitude: 139.6990,
        kawasakiTime: 28,
        kawasakiScore: 72.0,
        shibuyaTime: 10,
        shibuyaScore: 90.0,
        shinbashiTime: 15,
        shinbashiScore: 85.0,
        shinjukuTime: 5,
        shinjukuScore: 95.0,
        walkingScore: 50.0,
        areaScore: 82.4,
        totalScore: 78.2,
        rank: 3,
        isFavorite: _favoriteIds.contains('jnc_000101488641'),
      ),
    ];
  }

  /// すべての物件を取得
  List<Property> getAllProperties() {
    return List.from(_allProperties);
  }

  /// フィルター適用
  List<Property> getFilteredProperties(PropertyFilter filter) {
    var filtered = _allProperties.where((property) {
      // 賃料フィルター
      if (filter.minRent != null && property.rent < filter.minRent!) {
        return false;
      }
      if (filter.maxRent != null && property.rent > filter.maxRent!) {
        return false;
      }
      
      // 間取りフィルター
      if (filter.layouts != null && 
          filter.layouts!.isNotEmpty && 
          !filter.layouts!.contains(property.layout)) {
        return false;
      }
      
      // 徒歩時間フィルター
      if (filter.maxWalkingMinutes != null && 
          property.walkingMinutes > filter.maxWalkingMinutes!) {
        return false;
      }
      
      // 広さフィルター
      if (filter.minArea != null && property.area < filter.minArea!) {
        return false;
      }
      
      // 駅フィルター
      if (filter.station != null && 
          !property.nearestStation.contains(filter.station!)) {
        return false;
      }
      
      // お気に入りフィルター
      if (filter.favoritesOnly == true && !property.isFavorite) {
        return false;
      }
      
      return true;
    }).toList();
    
    return filtered;
  }

  /// ソート適用
  List<Property> sortProperties(List<Property> properties, SortType sortType, bool ascending) {
    var sorted = List<Property>.from(properties);
    
    switch (sortType) {
      case SortType.totalScore:
        sorted.sort((a, b) => ascending 
            ? a.totalScore.compareTo(b.totalScore)
            : b.totalScore.compareTo(a.totalScore));
        break;
      case SortType.rent:
        sorted.sort((a, b) => ascending 
            ? a.rent.compareTo(b.rent)
            : b.rent.compareTo(a.rent));
        break;
      case SortType.area:
        sorted.sort((a, b) => ascending 
            ? a.area.compareTo(b.area)
            : b.area.compareTo(a.area));
        break;
      case SortType.walkingTime:
        sorted.sort((a, b) => ascending 
            ? a.walkingMinutes.compareTo(b.walkingMinutes)
            : b.walkingMinutes.compareTo(a.walkingMinutes));
        break;
      case SortType.kawasakiTime:
        sorted.sort((a, b) => ascending 
            ? a.kawasakiTime.compareTo(b.kawasakiTime)
            : b.kawasakiTime.compareTo(a.kawasakiTime));
        break;
    }
    
    return sorted;
  }

  /// お気に入り切り替え
  Future<void> toggleFavorite(String propertyId) async {
    if (_favoriteIds.contains(propertyId)) {
      _favoriteIds.remove(propertyId);
    } else {
      _favoriteIds.add(propertyId);
    }
    
    // ローカルストレージに保存
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorites', _favoriteIds.toList());
    } catch (e) {
      print('お気に入り保存エラー: $e');
    }
    
    // プロパティリストを更新
    _allProperties = _allProperties.map((property) {
      if (property.id == propertyId) {
        return property.copyWith(isFavorite: _favoriteIds.contains(propertyId));
      }
      return property;
    }).toList();
  }

  /// お気に入り物件を取得
  List<Property> getFavoriteProperties() {
    return _allProperties.where((p) => p.isFavorite).toList();
  }

  /// IDで物件を取得
  Property? getPropertyById(String id) {
    try {
      return _allProperties.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 利用可能な間取りリストを取得
  List<String> getAvailableLayouts() {
    return _allProperties
        .map((p) => p.layout)
        .toSet()
        .toList()
        ..sort();
  }

  /// 利用可能な駅リストを取得
  List<String> getAvailableStations() {
    return _allProperties
        .map((p) => p.nearestStation)
        .toSet()
        .toList()
        ..sort();
  }
}
