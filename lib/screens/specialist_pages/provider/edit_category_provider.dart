import 'package:flutter/material.dart';
import 'package:stylehub/screens/specialist_pages/model/categories_model.dart';
import 'package:stylehub/storage/category_service.dart';

class EditCategoryProvider extends ChangeNotifier {
  // final List<String> _selectedCategories = [];
  List<Service> _services = [Service()];
  List<Service> _submittedServices = [];
  List<String> _submittedCategories = [];

  // Getters
  // List<String> get selectedCategories => _selectedCategories;
  List<Service> get services => _services;
  List<Service> get submittedServices => _submittedServices;
  List<String> get submittedCategories => _submittedCategories;

  List<Category> _availableCategories = [];
  final List<String> _selectedCategories = [];
  // ... keep existing service-related code ...

  List<Category> get availableCategories => _availableCategories;
  List<String> get selectedCategories => _selectedCategories;

  final FirebaseServices _firebaseService = FirebaseServices();

  // void toggleCategory(String category) {
  //   if (_selectedCategories.contains(category)) {
  //     _selectedCategories.remove(category);
  //   } else {
  //     _selectedCategories.add(category);
  //   }
  //   notifyListeners();
  // }

  void addService() {
    _services.add(Service());
    notifyListeners();
  }

  void updateService(int index, String name, String price) {
    _services[index] = Service(name: name, price: price);
    notifyListeners();
  }

  void submitForm() {
    // Validate and save services
    _submittedServices = List.from(_services.where((s) => s.name.isNotEmpty && s.price.isNotEmpty));
    _submittedCategories = List.from(_selectedCategories);

    // Reset form fields
    _services = [Service()];
    _selectedCategories.clear();
    notifyListeners();
  }

  void clearSelections() {
    submittedServices.clear();
    submittedCategories.clear();
    notifyListeners();
  }

  void clearAll() {
    _submittedServices.clear();
    _submittedCategories.clear();
    _services = [Service()];
    _selectedCategories.clear();
    notifyListeners();
  }

  void toggleSubmittedServiceSelection(int index) {
    if (index >= 0 && index < _submittedServices.length) {
      _submittedServices[index].selected = !_submittedServices[index].selected;
      notifyListeners();
    }
  }

  void loadCategories() {
    _firebaseService.getCategories().listen((categories) {
      _availableCategories = categories;
      print(_selectedCategories);
      notifyListeners();
    });
  }

  void toggleCategory(String categoryId) {
    if (_selectedCategories.contains(categoryId)) {
      _selectedCategories.remove(categoryId);
    } else {
      _selectedCategories.add(categoryId);
    }
    notifyListeners();
  }
}

class Service {
  String name;
  String price;
  bool selected;

  Service({this.name = '', this.price = '', this.selected = false});
}
