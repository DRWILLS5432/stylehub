import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stylehub/screens/specialist_pages/model/post_details_model.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadServiceDetails({
    required String userId,
    required String bio,
    required String phone,
    required String city,
    required List<Map<String, String>> services,
  }) async {
    String res = "Some error occurred";
    try {
      String postId = const Uuid().v1();

      PostServicesModel post = PostServicesModel(
        userId: userId,
        bio: bio,
        phone: phone,
        city: city,
        services: services,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('services').doc(postId).set(post.toJson());
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
