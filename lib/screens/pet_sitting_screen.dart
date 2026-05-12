import 'package:flutter/material.dart';

class PetSittingScreen extends StatelessWidget {
  const PetSittingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: Theme.of(context).colorScheme.onPrimary,
        child: Text('Sitting Screen'),
      ),
    );
  }
}
