import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planova/pages/today_page.dart';
import 'package:intl/intl.dart';
import 'package:planova/pages/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:planova/utilities/theme.dart';
import 'package:planova/pages/user_stories_page.dart';

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
  List<Map<String, dynamic>> habits = [];
  bool storyExists = false;
  String story = "";

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _fetchUserProfile();
    getTaskCountsForToday();
    _fetchHabits();
    _checkStory();
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
          .where('isPending', isEqualTo: false)
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

  Future<void> _checkStory() async {
    if (user != null) {
      DateTime today = DateTime.now();
      String todayStr = DateFormat('yyyy-MM-dd').format(today);
      QuerySnapshot storySnapshot = await FirebaseFirestore.instance
          .collection('stories')
          .where('user_id', isEqualTo: user!.uid)
          .where('date', isEqualTo: todayStr)
          .get();
      if (storySnapshot.docs.isNotEmpty) {
        story = storySnapshot.docs.first['story'];
      }
      setState(() {
        storyExists = storySnapshot.docs.isNotEmpty;
      });
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
    String email = user?.email ?? tr('Anonymous User');
    if (_image != null) {
      imageUrl = await _uploadImageToStorage(_image!);
    }

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'name': name,
      'imageUrl': imageUrl,
      'userId': user!.uid,
      'userEmail': email,
    });

    setState(() {
      _image = null; // Clear the image after uploading
    });
  }

  Future<void> _refreshProfile() async {
    await _fetchUserProfile();
    await getTaskCountsForToday();
    await _fetchHabits();
    await _checkStory();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        CustomThemeData theme = ThemeColors.getTheme(themeProvider.themeValue);
        return Scaffold(
          backgroundColor: theme.background,
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: theme.checkBoxActiveColor,
                          child: CircleAvatar(
                            radius: 58,
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
                              color: theme.checkBoxActiveColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: nameController,
                            style: GoogleFonts.didactGothic(
                                color: theme.calenderNumbers),
                            decoration: InputDecoration(
                              hintText: tr('Enter Name'),
                              hintStyle: GoogleFonts.didactGothic(
                                  color:
                                      theme.calenderNumbers.withOpacity(0.7)),
                              contentPadding: const EdgeInsets.all(10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: theme.checkBoxBorderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: theme.checkBoxBorderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: theme.checkBoxActiveColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton.icon(
                            onPressed: saveProfile,
                            icon: Icon(Icons.save,
                                color: theme.toDoCardBackground),
                            label: Text(
                              tr('Save Profile'),
                              style: GoogleFonts.didactGothic(
                                  color: theme.toDoCardBackground,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.checkBoxActiveColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  tr("Today's Story"),
                  style: GoogleFonts.didactGothic(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: theme.calenderNumbers,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                storyExists
                    ? GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserStoriesPage()),
                          );
                          _refreshProfile();
                        },
                        child: StoryWidget(story: story),
                      )
                    : GestureDetector(
                        onTap: () async {
                          if (user != null && user!.isAnonymous) {
                            _showAnonymousAlertDialog(context);
                            return;
                          }
                          bool userExists =
                              await _isUserInCollection(user!.uid);
                          if (!userExists) {
                            _showProfileAlertDialog(context);
                            return;
                          }
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserStoriesPage()),
                          );
                          _refreshProfile();
                        },
                        child: StoryWidget(
                          story: tr("Create your story for today"),
                        ),
                      ),
                const SizedBox(height: 30),
                Text(
                  tr("Daily Task Overview"),
                  style: GoogleFonts.didactGothic(
                      color: theme.calenderNumbers,
                      fontWeight: FontWeight.bold,
                      fontSize: 23),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TaskCard(
                      title: tr('Incomplete Task'),
                      count: _incompleteTasks,
                    ),
                    TaskCard(
                      title: tr('Completed Task'),
                      count: _completedTasks,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  tr("Daily Task Statistics"),
                  style: GoogleFonts.didactGothic(
                      color: theme.calenderNumbers,
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
                  style: GoogleFonts.didactGothic(
                      color: theme.calenderNumbers,
                      fontWeight: FontWeight.bold,
                      fontSize: 23),
                ).tr(),
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

  void _showAnonymousAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Provider.of<ThemeProvider>(context).currentTheme;
        return AlertDialog(
          backgroundColor: theme.background,
          title: Text(
            tr('Warning'),
            style: GoogleFonts.didactGothic(color: theme.welcomeText),
          ),
          content: Text(
            tr('You cannot use this section while logged in as a guest. Please create an account.'),
            style: GoogleFonts.didactGothic(color: theme.welcomeText),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                tr('Cancel'),
                style: GoogleFonts.didactGothic(
                    color: Colors.red, fontWeight: FontWeight.w200),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const WelcomeScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text(
                tr('Confirm'),
                style: GoogleFonts.didactGothic(
                    color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showProfileAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Provider.of<ThemeProvider>(context).currentTheme;
        return AlertDialog(
          backgroundColor: theme.background,
          title: Text(
            tr('Warning'),
            style: GoogleFonts.didactGothic(color: theme.welcomeText),
          ),
          content: Text(
            tr('You need to create a profile to continue this action.'),
            style: GoogleFonts.didactGothic(color: theme.welcomeText),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                tr('Cancel'),
                style: GoogleFonts.didactGothic(
                    color: Colors.red, fontWeight: FontWeight.w200),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                tr('Confirm'),
                style: GoogleFonts.didactGothic(
                    color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _isUserInCollection(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.exists;
  }

  Future<Uint8List> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      return await pickedFile.readAsBytes();
    } else {
      throw Exception(tr('No image selected'));
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

class StoryWidget extends StatelessWidget {
  final String story;
  static const int maxLength = 200; // Güncellenen uzunluk

  const StoryWidget({required this.story});

  @override
  Widget build(BuildContext context) {
    String displayedStory = story.length > maxLength
        ? story.substring(0, maxLength) + '...'
        : story;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        CustomThemeData theme = ThemeColors.getTheme(themeProvider.themeValue);
        return Card(
          color: theme.toDoCardBackground,
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                displayedStory,
                style: GoogleFonts.didactGothic(
                  color: theme.addButton,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
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
          color: theme.toDoCardBackground,
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
                  style: GoogleFonts.didactGothic(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: theme.checkBoxActiveColor,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    title,
                    textAlign: TextAlign
                        .center, // Text widget'ının içinde yazıyı ortalar
                    style: GoogleFonts.didactGothic(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.calenderNumbers,
                    ),
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
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final int currentStreak = _calculateCurrentStreak;
    final int longestStreak = _calculateLongestStreak;
    final int targetDays = habit['target_days'];
    final int completedCount = habit['completed_days'] != null &&
            habit['completed_days'][userId] != null
        ? habit['completed_days'][userId]
            .values
            .where((value) => value == true)
            .length
        : 0;

    double completionDouble = completedCount / targetDays * 100;
    int completion = completionDouble.isNaN ? 0 : completionDouble.toInt();

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        CustomThemeData theme = ThemeColors.getTheme(themeProvider.themeValue);
        return Card(
          margin: const EdgeInsets.all(18),
          color: theme.toDoCardBackground,
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
                  style: GoogleFonts.didactGothic(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.calenderNumbers,
                  ),
                ),
                const SizedBox(height: 10),
                _buildStatRow(tr('Current Streak'),
                    "$currentStreak " + tr("days"), theme),
                _buildStatRow(tr('Longest Streak'),
                    "$longestStreak " + tr("days"), theme),
                _buildStatRow(tr('Completion'),
                    '$completion% ($completedCount / $targetDays)', theme),
                _buildStatRow(
                    tr('Start Date'), _formatDate(habit['start_date']), theme),
                _buildStatRow(
                    tr('End Date'), _formatDate(habit['end_date']), theme),
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
            style: GoogleFonts.didactGothic(
                color: theme.calenderNumbers.withOpacity(0.7)),
          ),
          Text(
            value,
            style: GoogleFonts.didactGothic(color: theme.calenderNumbers),
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
              return Text("Error" + ":" + " ${snapshot.error}");
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
                  color: theme.toDoCardBackground,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        ' ',
                        style: GoogleFonts.didactGothic(
                          color: theme.calenderNumbers,
                          fontSize: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: BarChart(BarChartData(
                        alignment: BarChartAlignment.spaceEvenly,
                        maxY: maxY.toDouble(),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: false), // Sol tarafı kaldır
                          ),
                          topTitles: const AxisTitles(
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
                                    return Text(tr('Mon'),
                                        style: GoogleFonts.didactGothic(
                                            color: theme.calenderNumbers,
                                            fontSize: 12));
                                  case 1:
                                    return Text(tr('Tue'),
                                        style: GoogleFonts.didactGothic(
                                            color: theme.calenderNumbers,
                                            fontSize: 12));
                                  case 2:
                                    return Text(tr('Wed'),
                                        style: GoogleFonts.didactGothic(
                                            color: theme.calenderNumbers,
                                            fontSize: 12));
                                  case 3:
                                    return Text(tr('Thu'),
                                        style: GoogleFonts.didactGothic(
                                            color: theme.calenderNumbers,
                                            fontSize: 12));
                                  case 4:
                                    return Text(tr('Fri'),
                                        style: GoogleFonts.didactGothic(
                                            color: theme.calenderNumbers,
                                            fontSize: 12));
                                  case 5:
                                    return Text(tr('Sat'),
                                        style: GoogleFonts.didactGothic(
                                            color: theme.calenderNumbers,
                                            fontSize: 12));
                                  case 6:
                                    return Text(tr('Sun'),
                                        style: GoogleFonts.didactGothic(
                                            color: theme.calenderNumbers,
                                            fontSize: 12));
                                  default:
                                    return const Text('');
                                }
                              },
                            ),
                          ),
                        ),
                        gridData: const FlGridData(
                            show: false), // Kesikli çizgileri kaldırır
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          for (int i = 0; i < 7; i++)
                            BarChartGroupData(x: i, barRods: [
                              BarChartRodData(
                                toY: taskCounts != null
                                    ? taskCounts[weekDays[i]]!['total']!
                                        .toDouble()
                                    : 0,
                                color: theme.weeklyStatsBackgroundColor,
                                width: 22,
                                rodStackItems: [
                                  BarChartRodStackItem(
                                    0,
                                    taskCounts != null
                                        ? taskCounts[weekDays[i]]!['completed']!
                                            .toDouble()
                                        : 0,
                                    theme.checkBoxActiveColor,
                                  ),
                                  BarChartRodStackItem(
                                    taskCounts != null
                                        ? taskCounts[weekDays[i]]!['completed']!
                                            .toDouble()
                                        : 0,
                                    taskCounts != null
                                        ? taskCounts[weekDays[i]]!['total']!
                                            .toDouble()
                                        : 0,
                                    theme.habitDetailEditBackground,
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

  static List<String> weekDays = [
    tr('Mon'),
    tr('Tue'),
    tr('Wed'),
    tr('Thu'),
    tr('Fri'),
    tr('Sat'),
    tr('Sun')
  ];
}
