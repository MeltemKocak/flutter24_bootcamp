import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  Uint8List? _image;
  String? imageUrl;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _fetchUserProfile();
  }

  Future<void> _fetchUser() async {
    user = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  Future<void> _fetchUserProfile() async {
    if (user != null) {
      DocumentSnapshot userProfile = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      if (userProfile.exists) {
        var data = userProfile.data() as Map<String, dynamic>;
        nameController.text = data['name'];
        bioController.text = data['bio'];
        imageUrl = data['imageUrl'];
        setState(() {});
      }
    }
  }

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  Future<String> _uploadImageToStorage(Uint8List image) async {
    Reference ref =
        FirebaseStorage.instance.ref().child('profilePics').child(user!.uid);
    UploadTask uploadTask = ref.putData(image);
    TaskSnapshot snap = await uploadTask;
    return await snap.ref.getDownloadURL();
  }

  void saveProfile() async {
    String name = nameController.text;
    String bio = bioController.text;
    if (_image != null) {
      imageUrl = await _uploadImageToStorage(_image!);
    }

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'name': name,
      'bio': bio,
      'imageUrl': imageUrl,
      'userId': user!.uid,
    });

    setState(() {
      _image = null; // Clear the image after uploading
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 30, 30, 30),
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 66,
                  backgroundColor: const Color.fromARGB(255, 3, 218, 198),
                  child: CircleAvatar(
                    radius: 64,
                    backgroundImage: _image != null
                        ? MemoryImage(_image!)
                        : (imageUrl != null
                                ? NetworkImage(imageUrl!)
                                : const AssetImage(
                                    'assets/images/default_profile.png'))
                            as ImageProvider,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    onPressed: selectImage,
                    icon: const Icon(
                      Icons.add_a_photo,
                      color: Color.fromARGB(255, 3, 218, 198),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              user?.email ?? 'Anonymous User',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter Name',
                hintStyle: const TextStyle(color: Colors.white70),
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color.fromARGB(200, 3, 218, 198)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color.fromARGB(200, 3, 218, 198)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color.fromARGB(255, 3, 218, 198)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bioController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter Bio',
                hintStyle: const TextStyle(color: Colors.white70),
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color.fromARGB(200, 3, 218, 198)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color.fromARGB(200, 3, 218, 198)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color.fromARGB(255, 3, 218, 198)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: saveProfile,
              icon: const Icon(Icons.save,
                  color: Color.fromARGB(255, 30, 30, 30)),
              label: const Text(
                'Save Profile',
                style: TextStyle(color: Color.fromARGB(200, 30, 30, 30)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 3, 218, 198),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      return await pickedFile.readAsBytes();
    } else {
      throw Exception('No image selected');
    }
  }
}
