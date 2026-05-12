import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat.yMd();

class Pet {
  Pet({
    required this.id,
    required this.dateOfBirth,
    required this.name,
    required this.image,
    required this.imagePath,
  });

  final String id;
  final String name;
  final DateTime dateOfBirth;
  final String image;
  final String? imagePath;

  ImageProvider get avatarImage {
    if (imagePath == null || imagePath!.isEmpty) {
      return const AssetImage('assets/images/dog_with_bone.png');
    }
    return FileImage(File(imagePath!));
  }

  String get formattedDate {
    return formatter.format(dateOfBirth);
  }
}
