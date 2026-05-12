import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pettiva_v2/components/image_input.dart';
import 'package:pettiva_v2/models/user_information.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  String _emailAddress = '';
  String _password = '';
  bool isLogin = true;
  String username = '';
  File? image;
  bool isClient = true;

  UserInformation? userInformation;

  final _form = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final callable = FirebaseFunctions.instance.httpsCallable(
    'createUserWithClaims',
  );

  Future<void> login() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) return;

    _form.currentState!.save();

    try {
      if (isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: _emailAddress.trim(),
          password: _password.trim(),
        );
      } else {
        // await callable.call(<String, dynamic>{
        //   'email': _emailAddress.trim(),
        //   'password': _password.trim(),
        //   'userType': 'client',
        // });
        await _auth.createUserWithEmailAndPassword(
          email: _emailAddress.trim(),
          password: _password.trim(),
        );
        userInformation = UserInformation(
          name: username,
          emailAddress: _emailAddress.trim(),
          image: image,
        );
        FirebaseFirestore.instance.collection('users').add({
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'userName': userInformation!.name,
          'emailAddress': userInformation!.emailAddress,
          'image': userInformation!.image?.path,
          'userType': isClient ? 'client' : 'fleet',
        });
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Authentication failed')),
      );
    }
  }

  void toggleSignIn() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  void userTypeToggle() {
    setState(() {
      isClient = !isClient;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: isClient == true
              ? Card(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  elevation: 20,
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/Pettiva.png',
                          width: 300,
                          height: 230,
                          // color: Theme.of(context).colorScheme.secondary,
                        ),
                        if (!isLogin)
                          InkWell(
                            onTap: () async {
                              final pickedImage = await ImageInput()
                                  .cameraImage();
                              if (pickedImage == null) {
                                return;
                              }
                              setState(() {
                                image = pickedImage;
                              });
                            },
                            child: image == null
                                ? Icon(
                                    Icons.image,
                                    color: const Color.fromRGBO(
                                      251,
                                      176,
                                      59,
                                      1,
                                    ),
                                  )
                                : CircleAvatar(
                                    minRadius: 40,
                                    backgroundImage: FileImage(
                                      File(image!.path),
                                    ),
                                  ),
                          ),

                        if (!isLogin)
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hint: Text(
                                  'Full name',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Invalid name';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                username = newValue!;
                              },
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),

                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: Colors.white),

                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              // labelText: 'Email',
                              hint: Text(
                                'Email',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Invalid email';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _emailAddress = newValue!;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),

                          child: TextFormField(
                            style: TextStyle(color: Colors.white),

                            decoration: const InputDecoration(
                              hint: Text(
                                'Password',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password should contain at least 6 characters';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _password = newValue!;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: login,
                          icon: const Icon(Icons.login),
                          label: Text(isLogin ? 'Sign in' : 'Sign up'),
                        ),
                        TextButton(
                          onPressed: toggleSignIn,
                          child: Text(
                            isLogin
                                ? 'Create an account'
                                : 'Already have an account',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: userTypeToggle,
                          label: Row(
                            children: [
                              Icon(
                                Icons.person_2,
                                size: 17,
                                color: const Color.fromRGBO(251, 176, 59, 1),
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Log in as a fleet',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Card(
                  elevation: 10,
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/Pettiva.png',
                          width: 300,
                          height: 230,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        if (!isLogin)
                          InkWell(
                            onTap: () async {
                              final pickedImage = await ImageInput()
                                  .cameraImage();
                              if (pickedImage == null) {
                                return;
                              }
                              setState(() {
                                image = pickedImage;
                              });
                            },
                            child: image == null
                                ? Icon(
                                    Icons.image,
                                    color: const Color.fromRGBO(
                                      251,
                                      176,
                                      59,
                                      1,
                                    ),
                                  )
                                : CircleAvatar(
                                    minRadius: 60,
                                    backgroundImage: FileImage(
                                      File(image!.path),
                                    ),
                                  ),
                          ),

                        if (!isLogin)
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Invalid name';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              username = newValue!;
                            },
                          ),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Invalid email';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _emailAddress = newValue!;
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return 'Password should contain at least 6 characters';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _password = newValue!;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: login,
                          icon: const Icon(Icons.login),
                          label: Text(isLogin ? 'Sign in' : 'Sign up'),
                        ),
                        TextButton(
                          onPressed: toggleSignIn,
                          child: Text(
                            isLogin
                                ? 'Create an account'
                                : 'Already have an account',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: userTypeToggle,
                          label: Row(
                            children: [
                              Icon(Icons.person_2),
                              Text(
                                'Log in as a client',

                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
