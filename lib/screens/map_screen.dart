import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/property_provider.dart';
import '../models/property.dart';
import 'property_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Property? _selectedProperty;
  Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地図で探す'),
      ),
      body: Consumer<PropertyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.properties.isEmpty) {
            return const Center(
              child: Text('表示する物件がありません'),
            );
          }

          // マーカーを作成
          _markers = provider.properties.map((property) {
            return Marker(
              markerId: MarkerId(property.id),
              position: LatLng(property.latitude, property.longitude),
              onTap: () {
                setState(() {
                  _selectedProperty = property;
                });
              },
              icon: BitmapDescriptor.defaultMarkerWithHue(
                _getMarkerHue(property),
              ),
            );
          }).toSet();

          // 中心位置を計算
          final center = _calculateCenter(provider.properties);

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: center,
                  zoom: 11,
                ),
                markers: _markers,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
              ),
              
              // 選択された物件の情報カード
              if (_selectedProperty != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildPropertyCard(_selectedProperty!, provider),
                ),
              
              // 凡例
              Positioned(
                top: 16,
                right: 16,
                child: _buildLegend(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPropertyCard(Property property, PropertyProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getRankColor(property.rank),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '#${property.rank}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars, size: 14, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            '${property.totalScore.toStringAsFixed(1)}点',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        property.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: property.isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        provider.toggleFavorite(property.id);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _selectedProperty = null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  property.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.address,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.train, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${property.nearestStation} 徒歩${property.walkingMinutes}分',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '¥${property.rent.toStringAsFixed(1)}万',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${property.layout} / ${property.area.toStringAsFixed(1)}㎡',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PropertyDetailScreen(
                      propertyId: property.id,
                    ),
                  ),
                );
              },
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '詳細を見る',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, 
                          size: 20, color: Colors.blue.shade700),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'スコア',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildLegendItem('80点以上', BitmapDescriptor.hueGreen),
          _buildLegendItem('60-79点', BitmapDescriptor.hueYellow),
          _buildLegendItem('60点未満', BitmapDescriptor.hueRed),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, double hue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _hueToColor(hue),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  double _getMarkerHue(Property property) {
    if (property.totalScore >= 80) {
      return BitmapDescriptor.hueGreen;
    } else if (property.totalScore >= 60) {
      return BitmapDescriptor.hueYellow;
    } else {
      return BitmapDescriptor.hueRed;
    }
  }

  Color _hueToColor(double hue) {
    if (hue == BitmapDescriptor.hueGreen) return Colors.green;
    if (hue == BitmapDescriptor.hueYellow) return Colors.amber;
    return Colors.red;
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber.shade700;
    if (rank == 2) return Colors.grey.shade400;
    if (rank == 3) return Colors.brown.shade400;
    if (rank <= 10) return Colors.blue.shade700;
    return Colors.grey.shade600;
  }

  LatLng _calculateCenter(List<Property> properties) {
    if (properties.isEmpty) {
      return const LatLng(35.6762, 139.6503); // 東京の座標
    }

    double lat = 0;
    double lng = 0;

    for (var property in properties) {
      lat += property.latitude;
      lng += property.longitude;
    }

    return LatLng(
      lat / properties.length,
      lng / properties.length,
    );
  }
}
