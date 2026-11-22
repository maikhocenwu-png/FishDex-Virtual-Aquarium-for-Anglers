import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import 'catch_details_screen.dart';
import '../data/store.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapControl = MapController();
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  bool isLoading = true;
  bool _mapReady = false;
  bool _didCenterOnLocation = false;
  LatLng? _currentLocation;
  String _searchQuery = '';

  String _selectedCategory = 'All';

  List<String> get _categories => [
    'All',
    ...{
      for (final c in store.catches)
        if (c.latitude != null && c.longitude != null) c.species,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final permitted = await _checktheRequestPermissions();

    if (!permitted || !mounted) {
      setState(() => isLoading = false);
      return;
    }

    _locationSubscription =
        _location.onLocationChanged.listen((locationData) {
          final latitude = locationData.latitude;
          final longitude = locationData.longitude;

          setState(() {
            _currentLocation = LatLng(latitude, longitude);
            isLoading = false;
          });

          _centerOnCurrentLocation();
        });
  }

  Future<bool> _checktheRequestPermissions() async {
    var serviceEnabled = await _location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    var permissionGranted = await _location.hasPermission();

    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
    }

    return permissionGranted == PermissionStatus.granted ||
        permissionGranted == PermissionStatus.grantedLimited;
  }

  void _userCurrentLocation() {
    final location = _currentLocation;

    if (location != null && _mapReady) {
      mapControl.move(location, 15);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Current location not available.'),
        ),
      );
    }
  }

  void _centerOnCurrentLocation() {
    final location = _currentLocation;

    if (!_mapReady || location == null || _didCenterOnLocation) return;

    _didCenterOnLocation = true;
    mapControl.move(location, 15);
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final query = _searchQuery.trim().toLowerCase();

        final visibleCatches = store.catches.where((c) {
          final matchesCategory =
              _selectedCategory == 'All' || c.species == _selectedCategory;
          final matchesSearch = query.isEmpty ||
              c.species.toLowerCase().contains(query) ||
              c.place.toLowerCase().contains(query);

          return matchesCategory && matchesSearch;
        }).toList();

        final catchesWithLocation = visibleCatches.where(
              (c) => c.latitude != null && c.longitude != null,
        );

        return Scaffold(
          appBar: AppBar(
            foregroundColor: const Color(0xFFEDEDED),
            title: const Text(
              'Map',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            leading: IconButton(
              icon: const Text(
                '<',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () => Navigator.of(context).maybePop(),
              tooltip: 'Back',
            ),
          ),
          body: Stack(
            children: [
              FlutterMap(
                mapController: mapControl,
                options: MapOptions(
                  initialCenter: _currentLocation ?? const LatLng(0, 0),
                  initialZoom: 4,
                  minZoom: 0,
                  maxZoom: 100,
                  onMapReady: () {
                    _mapReady = true;
                    _centerOnCurrentLocation();
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.fishdexteam.fishdex',
                  ),
                  MarkerLayer(
                    markers: catchesWithLocation.map((c) {
                      return Marker(
                        point: LatLng(c.latitude!, c.longitude!),
                        width: 110,
                        height: 55,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CatchDetailsScreen(catchId: c.id),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              const Icon(Icons.location_pin, color: Colors.red, size: 32),
                              Text(
                                c.species,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  backgroundColor: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  CurrentLocationLayer(
                    style: const LocationMarkerStyle(
                      markerSize: Size(20, 20),
                      markerDirection: MarkerDirection.heading,
                    ),
                  ),
                ],
              ),

              if (isLoading)
                const Center(child: CircularProgressIndicator()),

              // Bottom panel: drag upward to expand.
              DraggableScrollableSheet(
                initialChildSize: 0.12,
                minChildSize: 0.12,
                maxChildSize: 0.75,
                snap: true,
                snapSizes: const [0.12, 0.75],
                builder: (context, scrollController) {
                  return Material(
                    color: Colors.white,
                    elevation: 12,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      children: [
                        const SizedBox(height: 10),
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Text(
                            'Catches',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search catches',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              isDense: true,
                            ),
                            onChanged: (value) {
                              setState(() => _searchQuery = value);
                            },
                          ),
                        ),
                        SizedBox(
                          height: 52,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            children: _categories.map((category) {
                              return Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                                child: ChoiceChip(
                                  label: Text(category),
                                  selected: _selectedCategory == category,
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedCategory = category;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        if (visibleCatches.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No saved catches yet.'),
                          )
                        else
                          ...visibleCatches.map((c) {
                            return ListTile(
                              leading: const Icon(Icons.location_on),
                              title: Text(c.species),
                              subtitle: Text(
                                c.place.isEmpty ? 'Place not provided' : c.place,
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CatchDetailsScreen(catchId: c.id),
                                  ),
                                );
                              },
                            );
                          }),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            elevation: 0,
            onPressed: _userCurrentLocation,
            backgroundColor: Colors.blue,
            child: const Icon(
              Icons.my_location,
              size: 30,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
