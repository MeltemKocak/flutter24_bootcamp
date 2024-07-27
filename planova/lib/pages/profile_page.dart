import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planova/pages/today_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:planova/utilities/theme.dart';

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
  List<Map<String, dynamic>> habits = [];

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _fetchUserProfile();
    getTaskCountsForToday();
    _fetchHabits();
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

  Future<void> _fetchHabits() async {
    if (user != null) {
      QuerySnapshot habitsSnapshot = await FirebaseFirestore.instance
          .collection('habits')
          .where('user_id', isEqualTo: user!.uid)
          .get();

      habits = habitsSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'],
          'start_date': data['start_date'],
          'end_date': data['end_date'],
          'completed_days': data['completed_days'] ?? {},
          'target_days': data['target_days'] ?? 0,
        };
      }).toList();

      setState(() {});
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
    String email = user?.email ?? 'Anonymous User';
    if (_image != null) {
      imageUrl = await _uploadImageToStorage(_image!);
    }

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'name': name,
      'bio': bio,
      'imageUrl': imageUrl,
      'userId': user!.uid,
      'userEmail': email,
    });

    setState(() {
      _image = null; // Clear the image after uploading
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        CustomThemeData theme = ThemeColors.getTheme(themeProvider.themeValue);
        return Card(
          color: theme.cardBackground,
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
                      backgroundColor: theme.activeColor,
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
                        icon: Icon(
                          Icons.add_a_photo,
                          color: theme.activeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user?.email ?? 'Anonymous User',
                  style: TextStyle(
                    color: theme.dayNumTextColor,
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
                        style: TextStyle(color: theme.dayNumTextColor),
                        decoration: InputDecoration(
                          hintText: 'Enter Name',
                          hintStyle: TextStyle(
                              color: theme.dayNumTextColor.withOpacity(0.7)),
                          contentPadding: const EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: theme.checkBoxBorderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: theme.checkBoxBorderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.activeColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: bioController,
                        style: TextStyle(color: theme.dayNumTextColor),
                        decoration: InputDecoration(
                          hintText: 'Enter Bio',
                          hintStyle: TextStyle(
                              color: theme.dayNumTextColor.withOpacity(0.7)),
                          contentPadding: const EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: theme.checkBoxBorderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: theme.checkBoxBorderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.activeColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: saveProfile,
                  icon: Icon(Icons.save, color: theme.cardBackground),
                  label: Text(
                    'Save Profile',
                    style: TextStyle(
                        color: theme.cardBackground,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.activeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 60),
                Text(
                  "Daily Task Overview",
                  style: TextStyle(
                      color: theme.dayNumTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 23),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TaskCard(
                      title: 'Incomplete Task',
                      count: _incompleteTasks,
                    ),
                    TaskCard(
                      title: 'Completed Task',
                      count: _completedTasks,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  "Weekly Task Statistics",
                  style: TextStyle(
                      color: theme.dayNumTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 23),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: 200,
                  child: WeeklyStatsWidget(),
                ),
                const SizedBox(height: 40),
                Text(
                  "Habits Overview",
                  style: TextStyle(
                      color: theme.dayNumTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 23),
                ),
                Column(
                  children: habits
                      .map((habit) => HabitOverviewCard(habit: habit))
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
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
}

class TaskCard extends StatelessWidget {
  final String title;
  final int count;

  const TaskCard({super.key, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        CustomThemeData theme = ThemeColors.getTheme(themeProvider.themeValue);
        return Card(
          color: theme.todoCardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: SizedBox(
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
                    color: theme.activeColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.dayNumTextColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HabitOverviewCard extends StatelessWidget {
  final Map<String, dynamic> habit;

  const HabitOverviewCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    final int currentStreak = _calculateCurrentStreak;
    final int longestStreak = _calculateLongestStreak;
    final int targetDays = habit['target_days'];
    final int completedCount = habit['completed_days'].length;
    double completionDouble = completedCount / targetDays * 100;
    int completion = completionDouble.isNaN ? 0 : completionDouble.toInt();

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        CustomThemeData theme = ThemeColors.getTheme(themeProvider.themeValue);
        return Card(
          margin: const EdgeInsets.all(18),
          color: theme.todoCardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit['name'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.dayNumTextColor,
                  ),
                ),
                const SizedBox(height: 10),
                _buildStatRow('Current Streak', '$currentStreak days', theme),
                _buildStatRow('Longest Streak', '$longestStreak days', theme),
                _buildStatRow(
                    'Completion',
                    '$completion% ($completedCount days of $targetDays days)',
                    theme),
                _buildStatRow(
                    'Start Date', _formatDate(habit['start_date']), theme),
                _buildStatRow(
                    'End Date', _formatDate(habit['end_date']), theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, CustomThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: theme.dayNumTextColor.withOpacity(0.7)),
          ),
          Text(
            value,
            style: TextStyle(color: theme.dayNumTextColor),
          ),
        ],
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('MMM d, yyyy').format(date);
  }

  int get _calculateCurrentStreak {
    List<bool> yearProgress = _getStreakProgress();
    int streak = 0;
    for (int i = yearProgress.length - 1; i >= 0; i--) {
      if (yearProgress[i]) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int get _calculateLongestStreak {
    List<bool> yearProgress = _getYearProgress();
    int streak = 0;
    int longest = 0;
    for (int i = 0; i < yearProgress.length; i++) {
      if (yearProgress[i]) {
        streak++;
        if (streak > longest) {
          longest = streak;
        }
      } else {
        streak = 0;
      }
    }
    return longest;
  }

  List<bool> _getStreakProgress() {
    List<bool> yearProgress = [];
    DateTime startDate = (habit['start_date'] as Timestamp).toDate();
    DateTime endDate = DateTime.now();
    Map<String, dynamic> completedDays =
        (habit['completed_days'] ?? {}).cast<String, dynamic>();

    for (DateTime date = startDate;
        date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
        date = date.add(const Duration(days: 1))) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      Map<String, dynamic> userCompletedDays =
          (completedDays[FirebaseAuth.instance.currentUser!.uid] ?? {})
              .cast<String, dynamic>();
      yearProgress.add(userCompletedDays[formattedDate] ?? false);
    }

    return yearProgress;
  }

  List<bool> _getYearProgress() {
    List<bool> yearProgress = [];
    DateTime startDate = (habit['start_date'] as Timestamp).toDate();
    DateTime endDate = (habit['end_date'] as Timestamp).toDate();
    Map<String, dynamic> completedDays =
        (habit['completed_days'] ?? {}).cast<String, dynamic>();

    for (DateTime date = startDate;
        date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
        date = date.add(const Duration(days: 1))) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      Map<String, dynamic> userCompletedDays =
          (completedDays[FirebaseAuth.instance.currentUser!.uid] ?? {})
              .cast<String, dynamic>();
      yearProgress.add(userCompletedDays[formattedDate] ?? false);
    }

    return yearProgress;
  }
}

class WeeklyStatsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        CustomThemeData theme = ThemeColors.getTheme(themeProvider.themeValue);

        return FutureBuilder<Map<String, Map<String, int>>>(
          future: getWeeklyTaskCounts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              Map<String, Map<String, int>>? taskCounts = snapshot.data;

              // Max değeri belirle
              int maxY = 0;
              if (taskCounts != null) {
                for (var counts in taskCounts.values) {
                  if (counts['total']! > maxY) {
                    maxY = counts['total']!;
                  }
                }
              }

              return Container(
                decoration: BoxDecoration(
                  color: theme.todoCardBackground,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        ' ',
                        style: TextStyle(
                          color: theme.dayNumTextColor,
                          fontSize:1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: BarChart(BarChartData(
                        alignment: BarChartAlignment.spaceEvenly,
                        maxY: maxY.toDouble(),
                        titlesData: FlTitlesData(
                          rightTitles: AxisTitles(),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false), // Sol tarafı kaldır
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                switch (value.toInt()) {
                                  case 0:
                                    return Text('Mon', style: TextStyle(color: theme.dayNumTextColor, fontSize: 12));
                                  case 1:
                                    return Text('Tue', style: TextStyle(color: theme.dayNumTextColor, fontSize: 12));
                                  case 2:
                                    return Text('Wed', style: TextStyle(color: theme.dayNumTextColor, fontSize: 12));
                                  case 3:
                                    return Text('Thu', style: TextStyle(color: theme.dayNumTextColor, fontSize: 12));
                                  case 4:
                                    return Text('Fri', style: TextStyle(color: theme.dayNumTextColor, fontSize: 12));
                                  case 5:
                                    return Text('Sat', style: TextStyle(color: theme.dayNumTextColor, fontSize: 12));
                                  case 6:
                                    return Text('Sun', style: TextStyle(color: theme.dayNumTextColor, fontSize: 12));
                                  default:
                                    return Text('');
                                }
                              },
                            ),
                          ),
                        ),
                        gridData: FlGridData(show: false), // Kesikli çizgileri kaldırır
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          for (int i = 0; i < 7; i++)
                            BarChartGroupData(x: i, barRods: [
                              BarChartRodData(
                                toY: taskCounts != null ? taskCounts[weekDays[i]]!['total']!.toDouble() : 0,
                                color: theme.weeklyStatsBackgroundColor,
                                width: 22,
                                rodStackItems: [
                                  BarChartRodStackItem(
                                    0,
                                    taskCounts != null ? taskCounts[weekDays[i]]!['completed']!.toDouble() : 0,
                                    theme.activeColor,
                                  ),
                                ],
                              ),
                            ]),
                        ],
                      )),
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }

  Future<Map<String, Map<String, int>>> getWeeklyTaskCounts() async {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    Map<String, Map<String, int>> taskCounts = {};
    for (int i = 0; i < 7; i++) {
      DateTime day = startOfWeek.add(Duration(days: i));
      Map<String, int> counts = await TodayPage.getTaskCounts(day);
      taskCounts[weekDays[i]] = {
        'total': counts['incomplete']! + counts['completed']!,
        'completed': counts['completed']!,
      };
    }
    return taskCounts;
  }

  static const List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
}
