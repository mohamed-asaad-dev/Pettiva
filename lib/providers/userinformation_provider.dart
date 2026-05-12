// import 'dart:io';

import 'dart:io';

import 'package:flutter_riverpod/legacy.dart';

import 'package:pettiva_v2/models/user_information.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:path/path.dart' as path;

class UserinformationNotifier extends StateNotifier<UserInformation> {
  UserinformationNotifier()
    : super(UserInformation(name: '', emailAddress: '', image: null));

  Future<Database> _getDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(
      path.join(dbPath, 'userInformation.db'),
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE user_information(name TEXT, email TEXT, image TEXT)',
        );
      },
      version: 1,
    );
    return db;
  }

  Future<void> loadData() async {
    final db = await _getDatabase();
    final dataBase = await db.query('user_information');

    if (dataBase.isEmpty) {
      return;
    }

    final user = dataBase.first;
    final imagePath = user['image'] as String?;

    File? imageFile;

    if (imagePath != null && await File(imagePath).exists()) {
      imageFile = File(imagePath);
    }

    state = UserInformation(
      name: user['name'] as String,
      emailAddress: user['email'] as String,
      image: imageFile,
    );
  }

  void saveInformation(UserInformation information) async {
    File? copiedImage;
    if (information.image != null) {
      final systemPath = await syspath.getApplicationDocumentsDirectory();
      final imageName = path.basename(information.image!.path);
      copiedImage = await information.image!.copy(
        '${systemPath.path}/$imageName',
      );
    }

    final newInformation = UserInformation(
      name: information.name,
      emailAddress: information.emailAddress,
      image: copiedImage,
    );
    state = newInformation;

    final db = await _getDatabase();
    await db.delete('user_information');
    await db.insert('user_information', {
      'name': newInformation.name,
      'email': newInformation.emailAddress,
      'image': newInformation.image?.path,
    });
  }

  void changeName(String name) {
    state.name = name;
  }
}

final userInformationProvider =
    StateNotifierProvider<UserinformationNotifier, UserInformation>((ref) {
      return UserinformationNotifier();
    });
