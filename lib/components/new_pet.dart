import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pettiva_v2/models/pet.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pettiva_v1/providers/pets_provider.dart';
import 'package:http/http.dart' as http;

import 'package:image_picker/image_picker.dart';

class NewPet extends ConsumerStatefulWidget {
  const NewPet({super.key, required this.loadData});
  final void Function() loadData;

  @override
  ConsumerState<NewPet> createState() => _NewPetState();
}

class _NewPetState extends ConsumerState<NewPet> {
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  File? selectedImage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void pickImage() async {
    final pickedImage = ImagePicker();
    final newImage = await pickedImage.pickImage(source: ImageSource.camera);
    if (newImage == null) {
      return;
    }
    setState(() {
      selectedImage = File(newImage.path);
    });
  }

  void _dateOfBirth() async {
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

  void _addNewpet() async {
    if (_selectedDate == null || _nameController.toString().isEmpty) {
      if (Platform.isIOS) {
        showDialog(
          context: context,
          builder: (ctx) {
            return CupertinoAlertDialog(
              title: Text('Invalid Data'),
              content: Text('Make sure that you entered valid data'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(selectedImage);
                  },
                  child: Text('Okay'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text('Invalid Data'),
              content: Text('Make sure that you entered valid data'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: Text('Okay'),
                ),
              ],
            );
          },
        );
      }
    } else {
      // ref
      //     .read(petsProvider.notifier)
      //     .addPet(
      //       Pet(
      //         dateOfBirth: _selectedDate!,
      //         name: _nameController.text,
      //         image: 'assets/images/dog_with_bone.png',
      //       ),
      //     );
      final url = Uri.https(
        'pettiva-af8e4-default-rtdb.firebaseio.com',
        'pets_list.json',
      );
      final response = await http.post(
        url,
        headers: {'Content-type': 'application/json'},
        body: json.encode({
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'Name': _nameController.text,
          'Date': _selectedDate!.toIso8601String(),
          'imagePath': selectedImage?.path,
        }),
      );

      String petInformation = json.encode(response.body);
      print(petInformation);
      if (!context.mounted) {
        return;
      }

      Navigator.pop(context);
      widget.loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.pets, color: const Color.fromRGBO(251, 176, 59, 1)),
                SizedBox(width: 5),
                Text('Enter your pet\'s information!'),
              ],
            ),
            SizedBox(height: 6),
            TextField(
              controller: _nameController,
              keyboardType: TextInputType.text,
              maxLength: 50,

              decoration: InputDecoration(
                labelText: 'Pet\'s name',
                labelStyle: TextStyle(color: Colors.white),
              ),
              cursorColor: Colors.white,
              autocorrect: false,
              style: TextStyle(color: Colors.white),
            ),
            Container(
              height: 200,
              width: 200,
              child: selectedImage == null
                  ? TextButton.icon(
                      icon: Icon(
                        Icons.camera,
                        color: const Color.fromRGBO(251, 176, 59, 1),
                      ),
                      onPressed: pickImage,
                      label: Text(
                        'Pick an Image',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : Image.file(selectedImage!, width: double.infinity),
            ),
            SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _selectedDate == null
                      ? const Text('Date of Birth')
                      : Text(formatter.format(_selectedDate!)),
                  IconButton(
                    onPressed: _dateOfBirth,
                    icon: Icon(
                      Icons.calendar_month,
                      color: const Color.fromRGBO(251, 176, 59, 1),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    _addNewpet();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    iconColor: const Color.fromARGB(255, 225, 211, 85),
                  ),
                  child: Text('Okay'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
