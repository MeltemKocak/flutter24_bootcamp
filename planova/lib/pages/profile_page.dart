import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planova/pages/today_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _incompleteTasks = 0;
  int _completedTasks = 0;
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
    getTaskCountsForToday();
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
      margin: const EdgeInsets.all(4),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 36),
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundColor: const Color.fromARGB(255, 3, 218, 198),
                  child: CircleAvatar(
                    radius: 78,
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
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
                  const SizedBox(height: 35),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: saveProfile,
              icon: const Icon(Icons.save,
                  color: Color.fromARGB(255, 30, 30, 30)),
              label: const Text(
                'Save Profile',
                style: TextStyle(color: Color.fromARGB(230, 30, 30, 30), fontSize: 20, fontWeight: FontWeight.bold),
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
            SizedBox(height: 60),
            Text(
              "Daily Task Overview",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 23 ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TaskCard(
                  title: 'Incomplete Task',
                  count: _incompleteTasks,
                ),
                TaskCard(
                  title: 'Completed Task' ,
                  count: _completedTasks,
                ),
              ],
            ),
            SizedBox(height: 40),
            Text(
              "Daily Task Statistics",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 23 ),
            ),
            SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(15.0),
                color: const Color.fromARGB(255, 42, 42, 42)
              ),
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: BarChart(
                  _getBarChartData(),
                ),
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

  Future<void> getTaskCountsForToday() async {
    DateTime today = DateTime.now();
    Map<String, int> counts = await TodayPage.getTaskCounts(today);

    setState(() {
      _incompleteTasks = counts['incomplete'] ?? 0;
      _completedTasks = counts['completed'] ?? 0;
    });
  }

  BarChartData _getBarChartData() {
    return BarChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: [
        BarChartGroupData(
          x: 0,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
              toY: _incompleteTasks.toDouble(),
              color: Color.fromARGB(70, 3, 218, 198),
              width: 20,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ),
        BarChartGroupData(
          x: 0,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
              toY: _completedTasks.toDouble(),
              color: Color.fromARGB(200, 3, 218, 198),
              width: 20,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ),
        BarChartGroupData(
          x: 1,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
              toY: _incompleteTasks.toDouble(),
              color: Color.fromARGB(70, 3, 218, 198),
              width: 20,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ),
        BarChartGroupData(
          x: 2,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
              toY: _completedTasks.toDouble(),
              color: Color.fromARGB(200, 3, 218, 198),
              width: 20,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ),
        BarChartGroupData(
          x: 3,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
              toY: _incompleteTasks.toDouble(),
              color: Color.fromARGB(70, 3, 218, 198),
              width: 20,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ),
      ],
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final int count;

  TaskCard({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 42, 42, 42),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.40,
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 3, 218, 198),
              ),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
