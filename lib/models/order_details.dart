import 'package:flutter/material.dart';
import '../screens/pet_walking_screen.dart';

class OrderDetails {
  OrderDetails(
    this.serviceType,

    this.status,
    // this.userId,
    this.addressDetails,
    this.buildingNumber,
    this.floorNumber,
    this.selectedDate,
    this.selectedTime,
  );

  String serviceType;

  // String userId;

  String status;

  String? selectedPet;

  String addressDetails;
  String buildingNumber;
  String floorNumber;

  DateTime selectedDate;
  TimeOfDay selectedTime;
}
