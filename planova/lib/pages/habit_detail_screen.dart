import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planova/utilities/theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'habit_edit_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class HabitDetailPage extends StatefulWidget {
  final String habitId;

  const HabitDetailPage({super.key, required this.habitId});

  @override
  _HabitDetailPageState createState() => _HabitDetailPageState();
}

class _HabitDetailPageState extends State<HabitDetailPage> {
  Map<String, dynamic>? habitData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabitData();
  }

  Future<void> _loadHabitData() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('habits')
        .doc(widget.habitId)
        .get();
    setState(() {
      habitData = doc.data() as Map<String, dynamic>?;
      isLoading = false;
      if (habitData != null) {
        print('Habit data loaded: $habitData');
      } else {
        print('No habit data found.');
      }
    });
  }

  Future<void> _updateCompletionStatus(bool? value, String date) async {
    if (habitData == null) return;

    String userId = FirebaseAuth.instance.currentUser!.uid;
    Map<String, dynamic> completedDays =
        (habitData!['completed_days'] ?? {}).cast<String, dynamic>();

    if (!completedDays.containsKey(userId)) {
      completedDays[userId] = {};
    }

    completedDays[userId][date] = value ?? false;

    await FirebaseFirestore.instance
        .collection('habits')
        .doc(widget.habitId)
        .update({
      'completed_days': completedDays,
    });

    List<dynamic> friends = habitData!['friends'] ?? [];
    if (friends.isNotEmpty) {
      for (String friendId in friends.cast<String>()) {
        QuerySnapshot friendHabits = await FirebaseFirestore.instance
            .collection('habits')
            .where('user_id', isEqualTo: friendId)
            .where('name', isEqualTo: habitData!['name'])
            .get();

        for (var habit in friendHabits.docs) {
          Map<String, dynamic> friendCompletedDays =
              (habit['completed_days'] ?? {}).cast<String, dynamic>();

          if (!friendCompletedDays.containsKey(userId)) {
            friendCompletedDays[userId] = {};
          }

          friendCompletedDays[userId][date] = value ?? false;

          await FirebaseFirestore.instance
              .collection('habits')
              .doc(habit.id)
              .update({
            'completed_days': friendCompletedDays,
          });
        }
      }
    }

    setState(() {
      habitData!['completed_days'] = completedDays;
      print('Updated habit data: $habitData');
    });

    Provider.of<HabitProvider>(context, listen: false).setHabitData(habitData!);
  }

  void _showEditBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.9,
          maxChildSize: 0.9,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Provider.of<ThemeProvider>(context)
                    .currentTheme
                    .habitDetailEditBackground,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: HabitEditPage(habitId: widget.habitId),
            );
          },
        );
      },
    ).whenComplete(() => _loadHabitData());
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tr('Warning'), style: GoogleFonts.didactGothic()),
          content: Text(tr('You cannot check this habit today.'),
              style: GoogleFonts.didactGothic()),
          actions: <Widget>[
            TextButton(
              child: Text(tr('OK'), style: GoogleFonts.didactGothic()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(tr('Loading...'), style: GoogleFonts.didactGothic()),
          backgroundColor: theme.appBar,
        ),
        body: Center(
          child: CircularProgressIndicator(color: theme.checkBoxActiveColor),
        ),
      );
    }

    if (habitData == null) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(tr('Habit Details'), style: GoogleFonts.didactGothic()),
          backgroundColor: theme.appBar,
        ),
        body: Center(
          child: Text(tr('Habit not found'),
              style: GoogleFonts.didactGothic(color: theme.welcomeText)),
        ),
      );
    }

    DateTime today = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(today);
    String userId = FirebaseAuth.instance.currentUser!.uid;
    Map<String, dynamic> completedDays =
        (habitData!['completed_days'] ?? {}).cast<String, dynamic>();
    Map<String, dynamic> userCompletedDays =
        (completedDays[userId] ?? {}).cast<String, dynamic>();
    int targetDays = habitData!['target_days'] ?? 0;
    bool isCompleted = userCompletedDays[formattedDate] ?? false;
    bool isTodayHabitDay = habitData!['days'][formattedDate] ?? false;
    bool hasFriends = (habitData!['friends'] ?? []).isNotEmpty;

    return ChangeNotifierProvider(
      create: (_) => HabitProvider(habitData: habitData!),
      child: Consumer<HabitProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                provider.habitData['name'] ?? tr('Habit Details'),
                style: GoogleFonts.didactGothic(
                  color: theme.welcomeText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: theme.welcomeText),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              backgroundColor: theme.background,
              actions: [
                IconButton(
                  icon: Icon(Icons.edit,
                      color: theme
                          .welcomeText),
                  onPressed: () {
                    _showEditBottomSheet(context);
                  },
                ),
              ],
            ),
            body: Container(
              color: theme.background,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [],
                        ),
                      ),
                      const SizedBox(height: 15),
                      const AllTimeStats(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formattedDate,
                            style: GoogleFonts.didactGothic(
                              color: theme.subText,
                              fontSize: 14,
                            ),
                          ),
                          Checkbox(
                            value: isCompleted,
                            onChanged: isTodayHabitDay
                                ? (bool? value) {
                                    _updateCompletionStatus(
                                        value, formattedDate);
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                super.widget));
                                  }
                                : (bool? value) {
                                    _showAlertDialog(context);
                                  },
                            checkColor: theme.background,
                            activeColor: theme.checkBoxActiveColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      TwoWeekProgress(
                        habitId: widget.habitId,
                        targetDays: targetDays,
                        completedDays: completedDays,
                        hasFriends: hasFriends,
                      ),
                      const SizedBox(height: 16),
                      MonthlyStats(
                        habitId: widget.habitId,
                        completedDates:
                            provider.habitData['completed_days'] ?? {},
                        hasFriends: hasFriends,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TwoWeekProgress extends StatelessWidget {
  final String habitId;
  static String? firstFriend;
  final int targetDays;
  final Map<String, dynamic> completedDays;
  final bool hasFriends;

  const TwoWeekProgress({
    super.key,
    required this.habitId,
    required this.targetDays,
    required this.completedDays,
    required this.hasFriends,
  });

  Future<List<Map<String, bool>>> _fetchTwoWeekProgress() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('habits')
        .doc(habitId)
        .get();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, dynamic> completedDays =
        (data['completed_days'] ?? {}).cast<String, dynamic>();
    List<String> friends = List<String>.from(data['friends'] ?? []);
    firstFriend = friends.isNotEmpty ? friends.first : '';

    DateTime today = DateTime.now();

    List<Map<String, bool>> twoWeekProgress = [];
    int daysToFetch = targetDays < 14 ? targetDays : 14;
    for (int i = 0; i < daysToFetch; i++) {
      String day =
          DateFormat('yyyy-MM-dd').format(today.subtract(Duration(days: i)));
      Map<String, bool> dailyProgress = {};

      completedDays.forEach((userId, userCompletedDays) {
        dailyProgress[userId] =
            (userCompletedDays as Map<String, dynamic>)[day] ?? false;
      });

      twoWeekProgress.add(dailyProgress);
    }

    return twoWeekProgress;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return FutureBuilder<List<Map<String, bool>>>(
      future: _fetchTwoWeekProgress(),
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, bool>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: theme.checkBoxActiveColor),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(tr('Error loading progress'),
                style: GoogleFonts.didactGothic(color: theme.welcomeText)),
          );
        }
        List<Map<String, bool>> twoWeekProgress = snapshot.data ?? [];
        int daysToShow = targetDays < 14 ? targetDays : 14;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6.0),
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: theme.weeklyStatsBackgroundColor.withOpacity(1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('Progress'),
                    style: GoogleFonts.didactGothic(
                      color: theme.welcomeText,
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var value in twoWeekProgress)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 20,
                        height: 50,
                        child: CustomPaint(
                          painter: ProgressPainter(
                            value[FirebaseAuth.instance.currentUser!.uid] ??
                                false,
                            hasFriends ? (value[firstFriend] ?? false) : null,
                            context,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('Last $daysToShow days: ${twoWeekProgress.where((day) => day.values.contains(true)).length}/$daysToShow days'),
                    style: GoogleFonts.didactGothic(
                      color: theme.welcomeText,
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    '${(twoWeekProgress.where((day) => day.values.contains(true)).length / daysToShow * 100).toStringAsFixed(2)}%',
                    style: GoogleFonts.didactGothic(
                      color: theme.welcomeText,
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProgressPainter extends CustomPainter {
  final bool user1Completed;
  final bool? user2Completed;
  final BuildContext context;

  ProgressPainter(this.user1Completed, this.user2Completed, this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final theme =
        Provider.of<ThemeProvider>(context, listen: false).currentTheme;

    if (user2Completed == null) {
      paint.color = user1Completed
          ? theme.habitProgress
          : theme.habitProgress.withOpacity(0.2);
      canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);
    } else {
      if (user1Completed) {
        paint.color = theme.habitProgress;
        canvas.drawRect(
            Rect.fromLTRB(0, 0, size.width, size.height / 2), paint);
      } else {
        paint.color = theme.habitProgress.withOpacity(0.2);
        canvas.drawRect(
            Rect.fromLTRB(0, 0, size.width, size.height / 2), paint);
      }

      if (user2Completed != null && user2Completed!) {
        paint.color = theme.habitIcons;
        canvas.drawRect(
            Rect.fromLTRB(0, size.height / 2, size.width, size.height), paint);
      } else {
        paint.color = theme.habitProgress.withOpacity(0.1);
        canvas.drawRect(
            Rect.fromLTRB(0, size.height / 2, size.width, size.height), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class HabitProvider with ChangeNotifier {
  Map<String, dynamic> habitData;

  HabitProvider({required this.habitData});

  void setHabitData(Map<String, dynamic> newHabitData) {
    habitData = newHabitData;
    notifyListeners();
  }

  DateTime startDate = DateTime.now();
  List<bool> twoWeekProgress = List<bool>.filled(14, false);
  List<Map<int, bool>> monthlyStats = List.generate(
    12,
    (index) => {for (var item in List.generate(31, (i) => i + 1)) item: false},
  );
  List<bool> yearProgress = List<bool>.filled(365, false);

  bool ticked = false;
  bool isFavorite = false;

  void updateHabitStatus() {
    DateTime today = DateTime.now();
    int dayOfYear = int.parse(DateFormat("D").format(today));

    yearProgress[dayOfYear - 1] = !yearProgress[dayOfYear - 1];

    if (yearProgress[dayOfYear - 1]) {
      twoWeekProgress = [true, ...twoWeekProgress.sublist(0, 13)];
    } else {
      int lastIndex = twoWeekProgress.lastIndexOf(true);
      twoWeekProgress[lastIndex] = false;
      twoWeekProgress = [false, ...twoWeekProgress.sublist(0, 13)];
    }

    monthlyStats[today.month - 1][today.day] = yearProgress[dayOfYear - 1];

    ticked = yearProgress[dayOfYear - 1];
    notifyListeners();
  }

  void toggleProgress(int year, int month, int day) {
    DateTime today = DateTime.now();
    if (year == today.year && month == today.month - 1 && day == today.day) {
      monthlyStats[month][day] = !monthlyStats[month][day]!;
      notifyListeners();
    }
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }

  int get currentStreak {
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

  int get longestStreak {
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
    DateTime startDate = (habitData['start_date'] as Timestamp).toDate();
    DateTime endDate = DateTime.now();
    Map<String, dynamic> completedDays =
        (habitData['completed_days'] ?? {}).cast<String, dynamic>();

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
    DateTime startDate = (habitData['start_date'] as Timestamp).toDate();
    DateTime endDate = (habitData['end_date'] as Timestamp).toDate();
    Map<String, dynamic> completedDays =
        (habitData['completed_days'] ?? {}).cast<String, dynamic>();

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

  double get completion {
    int completedDays = yearProgress.where((day) => day).length;
    return (completedDays / 365) * 100;
  }

  double get twoWeekCompletion {
    int completedDays = twoWeekProgress.where((day) => day).length;
    return (completedDays / 14) * 100;
  }
}

class AllTimeStats extends StatelessWidget {
  const AllTimeStats({super.key});

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final habitProvider = Provider.of<HabitProvider>(context);
    final habitData = habitProvider.habitData;
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    Map<String, dynamic> completedDays =
        (habitData['completed_days'] ?? <String, dynamic>{})
            .cast<String, dynamic>();
    int targetDays = habitData['target_days'] ?? 0;

    final int completedCount = habitData['completed_days'] != null &&
            habitData['completed_days'][userId] != null
        ? habitData['completed_days'][userId]
            .values
            .where((value) => value == true)
            .length
        : 0;
    double completionDouble =
        targetDays != 0 ? (completedCount / targetDays) * 100 : 0.0;
    int completion = completionDouble.isNaN ? 0 : completionDouble.toInt();

    return Card(
      color: theme.weeklyStatsBackgroundColor.withOpacity(1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('All Time Stats'),
              style: GoogleFonts.didactGothic(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.welcomeText,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr('Current Streak'),
                  style: GoogleFonts.didactGothic(color: theme.subText),
                ),
                Text(
                  '${habitProvider.currentStreak} ${tr("days")}',
                  style: GoogleFonts.didactGothic(color: theme.welcomeText),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr('Longest Streak'),
                  style: GoogleFonts.didactGothic(color: theme.subText),
                ),
                Text(
                  '${habitProvider.longestStreak} ${tr("days")}',
                  style: GoogleFonts.didactGothic(color: theme.welcomeText),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr('Completion'),
                  style: GoogleFonts.didactGothic(color: theme.subText),
                ),
                Text(
                  '$completion% ($completedCount days of $targetDays days)',
                  style: GoogleFonts.didactGothic(color: theme.welcomeText),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr('Start Date'),
                  style: GoogleFonts.didactGothic(color: theme.subText),
                ),
                Text(
                  DateFormat('d MMM yyyy')
                      .format(habitData['start_date'].toDate()),
                  style: GoogleFonts.didactGothic(color: theme.welcomeText),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr('End Date'),
                  style: GoogleFonts.didactGothic(color: theme.subText),
                ),
                Text(
                  DateFormat('d MMM yyyy')
                      .format(habitData['end_date'].toDate()),
                  style: GoogleFonts.didactGothic(color: theme.welcomeText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MonthlyStats extends StatefulWidget {
  final String habitId;
  final Map<String, dynamic> completedDates;
  final bool hasFriends;

  const MonthlyStats({
    super.key,
    required this.habitId,
    required this.completedDates,
    required this.hasFriends,
  });

  @override
  _MonthlyStatsState createState() => _MonthlyStatsState();
}

class _MonthlyStatsState extends State<MonthlyStats> {
  int year = DateTime.now().year;
  Map<String, bool> days = {};
  late Future<void> _dataFuture;

  String? firstFriendId;

  @override
  void initState() {
    super.initState();
    _loadHabitData();
    _dataFuture = _loadHabitData();
  }

  Future<void> _loadHabitData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('habits')
        .doc(widget.habitId)
        .get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<String> friends = List<String>.from(data['friends'] ?? []);
      setState(() {
        days = Map<String, bool>.from(data['days'] ?? {});
        firstFriendId = friends.isNotEmpty ? friends.first : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return FutureBuilder(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child:
                  CircularProgressIndicator(color: theme.checkBoxActiveColor));
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: GoogleFonts.didactGothic(color: theme.welcomeText)));
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<int>(
                    value: year,
                    dropdownColor:
                        theme.weeklyStatsBackgroundColor.withOpacity(1),
                    icon: Icon(Icons.arrow_drop_down, color: theme.welcomeText),
                    style: GoogleFonts.didactGothic(
                        color: theme.welcomeText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    underline: Container(
                      height: 2,
                      color: theme.weeklyStatsBackgroundColor,
                    ),
                    onChanged: (int? newValue) {
                      setState(() {
                        year = newValue!;
                      });
                    },
                    items: [DateTime.now().year, DateTime.now().year + 1]
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value ${tr("Stats")}',
                            style: GoogleFonts.didactGothic()),
                      );
                    }).toList(),
                  ),
                ],
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  return FutureBuilder<List<Widget>>(
                    future: buildMonthGrid(year, index, context),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child: CircularProgressIndicator(
                                color: theme.checkBoxActiveColor));
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text('Error: ${snapshot.error}',
                                style: GoogleFonts.didactGothic(
                                    color: theme.welcomeText)));
                      } else {
                        return Card(
                          color:
                              theme.weeklyStatsBackgroundColor.withOpacity(1),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  monthName(index).tr(),
                                  style: GoogleFonts.didactGothic(
                                      fontWeight: FontWeight.bold,
                                      color: theme.welcomeText),
                                ),
                                const SizedBox(height: 4),
                                Expanded(
                                  child: GridView.count(
                                    crossAxisCount: 7,
                                    crossAxisSpacing: 3,
                                    mainAxisSpacing: 3,
                                    children: snapshot.data!,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          );
        }
      },
    );
  }

  Future<List<Widget>> buildMonthGrid(
      int year, int monthIndex, BuildContext context) async {
    List<Widget> dayWidgets = [];
    DateTime firstDayOfMonth = DateTime(year, monthIndex + 1, 1);
    int daysInMonth = DateTime(year, monthIndex + 2, 0).day;
    DateTime now = DateTime.now();
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    for (int i = 0; i < firstDayOfMonth.weekday % 7; i++) {
      dayWidgets.add(Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: theme.monthlyInvalidDayGrid,
        ),
      ));
    }

    for (int i = 1; i <= daysInMonth; i++) {
      DateTime currentDate = DateTime(year, monthIndex + 1, i);
      String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
      bool isHabitDay = days[formattedDate] ?? false;

      bool userCompleted =
          (widget.completedDates[userId] ?? {})[formattedDate] ?? false;
      bool friendCompleted = widget.hasFriends && firstFriendId != null
          ? (widget.completedDates[firstFriendId] ?? {})[formattedDate] ?? false
          : false;

      dayWidgets.add(ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CustomPaint(
          size: const Size(14, 14),
          painter: DayPainter(
            isHabitDay: isHabitDay,
            userCompleted: userCompleted,
            friendCompleted: widget.hasFriends ? friendCompleted : null,
            isPastDate: currentDate.isBefore(now),
            isFutureDate: currentDate.isAfter(now),
            context: context,
          ),
        ),
      ));
    }

    while (dayWidgets.length < 42) {
      dayWidgets.add(Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: theme.monthlyInvalidDayGrid,
        ),
      ));
    }

    return dayWidgets;
  }

  String monthName(int index) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[index];
  }
}

class DayPainter extends CustomPainter {
  final bool isHabitDay;
  final bool userCompleted;
  final bool? friendCompleted;
  final bool isPastDate;
  final bool isFutureDate;
  final BuildContext context;

  DayPainter({
    required this.isHabitDay,
    required this.userCompleted,
    required this.friendCompleted,
    required this.isPastDate,
    required this.isFutureDate,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    final theme =
        Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    final double halfHeight = size.height / 2;

    if (isHabitDay) {
      if (friendCompleted == null) {
        paint.color = userCompleted
            ? theme.monthlyCompleteDayGrid
            : theme.monthlyActiveDayGrid;
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      } else {
        if (isFutureDate) {
          paint.color = theme.monthlyActiveDayGrid;
          canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
        } else if (isPastDate) {
          paint.color = userCompleted
              ? theme.monthlyCompleteDayGrid
              : theme.monthlyActiveDayGrid;
          canvas.drawRect(Rect.fromLTWH(0, 0, size.width, halfHeight), paint);

          paint.color = friendCompleted!
              ? theme
                  .monthlyFriendCompleteDayGrid
              : theme
                  .monthlyFriendUncompleteDayGrid;
          canvas.drawRect(
              Rect.fromLTWH(0, halfHeight, size.width, halfHeight), paint);
        } else {
          paint.color = userCompleted
              ? theme.monthlyCompleteDayGrid
              : theme.monthlyDefaultDayGrid;
          canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
        }
      }
    } else {
      paint.color =
          theme.monthlyDefaultDayGrid.withOpacity(0.5);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Future<Map<String, dynamic>> prepareData() async {
  await Future.delayed(Duration(seconds: 2));

  return {
    'isHabitDay': true,
    'userCompleted': true,
    'friendCompleted': true,
    'isPastDate': false,
    'isFutureDate': false,
  };
}

class MyPainterWidget extends StatefulWidget {
  @override
  _MyPainterWidgetState createState() => _MyPainterWidgetState();
}

class _MyPainterWidgetState extends State<MyPainterWidget> {
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    var result = await prepareData();
    setState(() {
      data = result;
    });
  }

  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class EditHabitPage extends StatelessWidget {
  const EditHabitPage({super.key, required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context) {
    return HabitEditPage(habitId: habitId);
  }
}

class ReminderPage extends StatelessWidget {
  const ReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Set Reminder'), style: GoogleFonts.didactGothic()),
        backgroundColor: theme.appBar,
      ),
      body: Center(
        child: Text(tr('Reminder Page'),
            style: GoogleFonts.didactGothic(color: theme.welcomeText)),
      ),
    );
  }
}
