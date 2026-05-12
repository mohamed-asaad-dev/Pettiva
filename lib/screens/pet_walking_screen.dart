//import 'dart:developer';

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pettiva_v2/components/location_input.dart';
import 'package:intl/intl.dart';
// import 'package:pettiva_v2/models/order_summary.dart';
import 'package:pettiva_v2/models/pet.dart';
// import 'package:pettiva_v2/providers/oders_provider.dart';
import 'package:pettiva_v2/providers/pets_provider.dart';
import 'package:pettiva_v2/screens/maps.dart';
import 'package:pettiva_v2/screens/order_summary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:pettiva_v2/config/secrets.dart';

enum ServiceType { standard, premium }

class PetWalkingScreen extends ConsumerStatefulWidget {
  const PetWalkingScreen({super.key});

  @override
  ConsumerState<PetWalkingScreen> createState() {
    return _PetWalkingScreenState();
  }
}

class _PetWalkingScreenState extends ConsumerState<PetWalkingScreen> {
  Set<ServiceType> _selectedPetType = {ServiceType.standard};

  String? selectedPet;

  String? addressDetails;
  String? buildingNumber;
  String? floorNumber;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  List<Pet>? listPets;
  double? clientLatitude;
  double? clientLongitude;
  final formKey = GlobalKey<FormState>();

  LatLng? position;

  final TextEditingController addressController = TextEditingController();
  final formatter = DateFormat.yMd();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _dayOfRequest() async {
    DateTime now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 12),
      lastDate: DateTime(now.year + 2),
    );
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _timeOfRequest() async {
    TimeOfDay now = TimeOfDay.now();
    final pickedTime = await showTimePicker(context: context, initialTime: now);
    setState(() {
      _selectedTime = pickedTime;
    });
  }

  void getLocation(double lat, double lng) async {
    setState(() {
      position = LatLng(lat, lng);
      clientLatitude = position!.latitude;
      clientLongitude = position!.longitude;
    });

    //this part is used for reverse geocoding
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${Secrets.googleMapsApiKey}',
    );
    final response = await http.post(url);
    final data = json.decode(response.body);
    setState(() {
      addressDetails = data['results'][0]['formatted_address'];
      addressController.text = addressDetails!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final listPets = ref.watch(petsProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
      body: Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.secondaryContainer,

        child: Stack(
          children: [
            Column(
              children: [
                SegmentedButton<ServiceType>(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      // if (states.contains(WidgetState.selected)) {
                      //   return Color.fromRGBO(251, 176, 59, 1);
                      // }
                      return Theme.of(context).colorScheme.onPrimaryContainer;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return Color.fromRGBO(251, 176, 59, 1);
                      }
                      return Colors.white;
                    }),
                    elevation: WidgetStateProperty.resolveWith<double>((
                      states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return 100;
                      }
                      return 1;
                    }),
                  ),
                  segments: [
                    ButtonSegment(
                      value: ServiceType.standard,
                      label: Text('Standard'),
                      icon: Icon(Icons.add),
                    ),
                    ButtonSegment(
                      value: ServiceType.premium,
                      label: Text('Premium'),
                      icon: Icon(Icons.star_border),
                    ),
                  ],
                  selected: _selectedPetType,
                  onSelectionChanged: (Set<ServiceType> newSelection) {
                    setState(() {
                      _selectedPetType = newSelection;
                    });
                  },
                ),
                SizedBox(height: 15),
                // if (_selectedPetType == ServiceType.standard)
                Column(
                  children: [
                    //selecting pet from dropdown menu
                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),

                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                        child: DropdownMenu<Pet>(
                          inputDecorationTheme: const InputDecorationTheme(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            alignLabelWithHint: true,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          textStyle: TextStyle(
                            fontSize: 19,
                            color: Colors.white,
                          ),

                          menuStyle: MenuStyle(
                            maximumSize: WidgetStateProperty.resolveWith<Size>(
                              (states) => Size(
                                MediaQuery.of(context).size.width - 40,
                                200,
                              ),
                            ),
                            // padding: WidgetStateProperty.resolveWith<EdgeInsets>((
                            //   states,
                            // ) {
                            //   return EdgeInsets.only(left: 15, right: 15);
                            // }),
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color>((
                                  states,
                                ) {
                                  if (states.contains(WidgetState.selected)) {
                                    return Color.fromRGBO(251, 176, 59, 1);
                                  }
                                  return Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer;
                                }),
                          ),

                          label: Text(
                            'select pet',
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(
                                  color: Color.fromRGBO(251, 176, 59, 1),
                                ),
                          ),
                          leadingIcon: Icon(
                            Icons.pets_sharp,
                            color: Color.fromRGBO(251, 176, 59, 1),
                            size: 25,
                          ),
                          onSelected: (value) {
                            selectedPet = value!.name;
                          },
                          width: double.infinity - 50,
                          dropdownMenuEntries: [
                            for (final pet in listPets)
                              DropdownMenuEntry(
                                value: pet,
                                label: pet.name,

                                style: ButtonStyle(
                                  textStyle:
                                      WidgetStateProperty.resolveWith<
                                        TextStyle
                                      >((states) {
                                        return TextStyle(fontSize: 19);
                                      }),
                                  foregroundColor:
                                      WidgetStateProperty.resolveWith<Color>((
                                        states,
                                      ) {
                                        if (states.contains(
                                          WidgetState.selected,
                                        )) {
                                          return Theme.of(
                                            context,
                                          ).colorScheme.secondaryContainer;
                                        }
                                        return Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer;
                                      }),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    //information form
                    Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Card(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                  bottom: 8,
                                ),
                                child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  style: const TextStyle(color: Colors.white),
                                  controller: addressController,
                                  maxLines: 1,

                                  decoration: InputDecoration(
                                    labelText: 'Address',
                                    labelStyle: const TextStyle(
                                      color: Color.fromRGBO(251, 176, 59, 1),
                                    ),

                                    suffixIcon: IconButton(
                                      icon: const Icon(
                                        Icons.map,
                                        color: Color.fromRGBO(251, 176, 59, 1),
                                      ),
                                      onPressed: () async {
                                        // selectLocation();
                                        final location =
                                            await Navigator.of(
                                              context,
                                            ).push<LatLng>(
                                              MaterialPageRoute(
                                                builder: (ctx) {
                                                  return MapsScreen();
                                                },
                                              ),
                                            );
                                        if (location == null) {
                                          print('No location was picked');
                                          return;
                                        }
                                        getLocation(
                                          location.latitude,
                                          location.longitude,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                  bottom: 8,
                                ),
                                child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  style: TextStyle(color: Colors.white),

                                  decoration: InputDecoration(
                                    hint: Text(
                                      'Building Number',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                  onSaved: (newValue) {
                                    buildingNumber = newValue;
                                  },
                                ),
                              ),
                            ),
                            Card(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                  bottom: 8,
                                ),
                                child: TextFormField(
                                  style: TextStyle(color: Colors.white),

                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    hint: Text(
                                      'Floor Number',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                  onSaved: (newValue) {
                                    floorNumber = newValue;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (clientLatitude != null)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(15),
                            right: Radius.circular(15),
                          ),
                        ),
                        padding: EdgeInsets.all(25),
                        child: Image.network(
                          'https://maps.googleapis.com/maps/api/staticmap?center=${clientLatitude!},${clientLongitude!}&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:Here%7C${clientLatitude!},${clientLongitude!}&key=${Secrets.googleMapsApiKey}',
                          fit: BoxFit.fill,
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.monetization_on_outlined,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          if (_selectedPetType.contains(ServiceType.standard))
                            Text(
                              '50',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (_selectedPetType.contains(ServiceType.premium))
                            Text(
                              '70',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          Spacer(),
                          _selectedDate == null
                              ? IconButton(
                                  onPressed: _dayOfRequest,
                                  icon: Icon(
                                    Icons.calendar_month,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                )
                              : InkWell(
                                  onTap: _dayOfRequest,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Card(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          formatter.format(_selectedDate!),
                                          style: TextStyle(
                                            color: Color.fromRGBO(
                                              251,
                                              176,
                                              59,
                                              1,
                                            ),

                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          _selectedTime == null
                              ? IconButton(
                                  onPressed: _timeOfRequest,
                                  icon: Icon(
                                    Icons.timelapse_outlined,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                                )
                              : InkWell(
                                  onTap: _timeOfRequest,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Card(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          _selectedTime!.format(context),
                                          style: TextStyle(
                                            color: Color.fromRGBO(
                                              251,
                                              176,
                                              59,
                                              1,
                                            ),
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),

                    SizedBox(height: 80),
                  ],
                ),
              ],
            ),
            if (_selectedPetType.contains(ServiceType.standard))
              Positioned(
                bottom: 121,
                left: 5,
                child: Text(
                  'Standard pet walking service allows your dog\n to interact with other dogs in a proffesional walk.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
            if (_selectedPetType.contains(ServiceType.standard))
              Positioned(
                bottom: 40,
                left: MediaQuery.of(context).size.width / (15 / 4),
                right: MediaQuery.of(context).size.width / (15 / 4),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateColor.resolveWith((states) {
                      return Theme.of(context).colorScheme.onPrimaryContainer;
                    }),
                  ),
                  onPressed: () async {
                    formKey.currentState!.save();

                    if (selectedPet == null ||
                        addressController.text.isEmpty ||
                        buildingNumber == null ||
                        buildingNumber!.isEmpty ||
                        floorNumber == null ||
                        floorNumber!.isEmpty ||
                        _selectedDate == null ||
                        _selectedTime == null ||
                        clientLatitude == null) {
                      print('Please complete all required fields');
                      return;
                    }
                    try {
                      final userId = FirebaseAuth.instance.currentUser!.uid;
                      await FirebaseFirestore.instance
                          .collection('orders')
                          .add({
                            'userId': userId,
                            'serviceType': _selectedPetType.first.name,
                            'selectedPet': selectedPet,
                            'address': addressController.text,
                            'buildingNumber': buildingNumber,
                            'floorNumber': floorNumber,
                            'date': Timestamp.fromDate(_selectedDate!),
                            'time': _selectedTime!.format(context),
                            'createdAt': Timestamp.now(),
                            'status': 'posted',
                            'acceptedBy': '',
                            'rejectedBy': [],
                            'latitude': clientLatitude,
                            'longitude': clientLongitude,
                            'price': 50,
                          });
                    } catch (e) {
                      print(e.toString());
                    }

                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => OrderSummaryScreen(
                          // lengthOrderList: (lengthList) {},
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color.fromRGBO(251, 176, 59, 1),
                        ),
                        const SizedBox(width: 3),
                        const Text(
                          'Confirm Request',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromRGBO(251, 176, 59, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_selectedPetType.contains(ServiceType.premium))
              Positioned(
                bottom: 121,
                left: 45,
                child: Text(
                  'Let your dog get the A-class private walk.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
            if (_selectedPetType.contains(ServiceType.premium))
              Positioned(
                bottom: 40,
                left: MediaQuery.of(context).size.width / (15 / 4),
                right: MediaQuery.of(context).size.width / (15 / 4),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateColor.resolveWith((states) {
                      return Theme.of(context).colorScheme.onPrimaryContainer;
                    }),
                  ),
                  onPressed: () async {
                    formKey.currentState!.save();

                    if (selectedPet == null ||
                        addressController.text.isEmpty ||
                        buildingNumber == null ||
                        buildingNumber!.isEmpty ||
                        floorNumber == null ||
                        floorNumber!.isEmpty ||
                        _selectedDate == null ||
                        _selectedTime == null ||
                        clientLatitude == null) {
                      print('Please complete all required fields');
                      return;
                    }
                    try {
                      final userId = FirebaseAuth.instance.currentUser!.uid;
                      await FirebaseFirestore.instance
                          .collection('orders')
                          .add({
                            'userId': userId,
                            'serviceType': _selectedPetType.first.name,
                            'selectedPet': selectedPet,
                            'address': addressController.text,
                            'buildingNumber': buildingNumber,
                            'floorNumber': floorNumber,
                            'date': Timestamp.fromDate(_selectedDate!),
                            'time': _selectedTime!.format(context),
                            'createdAt': Timestamp.now(),
                            'status': 'posted',
                            'acceptedBy': '',
                            'rejectedBy': [],
                            'latitude': clientLatitude,
                            'longitude': clientLongitude,
                            'price': 70,
                          });
                    } catch (e) {
                      print(e.toString());
                    }

                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => OrderSummaryScreen(
                          // lengthOrderList: (lengthList) {},
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color.fromRGBO(251, 176, 59, 1),
                        ),
                        const SizedBox(width: 3),
                        const Text(
                          'Confirm Request',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromRGBO(251, 176, 59, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
