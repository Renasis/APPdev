import 'package:flutter/material.dart';

import '../models/saved_build_model.dart';

class SavedBuildProvider extends ChangeNotifier {
  final List<SavedBuildModel> _savedBuilds = [];

  List<SavedBuildModel> get savedBuilds =>
      List.unmodifiable(_savedBuilds);

  void addBuild(SavedBuildModel build) {
    _savedBuilds.add(build);
    notifyListeners();
  }

  void removeBuild(String id) {
    _savedBuilds.removeWhere(
      (build) => build.id == id,
    );

    notifyListeners();
  }

  void clearBuilds() {
    _savedBuilds.clear();
    notifyListeners();
  }
}