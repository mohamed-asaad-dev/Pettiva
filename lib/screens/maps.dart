import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapsScreen extends StatefulWidget {
  @override
  State<MapsScreen> createState() {
    return MapsScreenState();
  }
}

class MapsScreenState extends State<MapsScreen> {
  GoogleMapController? mapController;
  LatLng? pickedLocation;

  void selectLocation() async {
    final location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lng = locationData.longitude;
    if (lat == null || lng == null) {
      return;
    }
    setState(() {
      pickedLocation = LatLng(lat, lng);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectLocation();
  }

  @override
  Widget build(BuildContext context) {
    if (pickedLocation == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      floatingActionButton: ElevatedButton.icon(
        onPressed: pickedLocation == null
            ? null
            : () {
                Navigator.of(context).pop(pickedLocation);
              },
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_sharp),
            SizedBox(width: 5),
            Text('Pick Location'),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: GoogleMap(
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onTap: (position) {
          setState(() {
            pickedLocation = position;
          });
        },
        initialCameraPosition: CameraPosition(
          target: pickedLocation!,
          zoom: 12,
        ),
        markers: {
          Marker(
            markerId: MarkerId('m1'),
            position: pickedLocation!,
            icon: BitmapDescriptor.pinConfig(
              backgroundColor: Colors.blueAccent,
            ),
          ),
        },
      ),
    );
  }
}
