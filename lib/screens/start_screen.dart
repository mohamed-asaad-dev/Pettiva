import 'dart:io';

import 'package:flutter/material.dart';

// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pettiva_v2/components/pets_card.dart';

//import 'package:pettiva_v1/models/pet.dart';
import 'package:pettiva_v2/screens/discount_screen.dart';
import 'package:pettiva_v2/screens/order_summary.dart';
import 'package:pettiva_v2/screens/pet_sitting_screen.dart';
import '../components/fun_facts_cards.dart';
import 'pet_walking_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key, required this.listLength});
  final int listLength;

  void petWalkerSelected(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (builder) {
          return PetWalkingScreen();
        },
      ),
    );
  }

  void petSitterSelected(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (builder) {
          return PetSittingScreen();
        },
      ),
    );
  }

  void discountSelected(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (builder) {
          return DiscountScreen();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Stack(
        children: [
          ListView(
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      petWalkerSelected(context);
                    },
                    borderRadius: BorderRadius.circular(18),
                    hoverColor: Colors.amberAccent,
                    splashColor: Theme.of(context).colorScheme.primary,
                    child: Container(
                      height: 110,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(45),
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.onPrimaryContainer,
                            Theme.of(context).colorScheme.onPrimaryContainer,
                          ],
                          begin: AlignmentGeometry.topLeft,
                          end: AlignmentGeometry.bottomRight,
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/Walker.png',
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  InkWell(
                    onTap: () {
                      return petSitterSelected(context);
                    },
                    borderRadius: BorderRadius.circular(18),
                    hoverColor: Colors.amberAccent,
                    splashColor: Theme.of(context).colorScheme.primary,
                    child: Container(
                      height: 110,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(45),
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.onPrimaryContainer,
                            Theme.of(context).colorScheme.onPrimaryContainer,
                          ],
                          begin: AlignmentGeometry.topLeft,
                          end: AlignmentGeometry.bottomRight,
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/Sitter.png',
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              FunFactsCards(),
              SizedBox(height: 20),
              PetsCard(pickedImage: File(''), getListPets: (p0) {}),
              TextButton(
                onPressed: () {
                  return discountSelected(context);
                },
                child: Image.asset(
                  'assets/images/Pay_less.png',
                  width: 150,
                  height: 150,
                  color: const Color.fromRGBO(251, 176, 59, 1),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 15,
            right: 15,
            child: FloatingActionButton.large(
              shape: CircleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 2,
                ),
              ),
              child: Icon(Icons.delivery_dining),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) {
                      return OrderSummaryScreen();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
