import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String ruName;
  final String name;

  Category({required this.id, required this.name, required this.ruName});

  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      ruName: data['ru-name'] ?? '',
    );
  }
}
