import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pettiva_v2/models/user_information.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key, required this.userData});
  final UserInformation userData;
  @override
  State<AccountSettingsScreen> createState() {
    return _AccountSettingsScreenState();
  }
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  String userDocumentId = '';
  TextEditingController userNameController = TextEditingController();
  bool isEditingUserName = false;
  bool isEditingEmailAddress = false;
  String updatedUsername = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          spacing: double.minPositive,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 17, bottom: 2),
              child: Text(
                'Name',
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 16,
                  color: const Color.fromRGBO(251, 176, 59, 1),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                          right: 8,
                          bottom: 8.0,
                        ),
                        child: TextFormField(
                          enabled: isEditingUserName,
                          initialValue: widget.userData.name.replaceFirst(
                            widget.userData.name[0],
                            widget.userData.name[0].toUpperCase(),
                          ),

                          validator: (value) {
                            if (value == null || value.trim().length < 4) {
                              return 'Minimum 4 characters';
                            }
                            return null;
                          },

                          onFieldSubmitted: (value) async {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }

                            final userInformation = await FirebaseFirestore
                                .instance
                                .collection('users')
                                .where(
                                  'userId',
                                  isEqualTo:
                                      FirebaseAuth.instance.currentUser!.uid,
                                )
                                .limit(1)
                                .get();

                            final userDocumentId =
                                userInformation.docs.first.id;

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userDocumentId)
                                .update({'userName': value.trim()});

                            setState(() {
                              isEditingUserName = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                content: Center(
                                  child: Text('Username updated'),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  if (isEditingUserName == false)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isEditingUserName = true;
                        });
                      },
                      icon: Icon(Icons.edit),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 17, bottom: 2),
              child: Text(
                'Email Address',
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 16,
                  color: const Color.fromRGBO(251, 176, 59, 1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                          right: 8,
                          bottom: 8.0,
                        ),
                        child: TextFormField(
                          enabled: isEditingEmailAddress,
                          initialValue: widget.userData.emailAddress,

                          validator: (value) {
                            if (value == null || value.trim().length < 4) {
                              return 'Minimum 4 characters';
                            }
                            return null;
                          },

                          onFieldSubmitted: (value) async {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }

                            try {
                              final user = FirebaseAuth.instance.currentUser!;

                              // send verification email
                              await user.verifyBeforeUpdateEmail(value.trim());

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                  content: const Center(
                                    child: Text(
                                      'Verification email sent. Please verify.',
                                    ),
                                  ),
                                ),
                              );

                              // wait until verification is completed
                              bool verified = false;

                              while (!verified) {
                                await Future.delayed(
                                  const Duration(seconds: 3),
                                );

                                await user.reload();

                                final refreshedUser =
                                    FirebaseAuth.instance.currentUser!;

                                // Firebase updates currentUser.email
                                // only after verification
                                if (refreshedUser.email == value.trim()) {
                                  verified = true;
                                }
                              }

                              // get user document
                              final userInformation = await FirebaseFirestore
                                  .instance
                                  .collection('users')
                                  .where(
                                    'userId',
                                    isEqualTo:
                                        FirebaseAuth.instance.currentUser!.uid,
                                  )
                                  .limit(1)
                                  .get();

                              final userDocumentId =
                                  userInformation.docs.first.id;

                              // update firestore only AFTER verification
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userDocumentId)
                                  .update({'emailAddress': value.trim()});

                              if (!mounted) return;

                              setState(() {
                                isEditingEmailAddress = false;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  content: const Center(
                                    child: Text('Email updated successfully'),
                                  ),
                                ),
                              );
                            } on FirebaseAuthException catch (e) {
                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.message ?? 'Error')),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  if (isEditingEmailAddress == false)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isEditingEmailAddress = true;
                        });
                      },
                      icon: Icon(Icons.edit),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 17, bottom: 2),
              child: Text(
                'Password',
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 16,
                  color: const Color.fromRGBO(251, 176, 59, 1),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8,
                      right: 8,
                      left: 8,
                    ),
                    child: TextFormField(
                      obscureText: true,
                      initialValue: 'miha',
                    ),
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
