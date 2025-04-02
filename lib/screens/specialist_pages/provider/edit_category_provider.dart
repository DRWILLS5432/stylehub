import 'package:flutter/material.dart';
import 'package:stylehub/screens/specialist_pages/model/categories_model.dart';
import 'package:stylehub/storage/category_service.dart';

class EditCategoryProvider extends ChangeNotifier {
  List<Service> _services = [Service()];
  List<Service> _submittedServices = [];
  List<String> _submittedCategories = [];
  List<Category> _availableCategories = [];
  final List<String> _selectedCategories = [];
  final FirebaseServices _firebaseService = FirebaseServices();

  // Getters
  List<Service> get services => _services;
  List<Service> get submittedServices => _submittedServices;
  List<String> get submittedCategories => _submittedCategories;
  List<Category> get availableCategories => _availableCategories;
  List<String> get selectedCategories => _selectedCategories;

  void addService() {
    _services.add(Service());
    notifyListeners();
  }

  void updateService(int index, String name, String price) {
    _services[index] = Service(name: name, price: price);
    notifyListeners();
  }

  void submitForm() {
    _submittedServices = List.from(_services.where((s) => s.name.isNotEmpty && s.price.isNotEmpty));
    _submittedCategories = List.from(_selectedCategories);
    _services = [Service()];
    notifyListeners();
  }

  void clearSelections() {
    _submittedServices.clear();
    _submittedCategories.clear();
    notifyListeners();
  }

  void clearAll() {
    _submittedServices.clear();
    _submittedCategories.clear();
    _services = [Service()];
    _selectedCategories.clear();
    notifyListeners();
  }

  void loadCategories() {
    _firebaseService.getCategories().listen((categories) {
      _availableCategories = categories;
      notifyListeners();
    });
  }
   void updateSubmittedCategories(List<String> categoryNames) {
    _submittedCategories = categoryNames;
    notifyListeners();
  }

  void toggleCategory(String categoryId) {
    if (_selectedCategories.contains(categoryId)) {
      _selectedCategories.remove(categoryId);
    } else {
      _selectedCategories.add(categoryId);
    }
    notifyListeners();
  }

  String getCategoryName(String categoryId, String languageCode) {
    try {
      final category = _availableCategories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => Category(id: '', name: 'Unknown', ruName: 'Unknown'),
      );
      return languageCode == 'ru' ? (category.ruName ?? category.name) : category.name;
    } catch (e) {
      debugPrint('Error getting category name: $e');
      return 'Unknown';
    }
  }

  // New method to get category names for current language
  List<String> getSelectedCategoryNames(String languageCode) {
    return _selectedCategories.map((id) => getCategoryName(id, languageCode)).toList();
  }
}

class Service {
  // This is a field, not a getter
  String name;
  String price;
  bool selected;

  Service({this.name = '', this.price = '', this.selected = false});
}
