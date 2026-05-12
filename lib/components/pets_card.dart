import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pettiva_v2/components/new_pet.dart';
import 'package:pettiva_v2/models/pet.dart';
//import 'package:pettiva_v1/models/pet.dart';
// import 'package:pettiva_v1/providers/pets_provider.dart';
import 'package:http/http.dart' as http;
import 'package:pettiva_v2/providers/pets_provider.dart';

class PetsCard extends ConsumerStatefulWidget {
  const PetsCard({
    super.key,
    required this.pickedImage,
    required this.getListPets,
  });
  final File pickedImage;
  final void Function(List<Pet>) getListPets;

  @override
  ConsumerState<PetsCard> createState() => _PetsCardState();
}

class _PetsCardState extends ConsumerState<PetsCard> {
  List<Pet> petsList = [];

  void _showBottomSheet() async {
    await showModalBottomSheet<File>(
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return NewPet(loadData: _loadData);
      },
    );
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  void _loadData() async {
    final url = Uri.https(
      'pettiva-af8e4-default-rtdb.firebaseio.com',
      'pets_list.json',
    );
    final response = await http.get(url);
    final Map<String, dynamic> mPetsList = json.decode(response.body);
    final List<Pet> list = [];
    final userId = FirebaseAuth.instance.currentUser!.uid;
    for (final pet in mPetsList.entries) {
      ref
          .read(petsProvider.notifier)
          .addPet(
            Pet(
              id: userId,
              dateOfBirth: DateTime.parse(pet.value["Date"]),
              name: pet.value["Name"],
              image: 'assets/images/dog_with_bone.png',
              imagePath: pet.value["imagePath"],
            ),
          );

      if (pet.value['userId'] == userId) {
        list.add(
          Pet(
            id: pet.key,
            dateOfBirth: DateTime.parse(pet.value["Date"]),
            name: pet.value["Name"],
            image: 'assets/images/dog_with_bone.png',
            imagePath: pet.value["imagePath"],
          ),
        );
      }
    }
    setState(() {
      petsList = list;
    });
    widget.getListPets(petsList);
  }

  @override
  Widget build(BuildContext context) {
    // final petsList = ref.watch(petsProvider);
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Card(
          margin: EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(35),
          ),
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Add pet',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  IconButton(
                    onPressed: _showBottomSheet,
                    icon: Icon(
                      Icons.add,
                      color: const Color.fromRGBO(251, 176, 59, 1),
                    ),
                  ),
                ],
              ),
              ...petsList.map((petInformation) {
                return Stack(
                  // mainAxisSize: MainAxisSize.min,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                petInformation.name.replaceFirst(
                                  petInformation.name[0],
                                  petInformation.name[0].toUpperCase(),
                                ),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              IconButton(
                                onPressed: () async {
                                  final url = Uri.https(
                                    'pettiva-af8e4-default-rtdb.firebaseio.com',
                                    'pets_list/${petInformation.id}.json',
                                  );
                                  await http.delete(url);
                                  _loadData();
                                },
                                icon: Icon(Icons.remove),
                              ),
                            ],
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),

                        //   child: Text(
                        //     'Breed',
                        //     style: Theme.of(
                        //       context,
                        //     ).textTheme.bodyMedium!.copyWith(fontSize: 19),
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 15),
                          child: Text(
                            petInformation.formattedDate,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 20,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 35,
                        backgroundImage: petInformation.avatarImage,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
