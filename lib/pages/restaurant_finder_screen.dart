import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/yens_theme.dart';
import '../widgets/yens_main_header.dart';

class RestaurantFinderScreen extends StatefulWidget {
  const RestaurantFinderScreen({super.key});

  @override
  State<RestaurantFinderScreen> createState() => _RestaurantFinderScreenState();
}

class _RestaurantFinderScreenState extends State<RestaurantFinderScreen> {
  final TextEditingController _searchController = TextEditingController();
  Position? _currentPosition;
  bool _loading = false;
  
  // Mock store data
  final List<Map<String, dynamic>> _stores = [
    {
      'name': 'Yens Thai - Central World',
      'address': '4, 4/1-4/2 Rama I Rd, Pathum Wan, Bangkok 10330',
      'lat': 13.7462,
      'lng': 100.5399,
      'phone': '+66 2 640 7000',
    },
    {
      'name': 'Yens Thai - Siam Paragon',
      'address': '991 Rama I Rd, Pathum Wan, Bangkok 10330',
      'lat': 13.7468,
      'lng': 100.5350,
      'phone': '+66 2 610 8000',
    },
    {
      'name': 'Yens Thai - IconSiam',
      'address': '299 Charoen Nakhon Rd, Khlong Ton Sai, Khlong San, Bangkok 10600',
      'lat': 13.7266,
      'lng': 100.5111,
      'phone': '+66 2 495 7000',
    },
    {
      'name': 'Yens Thai - Ari Station',
      'address': 'Phahonyothin Rd, Samsen Nai, Phaya Thai, Bangkok 10400',
      'lat': 13.7797,
      'lng': 100.5447,
      'phone': '+66 81 234 5678',
    },
  ];

  List<Map<String, dynamic>> _filteredStores = [];

  @override
  void initState() {
    super.initState();
    _filteredStores = List.from(_stores);
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _loading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('Location services are disabled.');
        setState(() => _loading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permissions are denied');
          setState(() => _loading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError('Location permissions are permanently denied');
        setState(() => _loading = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = pos;
        _sortStoresByDistance();
        _loading = false;
      });
    } catch (e) {
      _showError('Could not get location: $e');
      setState(() => _loading = false);
    }
  }

  void _sortStoresByDistance() {
    if (_currentPosition == null) return;
    
    for (var store in _filteredStores) {
      double distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        store['lat'],
        store['lng'],
      );
      store['distance'] = distance / 1000; // in km
    }
    
    _filteredStores.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
  }

  void _searchLocation(String query) {
    setState(() {
      _filteredStores = _stores.where((s) => 
        s['name'].toLowerCase().contains(query.toLowerCase()) || 
        s['address'].toLowerCase().contains(query.toLowerCase())
      ).toList();
      if (_currentPosition != null) _sortStoresByDistance();
    });
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YensTheme.cream,
      body: SafeArea(
        child: Column(
          children: [
            YensMainHeader.pushed(
              title: 'Restaurant Finder',
              onBack: () => Navigator.pop(context),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _searchLocation,
                      decoration: InputDecoration(
                        hintText: 'Search by city or area...',
                        prefixIcon: const Icon(Icons.search, color: YensTheme.navy),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.my_location, color: YensTheme.navy),
                          onPressed: _getCurrentLocation,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_loading) const LinearProgressIndicator(color: YensTheme.navy, backgroundColor: Colors.transparent),
                ],
              ),
            ),

            Expanded(
              child: _filteredStores.isEmpty
                  ? Center(child: Text('No stores found.', style: GoogleFonts.dmSans(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredStores.length,
                      itemBuilder: (context, index) {
                        final store = _filteredStores[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      store['name'],
                                      style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16, color: YensTheme.navy),
                                    ),
                                  ),
                                  if (store['distance'] != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: YensTheme.yellow.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                      child: Text(
                                        '${(store['distance'] as double).toStringAsFixed(1)} km',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: YensTheme.navy),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                store['address'],
                                style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _actionBtn(Icons.directions_outlined, 'Directions', () {}),
                                  const SizedBox(width: 8),
                                  _actionBtn(Icons.call_outlined, 'Call', () {}),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          foregroundColor: YensTheme.navy,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
