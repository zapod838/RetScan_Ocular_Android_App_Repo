import 'dart:io';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  File? imageFile;

  void setImage(File? file) {
    imageFile = file;
    notifyListeners();
  }

  String predictDisease(File image) {
    // Interface with ML model logic here
    return "Predicted Condition: Glaucoma";
  }
}
