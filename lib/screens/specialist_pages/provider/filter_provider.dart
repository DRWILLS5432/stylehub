// filter_provider.dart
import 'package:flutter/material.dart';

class FilterProvider with ChangeNotifier {
  String? _selectedCity;
  String? _selectedCategory;
  bool _nearestSpecialists = false;
  bool _specialistsInCity = false;
  bool _highestRating = false;
  bool _mediumRating = false;
  bool _filtersApplied = false;

  // Getters
  String? get selectedCity => _selectedCity;
  String? get selectedCategory => _selectedCategory;
  bool get nearestSpecialists => _nearestSpecialists;
  bool get specialistsInCity => _specialistsInCity;
  bool get highestRating => _highestRating;
  bool get mediumRating => _mediumRating;
  bool get filtersApplied => _filtersApplied;

  void setSelectedCity(String? city) {
    _selectedCity = city;
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleNearestSpecialists(bool value) {
    _nearestSpecialists = value;
    notifyListeners();
  }

  void toggleSpecialistsInCity(bool value) {
    _specialistsInCity = value;
    notifyListeners();
  }

  void toggleHighestRating(bool value) {
    _highestRating = value;
    notifyListeners();
  }

  void toggleMediumRating(bool value) {
    _mediumRating = value;
    notifyListeners();
  }

  void applyFilters() {
    _filtersApplied = true;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCity = null;
    _selectedCategory = null;
    _nearestSpecialists = false;
    _specialistsInCity = false;
    _highestRating = false;
    _mediumRating = false;
    _filtersApplied = false;
    notifyListeners();
  }
}
