import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart'; // For geocoding the search query

class Googlemap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;
  
  const Googlemap({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  }) : super(key: key);

  @override
  State<Googlemap> createState() => _GooglemapState();
}

class _GooglemapState extends State<Googlemap> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    _markers.add(
      Marker(
        markerId: MarkerId('initialLocation'),
        position: LatLng(widget.latitude, widget.longitude),
        infoWindow: InfoWindow(title: widget.locationName),
      ),
    );
  }

   Future<void> _searchLocation() async {
    String location = _searchController.text;
    if (location.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(location);
        if (locations.isNotEmpty) {
          Location loc = locations.first;
          LatLng target = LatLng(loc.latitude, loc.longitude);

          // Move the camera and add a marker
        _controller?.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: target, zoom: 16),
          ));

          setState(() {
            _markers.clear();
            _markers.add(
              Marker(
                markerId: MarkerId('searchedLocation'),
                position: target,
                infoWindow: InfoWindow(title: location),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
              ),
            );
          });
        }
      } catch (e) {
        print("Error searching location: $e");
      }
      }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.latitude, widget.longitude),
              zoom: 10.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              _moveToTargetLocation();
            },
            markers: _markers,
          ),
          Positioned(
            top: 40,
            left: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search location",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _searchLocation(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: _searchLocation,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _moveToTargetLocation() async {
    // Move the camera to the target location
    await _controller?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(widget.latitude, widget.longitude),
        zoom: 16.0,
      ),
    ));
  }
}
