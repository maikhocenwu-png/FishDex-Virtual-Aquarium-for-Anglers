import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../data/store.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'catch_details_screen.dart';

/// A.6 Map. For the demo the map is a drawn placeholder with pins.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapControl = MapController();
  final Location _location = Location();
  final TextEditingController _locationController = TextEditingController();
  bool isLoading = true;
  bool _mapReady = false;
  bool _didCenterOnLocation = false;
  LatLng? _currentLocation;

  @override

  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future <void> _initializeLocation() async {
    if (!await _checktheRequestPermissions()) return;
    // listen for location and update it

    _location.onLocationChanged.listen((LocationData locationData) {
      if(locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
          isLoading = false;
        });
        _centerOnCurrentLocation();
      }
    });
  }

  Future <bool> _checktheRequestPermissions() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if( !serviceEnabled) return false;
    }
    PermissionStatus permissionGranted = await _location.hasPermission();
    if(permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if(permissionGranted != PermissionStatus.granted) return false;
    }
    return true;
  }

  Future <void> _userCurrentLocation() async {
    if(_currentLocation != null) {
      mapControl.move(_currentLocation!, 15);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Current Location Not Avaliable."),
        ), // SnackBar
      );
    }
  }

  @override


  void _centerOnCurrentLocation() {
    final location = _currentLocation;
    if (!_mapReady || location == null || _didCenterOnLocation) return;

    _didCenterOnLocation = true;
    mapControl.move(location, 15);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Color(0xFFEDEDED),
        title:const Text("Map"),
        backgroundColor: kMuted,
      ), // AppBar
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapControl,
              options: MapOptions(
                initialCenter: _currentLocation ?? const LatLng(0,0),
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
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.fishdexteam.fishdex',
              ), // Tile Layer
              CurrentLocationLayer(
                style: LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.white,
                    ), // Icon
                  ), // DefaultLocationMarker
                  markerSize: Size(35, 35),
                  markerDirection: MarkerDirection.heading,
                ), // LocationMarkerStyle
              ), // CurrentLocationLayer
            ],
          ), // FlutterMap
        ],
      ), // Stack
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: _userCurrentLocation,
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.my_location, size:30,
          color: Colors.white,
        ), // Icon
      ),
    ); // Scaffold
  }
}


// class _MapScreenState extends State<MapScreen> {
//   String? _selected;
//
//   static const _spots = [
//     Offset(0.30, 0.25),
//     Offset(0.65, 0.40),
//     Offset(0.45, 0.70),
//     Offset(0.78, 0.78),
//     Offset(0.20, 0.60),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     final withPlace = store.catches.where((c) => c.place.isNotEmpty).toList();
//     final selected =
//         withPlace.where((c) => c.id == _selected).cast<CatchItem?>().firstOrNull;
//     return Scaffold(
//       body: Column(
//         children: [
//           const TopBar(title: 'Map', back: '<'),
//           Expanded(
//             child: Container(
//               margin: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFEDEDED),
//                 border: Border.all(color: kLine),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               clipBehavior: Clip.antiAlias,
//               child: LayoutBuilder(
//                 builder: (context, box) {
//                   return Stack(
//                     children: [
//                       Positioned.fill(
//                         child: CustomPaint(painter: _GridPainter()),
//                       ),
//                       for (var i = 0; i < withPlace.length; i++)
//                         Positioned(
//                           left: _spots[i % _spots.length].dx * box.maxWidth - 16,
//                           top: _spots[i % _spots.length].dy * box.maxHeight - 32,
//                           child: GestureDetector(
//                             onTap: () =>
//                                 setState(() => _selected = withPlace[i].id),
//                             child: Icon(
//                               Icons.location_on,
//                               size: 36,
//                               color: withPlace[i].id == _selected
//                                   ? kInk
//                                   : kDark.withValues(alpha: 0.7),
//                             ),
//                           ),
//                         ),
//                       const Positioned(
//                         right: 8,
//                         bottom: 6,
//                         child: Text('Map placeholder',
//                             style: TextStyle(fontSize: 11, color: kMuted)),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//             child: selected == null
//                 ? const InfoRow(
//                     title: 'Tap a pin',
//                     subtitle: 'See which fish you caught there',
//                   )
//                 : InfoRow(
//                     title: selected.species,
//                     subtitle: selected.subtitle,
//                     trailing: const Text('>', style: TextStyle(fontSize: 18)),
//                     onTap: () => Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (_) =>
//                             CatchDetailsScreen(catchId: selected.id),
//                       ),
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _GridPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final p = Paint()
//       ..color = const Color(0xFFD0D0D0)
//       ..strokeWidth = 1;
//     for (double x = 0; x < size.width; x += 40) {
//       canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
//     }
//     for (double y = 0; y < size.height; y += 40) {
//       canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
//     }
//     final river = Paint()
//       ..color = const Color(0xFFC4C4C4)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 18;
//     final path = Path()
//       ..moveTo(0, size.height * 0.2)
//       ..quadraticBezierTo(size.width * 0.5, size.height * 0.55, size.width,
//           size.height * 0.35);
//     canvas.drawPath(path, river);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
//}
