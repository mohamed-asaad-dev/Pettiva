import 'dart:io';

class UserInformation {
  UserInformation({required this.name, required this.emailAddress, this.image});
  String name;
  String emailAddress;
  File? image;
  String? userType;
}
