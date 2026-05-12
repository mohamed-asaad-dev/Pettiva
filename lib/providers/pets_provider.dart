import 'package:pettiva_v2/models/pet.dart';
import 'package:flutter_riverpod/legacy.dart';

class PetsNotifier extends StateNotifier<List<Pet>> {
  PetsNotifier() : super([]);
  void addPet(Pet pet) {
    state = [...state, pet];
  }
}

final petsProvider = StateNotifierProvider<PetsNotifier, List<Pet>>((ref) {
  return PetsNotifier();
});
