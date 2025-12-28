import 'dart:convert';

/// 物件データモデル
class Property {
  final String id;
  final String url;
  final String name;
  final String address;
  final String nearestStation;
  final int walkingMinutes;
  final double area;
  final String layout;
  final double rent;
  final double managementFee;
  final double latitude;
  final double longitude;
  
  // スコア関連
  final int kawasakiTime;
  final double kawasakiScore;
  final int shibuyaTime;
  final double shibuyaScore;
  final int shinbashiTime;
  final double shinbashiScore;
  final int shinjukuTime;
  final double shinjukuScore;
  final double walkingScore;
  final double areaScore;
  final double totalScore;
  final int rank;
  
  // UI関連
  bool isFavorite;

  Property({
    required this.id,
    required this.url,
    required this.name,
    required this.address,
    required this.nearestStation,
    required this.walkingMinutes,
    required this.area,
    required this.layout,
    required this.rent,
    required this.managementFee,
    required this.latitude,
    required this.longitude,
    required this.kawasakiTime,
    required this.kawasakiScore,
    required this.shibuyaTime,
    required this.shibuyaScore,
    required this.shinbashiTime,
    required this.shinbashiScore,
    required this.shinjukuTime,
    required this.shinjukuScore,
    required this.walkingScore,
    required this.areaScore,
    required this.totalScore,
    required this.rank,
    this.isFavorite = false,
  });

  /// 月額合計
  double get totalMonthly => rent + managementFee;

  /// JSONからProperty作成
  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] ?? '',
      url: json['URL'] ?? '',
      name: json['物件名'] ?? '',
      address: json['住所'] ?? '',
      nearestStation: json['最寄駅'] ?? '',
      walkingMinutes: json['駅徒歩時間'] ?? 0,
      area: (json['専有面積'] ?? 0).toDouble(),
      layout: json['間取り'] ?? '',
      rent: (json['賃料'] ?? 0).toDouble(),
      managementFee: (json['管理費'] ?? 0).toDouble(),
      latitude: (json['緯度'] ?? 0).toDouble(),
      longitude: (json['経度'] ?? 0).toDouble(),
      kawasakiTime: json['川崎駅時間(分)'] ?? 0,
      kawasakiScore: (json['川崎駅スコア'] ?? 0).toDouble(),
      shibuyaTime: json['渋谷駅時間(分)'] ?? 0,
      shibuyaScore: (json['渋谷駅スコア'] ?? 0).toDouble(),
      shinbashiTime: json['新橋駅時間(分)'] ?? 0,
      shinbashiScore: (json['新橋駅スコア'] ?? 0).toDouble(),
      shinjukuTime: json['新宿駅時間(分)'] ?? 0,
      shinjukuScore: (json['新宿駅スコア'] ?? 0).toDouble(),
      walkingScore: (json['駅徒歩スコア'] ?? 0).toDouble(),
      areaScore: (json['広さスコア'] ?? 0).toDouble(),
      totalScore: (json['総合スコア'] ?? 0).toDouble(),
      rank: json['ランク'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  /// PropertyをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'URL': url,
      '物件名': name,
      '住所': address,
      '最寄駅': nearestStation,
      '駅徒歩時間': walkingMinutes,
      '専有面積': area,
      '間取り': layout,
      '賃料': rent,
      '管理費': managementFee,
      '緯度': latitude,
      '経度': longitude,
      '川崎駅時間(分)': kawasakiTime,
      '川崎駅スコア': kawasakiScore,
      '渋谷駅時間(分)': shibuyaTime,
      '渋谷駅スコア': shibuyaScore,
      '新橋駅時間(分)': shinbashiTime,
      '新橋駅スコア': shinbashiScore,
      '新宿駅時間(分)': shinjukuTime,
      '新宿駅スコア': shinjukuScore,
      '駅徒歩スコア': walkingScore,
      '広さスコア': areaScore,
      '総合スコア': totalScore,
      'ランク': rank,
      'isFavorite': isFavorite,
    };
  }

  /// コピーを作成
  Property copyWith({
    String? id,
    String? url,
    String? name,
    String? address,
    String? nearestStation,
    int? walkingMinutes,
    double? area,
    String? layout,
    double? rent,
    double? managementFee,
    double? latitude,
    double? longitude,
    int? kawasakiTime,
    double? kawasakiScore,
    int? shibuyaTime,
    double? shibuyaScore,
    int? shinbashiTime,
    double? shinbashiScore,
    int? shinjukuTime,
    double? shinjukuScore,
    double? walkingScore,
    double? areaScore,
    double? totalScore,
    int? rank,
    bool? isFavorite,
  }) {
    return Property(
      id: id ?? this.id,
      url: url ?? this.url,
      name: name ?? this.name,
      address: address ?? this.address,
      nearestStation: nearestStation ?? this.nearestStation,
      walkingMinutes: walkingMinutes ?? this.walkingMinutes,
      area: area ?? this.area,
      layout: layout ?? this.layout,
      rent: rent ?? this.rent,
      managementFee: managementFee ?? this.managementFee,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      kawasakiTime: kawasakiTime ?? this.kawasakiTime,
      kawasakiScore: kawasakiScore ?? this.kawasakiScore,
      shibuyaTime: shibuyaTime ?? this.shibuyaTime,
      shibuyaScore: shibuyaScore ?? this.shibuyaScore,
      shinbashiTime: shinbashiTime ?? this.shinbashiTime,
      shinbashiScore: shinbashiScore ?? this.shinbashiScore,
      shinjukuTime: shinjukuTime ?? this.shinjukuTime,
      shinjukuScore: shinjukuScore ?? this.shinjukuScore,
      walkingScore: walkingScore ?? this.walkingScore,
      areaScore: areaScore ?? this.areaScore,
      totalScore: totalScore ?? this.totalScore,
      rank: rank ?? this.rank,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// フィルター条件
class PropertyFilter {
  final double? minRent;
  final double? maxRent;
  final List<String>? layouts;
  final int? maxWalkingMinutes;
  final double? minArea;
  final String? station;
  final bool? favoritesOnly;

  PropertyFilter({
    this.minRent,
    this.maxRent,
    this.layouts,
    this.maxWalkingMinutes,
    this.minArea,
    this.station,
    this.favoritesOnly,
  });

  PropertyFilter copyWith({
    double? minRent,
    double? maxRent,
    List<String>? layouts,
    int? maxWalkingMinutes,
    double? minArea,
    String? station,
    bool? favoritesOnly,
  }) {
    return PropertyFilter(
      minRent: minRent ?? this.minRent,
      maxRent: maxRent ?? this.maxRent,
      layouts: layouts ?? this.layouts,
      maxWalkingMinutes: maxWalkingMinutes ?? this.maxWalkingMinutes,
      minArea: minArea ?? this.minArea,
      station: station ?? this.station,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    );
  }

  bool hasActiveFilters() {
    return minRent != null ||
        maxRent != null ||
        (layouts != null && layouts!.isNotEmpty) ||
        maxWalkingMinutes != null ||
        minArea != null ||
        station != null ||
        (favoritesOnly != null && favoritesOnly!);
  }
}

/// ソート種類
enum SortType {
  totalScore,
  rent,
  area,
  walkingTime,
  kawasakiTime,
}
