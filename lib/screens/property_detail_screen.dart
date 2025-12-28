import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/property_provider.dart';
import '../models/property.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PropertyDetailScreen extends StatelessWidget {
  final String propertyId;

  const PropertyDetailScreen({
    super.key,
    required this.propertyId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PropertyProvider>(
      builder: (context, provider, child) {
        final property = provider.getPropertyById(propertyId);

        if (property == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('物件詳細')),
            body: const Center(
              child: Text('物件が見つかりませんでした'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('物件詳細'),
            actions: [
              IconButton(
                icon: Icon(
                  property.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: property.isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  provider.toggleFavorite(property.id);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 地図表示
                _buildMapSection(property),
                
                // 基本情報
                _buildBasicInfo(property, context),
                
                const Divider(height: 32),
                
                // スコア詳細
                _buildScoreSection(property),
                
                const Divider(height: 32),
                
                // 駅情報詳細
                _buildStationSection(property),
                
                const Divider(height: 32),
                
                // アクションボタン
                _buildActionButtons(property, context),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapSection(Property property) {
    return SizedBox(
      height: 250,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(property.latitude, property.longitude),
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: MarkerId(property.id),
            position: LatLng(property.latitude, property.longitude),
            infoWindow: InfoWindow(
              title: property.name,
              snippet: property.address,
            ),
          ),
        },
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
      ),
    );
  }

  Widget _buildBasicInfo(Property property, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ランクとスコア
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getRankColor(property.rank),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  '第${property.rank}位',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '総合スコア ${property.totalScore.toStringAsFixed(1)}点',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 物件名
          Text(
            property.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // 住所
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, size: 20, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  property.address,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 最寄駅
          Row(
            children: [
              Icon(Icons.train, size: 20, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                '${property.nearestStation} 徒歩${property.walkingMinutes}分',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // 価格
          Row(
            children: [
              const Text(
                '賃料',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '¥${property.rent.toStringAsFixed(1)}万',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '管理費 ¥${property.managementFee.toStringAsFixed(1)}万 / 月',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '合計 ¥${property.totalMonthly.toStringAsFixed(1)}万 / 月',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          
          // 物件スペック
          _buildSpecGrid(property),
        ],
      ),
    );
  }

  Widget _buildSpecGrid(Property property) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSpecRow('間取り', property.layout, Icons.home),
          const Divider(height: 24),
          _buildSpecRow('専有面積', '${property.area.toStringAsFixed(1)} ㎡', Icons.square_foot),
          const Divider(height: 24),
          _buildSpecRow('駅徒歩', '${property.walkingMinutes}分', Icons.directions_walk),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.blue.shade700),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreSection(Property property) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'スコア詳細',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildScoreBar('川崎駅へのアクセス', property.kawasakiScore, Colors.blue),
          _buildScoreBar('渋谷駅へのアクセス', property.shibuyaScore, Colors.purple),
          _buildScoreBar('新橋駅へのアクセス', property.shinbashiScore, Colors.orange),
          _buildScoreBar('新宿駅へのアクセス', property.shinjukuScore, Colors.green),
          _buildScoreBar('駅からの近さ', property.walkingScore, Colors.teal),
          _buildScoreBar('部屋の広さ', property.areaScore, Colors.pink),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, double score, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                '${score.toStringAsFixed(1)}点',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationSection(Property property) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '主要駅への移動時間',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStationCard('川崎駅', property.kawasakiTime, Icons.train, Colors.blue),
          _buildStationCard('渋谷駅', property.shibuyaTime, Icons.train, Colors.purple),
          _buildStationCard('新橋駅', property.shinbashiTime, Icons.train, Colors.orange),
          _buildStationCard('新宿駅', property.shinjukuTime, Icons.train, Colors.green),
        ],
      ),
    );
  }

  Widget _buildStationCard(String station, int minutes, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 12),
          Text(
            station,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color.shade700,
            ),
          ),
          const Spacer(),
          Text(
            '約 $minutes 分',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Property property, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () async {
                final url = Uri.parse(property.url);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('URLを開けませんでした')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text(
                'SUUMOで詳細を見る',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber.shade700;
    if (rank == 2) return Colors.grey.shade400;
    if (rank == 3) return Colors.brown.shade400;
    if (rank <= 10) return Colors.blue.shade700;
    return Colors.grey.shade600;
  }
}
