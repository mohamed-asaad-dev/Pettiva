// lib/config/secrets.example.dart
// Copy this file to secrets.dart and fill in your keys.
// secrets.dart is gitignored — never commit real keys.

class Secrets {
  static const googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
}
