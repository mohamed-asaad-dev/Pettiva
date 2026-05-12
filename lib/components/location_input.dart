import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:pettiva_v2/config/secrets.dart';
import 'package:pettiva_v2/screens/maps.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({
    super.key,
    required this.getFormattedAddress,
    required this.getPosition,
  });
  final void Function(String address) getFormattedAddress;
  final void Function(double latitude, double longitude) getPosition;
  @override
  State<LocationInput> createState() {
    return LocationInputState();
  }
}

class LocationInputState extends State<LocationInput> {
  LatLng? position;
  void getLocation(double lat, double lng) async {
    setState(() {
      position = LatLng(lat, lng);
    });
    widget.getPosition(lat, lng);

    //this part is used for reverse geocoding
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${Secrets.googleMapsApiKey}',
    );
    final response = await http.post(url);
    final data = json.decode(response.body);
    widget.getFormattedAddress(data['results'][0]['formatted_address']);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Container(
              child: position == null
                  ? Icon(
                      Icons.map,
                      color: Color.fromRGBO(251, 176, 59, 1),
                      size: 30,
                    )
                  : Image.network(
                      'https://maps.googleapis.com/maps/api/staticmap?center=${position!.latitude},${position!.longitude}&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:Here%7C${position!.latitude},${position!.longitude}&key=${Secrets.googleMapsApiKey}',
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
