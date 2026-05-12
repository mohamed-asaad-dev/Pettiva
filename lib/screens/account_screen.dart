import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pettiva_v2/components/account_screen_items.dart';
import 'package:pettiva_v2/components/image_input.dart';
import 'package:pettiva_v2/models/user_information.dart';
import 'package:pettiva_v2/screens/account_settings.dart';
import 'package:pettiva_v2/screens/orders_history.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key, required this.getUserData});
  final void Function(UserInformation userInformation) getUserData;

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  UserInformation userInformation = UserInformation(name: '', emailAddress: '');

  // Stored once in initState so FutureBuilder never creates a new Future on rebuild.
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadData();
  }

  Future<void> _loadData() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final response = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (response.docs.isEmpty) return;

    final doc = response.docs.first.data();
    final imagePath = doc['image'] as String?;

    final info = UserInformation(
      name: doc['userName'] as String? ?? '',
      emailAddress: doc['emailAddress'] as String? ?? '',
      image: imagePath == null ? null : File(imagePath),
    );

    if (mounted) {
      setState(() {
        userInformation = info;
      });
    }

    widget.getUserData(info);
  }

  Future<void> _pickPhoto() async {
    final picked = await ImageInput().cameraImage();
    if (picked == null) return;
    if (mounted) {
      setState(() {
        userInformation.image = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Theme.of(context).colorScheme.secondaryContainer,
            height: double.infinity,
            width: double.infinity,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        // Guard: name must not be empty before indexing [0]
        final displayName = userInformation.name.isNotEmpty
            ? userInformation.name.replaceFirst(
                userInformation.name[0],
                userInformation.name[0].toUpperCase(),
              )
            : '';

        return Container(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Color.fromRGBO(251, 176, 59, 1),
                                ),
                                Text(
                                  '5',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromRGBO(
                                      251,
                                      176,
                                      59,
                                      1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            backgroundImage: userInformation.image == null
                                ? null
                                : FileImage(File(userInformation.image!.path)),
                          ),
                          TextButton.icon(
                            icon: Icon(
                              Icons.add,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: _pickPhoto,
                            label: const Text('Add photo'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AccountScreenItems(
                  itemIcon: Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  itemTitle: 'Settings',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return AccountSettingsScreen(
                            userData: UserInformation(
                              emailAddress: userInformation.emailAddress,
                              name: userInformation.name,
                              image: userInformation.image,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                AccountScreenItems(
                  itemIcon: Icon(
                    Icons.history,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  itemTitle: 'History',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => OrdersHistoryScreen(),
                      ),
                    );
                  },
                ),
                AccountScreenItems(
                  itemIcon: Icon(
                    Icons.help,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  itemTitle: 'Help',
                  onPressed: () {},
                ),
                AccountScreenItems(
                  itemTitle: 'Terms & conditions',
                  itemIcon: Icon(
                    Icons.policy,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
