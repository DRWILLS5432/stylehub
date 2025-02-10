import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpdateServiceWidget extends StatefulWidget {
  const UpdateServiceWidget({super.key});

  @override
  State<UpdateServiceWidget> createState() => _UpdateServiceWidgetState();
}

class _UpdateServiceWidgetState extends State<UpdateServiceWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _servicesController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  List<XFile> _pickedImageFiles = [];
  List<File> _imageFiles = [];

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    setState(() {
      _pickedImageFiles = pickedFiles;
      _imageFiles = pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
    });
  }

  Future<List<String>> _uploadImages(String userId) async {
    List<String> imageUrls = [];

    for (var imageFile in _imageFiles) {
      final String imageId = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageRef = _storage.ref().child('user-images/$userId/$imageId');
      await storageRef.putFile(imageFile);
      final String imageUrl = await storageRef.getDownloadURL();
      imageUrls.add(imageUrl);
    }

    return imageUrls;
  }

  Future<void> _uploadData() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to update services.')),
        );
        return;
      }

      try {
        // Upload images to Firebase Storage
        final List<String> imageUrls = await _uploadImages(user.uid);

        // Upload data to Firestore
        await _firestore.collection('services').add({
          'userId': user.uid,
          'services': _servicesController.text,
          'bio': _bioController.text,
          'phone': _phoneController.text,
          'images': imageUrls,
          'createdAt': Timestamp.now(),
        });

        print('Data uploaded to Firestore successfully.');

        // Clear form and image data
        _servicesController.clear();
        _bioController.clear();
        _phoneController.clear();
        setState(() {
          _imageFiles.clear();
          _pickedImageFiles.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Services updated successfully!')),
        );
      } catch (e, stackTrace) {
        print('Error: $e');
        print('Stack trace: $stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update services: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Services'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _servicesController,
                  decoration: const InputDecoration(
                    labelText: 'Services (comma separated)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter at least one service';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a bio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImages,
                  child: const Text('Upload Images'),
                ),
                const SizedBox(height: 20),
                _imageFiles.isNotEmpty
                    ? GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                        ),
                        itemCount: _imageFiles.length,
                        itemBuilder: (context, index) {
                          return Image.file(
                            _imageFiles[index],
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Container(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _uploadData,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
