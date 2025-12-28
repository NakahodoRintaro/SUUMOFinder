import 'package:flutter/foundation.dart';
import '../models/property.dart';
import '../services/property_service.dart';

class PropertyProvider extends ChangeNotifier {
  final PropertyService _service = PropertyService.instance;
  
  List<Property> _displayedProperties = [];
  PropertyFilter _currentFilter = PropertyFilter();
  SortType _currentSort = SortType.totalScore;
  bool _sortAscending = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Property> get properties => _displayedProperties;
  PropertyFilter get currentFilter => _currentFilter;
  SortType get currentSort => _currentSort;
  bool get sortAscending => _sortAscending;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get propertyCount => _displayedProperties.length;
  bool get hasActiveFilters => _currentFilter.hasActiveFilters();

  /// 初期化
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.initialize();
      _refreshDisplayedProperties();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'データの読み込みに失敗しました: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 表示物件を更新
  void _refreshDisplayedProperties() {
    var filtered = _service.getFilteredProperties(_currentFilter);
    _displayedProperties = _service.sortProperties(filtered, _currentSort, _sortAscending);
  }

  /// フィルターを適用
  void applyFilter(PropertyFilter filter) {
    _currentFilter = filter;
    _refreshDisplayedProperties();
    notifyListeners();
  }

  /// フィルターをクリア
  void clearFilter() {
    _currentFilter = PropertyFilter();
    _refreshDisplayedProperties();
    notifyListeners();
  }

  /// ソート変更
  void changeSort(SortType sortType) {
    if (_currentSort == sortType) {
      _sortAscending = !_sortAscending;
    } else {
      _currentSort = sortType;
      _sortAscending = sortType == SortType.rent || sortType == SortType.walkingTime;
    }
    _refreshDisplayedProperties();
    notifyListeners();
  }

  /// お気に入り切り替え
  Future<void> toggleFavorite(String propertyId) async {
    await _service.toggleFavorite(propertyId);
    _refreshDisplayedProperties();
    notifyListeners();
  }

  /// お気に入り物件のみ表示
  void showFavoritesOnly(bool show) {
    if (show) {
      _currentFilter = _currentFilter.copyWith(favoritesOnly: true);
    } else {
      _currentFilter = PropertyFilter(
        minRent: _currentFilter.minRent,
        maxRent: _currentFilter.maxRent,
        layouts: _currentFilter.layouts,
        maxWalkingMinutes: _currentFilter.maxWalkingMinutes,
        minArea: _currentFilter.minArea,
        station: _currentFilter.station,
        favoritesOnly: false,
      );
    }
    _refreshDisplayedProperties();
    notifyListeners();
  }

  /// IDで物件を取得
  Property? getPropertyById(String id) {
    return _service.getPropertyById(id);
  }

  /// 利用可能な間取りを取得
  List<String> getAvailableLayouts() {
    return _service.getAvailableLayouts();
  }

  /// 利用可能な駅を取得
  List<String> getAvailableStations() {
    return _service.getAvailableStations();
  }

  /// お気に入り物件数を取得
  int getFavoriteCount() {
    return _service.getFavoriteProperties().length;
  }
}
