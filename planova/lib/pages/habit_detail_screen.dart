import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'habit_edit_page.dart'; // Yeni sayfayı içe aktarıyoruz

class HabitDetailPage extends StatefulWidget {
  final String habitId;

  const HabitDetailPage({super.key, required this.habitId});

  @override
  _HabitDetailPageState createState() => _HabitDetailPageState();
}

class _HabitDetailPageState extends State<HabitDetailPage> {
  static Map<String, dynamic>? habitData;
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
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('habits').doc(widget.habitId).get();
    setState(() {
      habitData = doc.data() as Map<String, dynamic>?;
      isLoading = false;
    });
  }

  void _updateCompletionStatus(bool? value, String date) {
    if (habitData == null) return;

    Map<String, dynamic> completedDates = habitData!['completed_days'] ?? {};
    completedDates[date] = value ?? false;

    FirebaseFirestore.instance.collection('habits').doc(widget.habitId).update({
      'completed_days': completedDates,
    }).then((_) {
      _loadHabitData();
    });
  }

  void _showEditBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9, // Tam ekran
          minChildSize: 0.9, // Tam ekran
          maxChildSize: 0.9, // Tam ekran
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
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
          title: const Text('Warning'),
          content: const Text('You cannot check this habit today.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
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
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Loading...'),
          backgroundColor: const Color(0xFF1E1E1E),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0XFF03DAC6)),
        ),
      );
    }

    if (habitData == null) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Habit Details'),
          backgroundColor: const Color(0xFF1E1E1E),
        ),
        body: const Center(
          child: Text('Habit not found', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    DateTime today = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(today);
    Map<String, dynamic> completedDates = habitData!['completed_days'] ?? {};
    int targetDays = habitData!['target_days'] ?? 0;
    bool isCompleted = completedDates[formattedDate] ?? false;
    bool isTodayHabitDay = habitData!['days'][formattedDate] ?? false;

    return ChangeNotifierProvider(
      create: (_) => HabitProvider(habitData: habitData),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            habitData!['name'] ?? 'Habit Details',
            style: const TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1),
              fontFamily: 'Roboto',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: const Color(0xFF1E1E1E),
        ),
        body: Container(
          color: const Color(0xFF1E1E1E),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800], // Button background color
                            foregroundColor: Colors.white, // Text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            minimumSize: const Size(160, 42), // Button size
                          ),
                          onPressed: () {
                            _showEditBottomSheet(context);
                          },
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.notifications),
                          label: const Text('Reminder'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800], // Button background color
                            foregroundColor: Colors.white, // Text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            minimumSize: const Size(160, 42), // Button size
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReminderPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  const AllTimeStats(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Checkbox(
                        value: isCompleted,
                        onChanged: isTodayHabitDay
                            ? (bool? value) {
                                _updateCompletionStatus(value, formattedDate);
                              }
                            : (bool? value) {
                                _showAlertDialog(context);
                              },
                        checkColor: Colors.white,
                        activeColor: const Color(0XFF03DAC6),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TwoWeekProgress(habitId: widget.habitId, targetDays: targetDays, completedDates: completedDates),
                  const SizedBox(height: 16),
                  MonthlyStats(habitId: widget.habitId, completedDates: completedDates),
                  const SizedBox(height: 16),
                  const YearProgress(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TwoWeekProgress extends StatelessWidget {
  final String habitId;
  final int targetDays;
  final Map<String, dynamic> completedDates;

  const TwoWeekProgress({
    super.key,
    required this.habitId,
    required this.targetDays,
    required this.completedDates,
  });

  Future<List<bool>> _fetchTwoWeekProgress() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('habits').doc(habitId).get();
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, dynamic> completedDays = data['completed_days'] ?? {};
    DateTime today = DateTime.now();

    List<bool> twoWeekProgress = [];
    int daysToFetch = targetDays < 14 ? targetDays : 14;
    for (int i = 0; i < daysToFetch; i++) {
      String day = DateFormat('yyyy-MM-dd').format(today.subtract(Duration(days: i)));
      twoWeekProgress.add(completedDays[day] ?? false);
    }

    return twoWeekProgress;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<bool>>(
      future: _fetchTwoWeekProgress(),
      builder: (BuildContext context, AsyncSnapshot<List<bool>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0XFF03DAC6)),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Error loading progress', style: TextStyle(color: Colors.white)),
          );
        }
        List<bool> twoWeekProgress = snapshot.data ?? [];
        int daysToShow = targetDays < 14 ? targetDays : 14;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6.0),
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(96, 125, 139, 0.25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto Flex',
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
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: twoWeekProgress
                          .asMap()
                          .map((index, value) => MapEntry(
                              index,
                              Container(
                                width: 20,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: value
                                      ? const Color.fromRGBO(3, 218, 198, 1)
                                      : const Color.fromRGBO(3, 218, 198, 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              )))
                          .values
                          .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Last $daysToShow days: ${twoWeekProgress.where((day) => day).length}/$daysToShow days',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto Flex',
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    '${(twoWeekProgress.where((day) => day).length / daysToShow * 100).toStringAsFixed(2)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto Flex',
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

class HabitProvider with ChangeNotifier {
  final Map<String, dynamic>? habitData;

  HabitProvider({required this.habitData});

  DateTime startDate = DateTime.now();
  List<bool> twoWeekProgress = List<bool>.filled(14, false);
  List<Map<int, bool>> monthlyStats = List.generate(
    12,
    (index) => { for (var item in List.generate(31, (i) => i + 1)) item : false },
  );
  List<bool> yearProgress = List<bool>.filled(365, false);

  bool ticked = false;
  bool isFavorite = false;

  void updateHabitStatus() {
    DateTime today = DateTime.now();
    int dayOfYear = int.parse(DateFormat("D").format(today));

    // Toggle the current day's status
    yearProgress[dayOfYear - 1] = !yearProgress[dayOfYear - 1];

    // Update twoWeekProgress
    if (yearProgress[dayOfYear - 1]) {
      twoWeekProgress = [true, ...twoWeekProgress.sublist(0, 13)];
    } else {
      int lastIndex = twoWeekProgress.lastIndexOf(true);
      twoWeekProgress[lastIndex] = false;
      twoWeekProgress = [false, ...twoWeekProgress.sublist(0, 13)];
    }

    // Update monthlyStats
    monthlyStats[today.month - 1][today.day] = yearProgress[dayOfYear - 1];

    // Update ticked status
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
    DateTime startDate = (habitData!['start_date'] as Timestamp).toDate();
    DateTime endDate = DateTime.now();
    Map<String, dynamic> completedDays = habitData!['completed_days'];

    for (DateTime date = startDate;
        date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
        date = date.add(const Duration(days: 1))) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      yearProgress.add(completedDays[formattedDate] ?? false);
    }

    return yearProgress;
  }

  List<bool> _getYearProgress() {
    List<bool> yearProgress = [];
    DateTime startDate = (habitData!['start_date'] as Timestamp).toDate();
    DateTime endDate = (habitData!['end_date'] as Timestamp).toDate();
    Map<String, dynamic> completedDays = habitData!['completed_days'];

    for (DateTime date = startDate;
        date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
        date = date.add(const Duration(days: 1))) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      yearProgress.add(completedDays[formattedDate] ?? false);
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
    final habitProvider = Provider.of<HabitProvider>(context);
    //get habitData from main class
    final habitData = _HabitDetailPageState.habitData;
    Map<String, dynamic> completedDates = habitData!['completed_days'] ?? {};
    int targetDays = habitData['target_days'] ?? 0;

    int completedCount = completedDates.values.where((value) => value == true).length;
    double completionDouble = completedCount / targetDays * 100;
    int completion = completionDouble.isNaN ? 0 : completionDouble.toInt();

    return Card(
      color: const Color.fromRGBO(96, 125, 139, 0.25), // Update the card background color
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'All Time Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Update the text color
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Streak',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  '${habitProvider.currentStreak} days',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Longest Streak',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  '${habitProvider.longestStreak} days',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Completion',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  '$completion% ($completedCount days of $targetDays days)',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Start Date',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  DateFormat('d MMM yyyy').format(habitData['start_date'].toDate()),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'End Date',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  DateFormat('d MMM yyyy').format(habitData['end_date'].toDate()),
                  style: const TextStyle(color: Colors.white),
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

  const MonthlyStats({
    super.key,
    required this.habitId,
    required this.completedDates,
  });

  @override
  _MonthlyStatsState createState() => _MonthlyStatsState();
}

class _MonthlyStatsState extends State<MonthlyStats> {
  int year = DateTime.now().year;
  Map<String, bool> days = {};

  // Renk paleti
  final Color backgroundColor = const Color.fromARGB(40, 96, 125, 139);
  final Color primaryColor = const Color.fromARGB(255, 96, 125, 139);
  final Color secondaryColor = const Color.fromARGB(135, 96, 125, 139);
  final Color textColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadHabitData();
  }

  Future<void> _loadHabitData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('habits').doc(widget.habitId).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      setState(() {
        days = Map<String, bool>.from(data['days'] ?? {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<int>(
              value: year,
              dropdownColor: secondaryColor,
              icon: Icon(Icons.arrow_drop_down, color: textColor),
              style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
              underline: Container(
                height: 2,
                color: primaryColor,
              ),
              onChanged: (int? newValue) {
                setState(() {
                  year = newValue!;
                });
              },
              items: [DateTime.now().year - 1, DateTime.now().year, DateTime.now().year + 1]
                  .map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value Stats'),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
            return Card(
              color: secondaryColor.withOpacity(0.25),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      monthName(index),
                      style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 7,
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 3,
                        children: buildMonthGrid(year, index),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  List<Widget> buildMonthGrid(int year, int monthIndex) {
    List<Widget> dayWidgets = [];
    DateTime firstDayOfMonth = DateTime(year, monthIndex + 1, 1);
    int daysInMonth = DateTime(year, monthIndex + 2, 0).day;
    DateTime now = DateTime.now();

    // Add black containers for days before the first day of the month
    for (int i = 0; i < firstDayOfMonth.weekday % 7; i++) {
      dayWidgets.add(Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: backgroundColor,
        ),
      ));
    }

    // Add containers for each day of the month
    for (int i = 1; i <= daysInMonth; i++) {
      DateTime currentDate = DateTime(year, monthIndex + 1, i);
      String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
      bool isHabitDay = days[formattedDate] ?? false;
      bool isCompletedDay = widget.completedDates[formattedDate] ?? false;

      Color dayColor;
      if (isHabitDay) {
        if (currentDate.isAfter(now)) {
          dayColor = primaryColor; // Future habit day
        } else if (currentDate.isBefore(now)) {
          dayColor = isCompletedDay ? const Color.fromARGB(255, 3, 218, 198) : const Color.fromARGB(80, 3, 218, 198); // Completed or missed past habit day
        } else {
          dayColor = isCompletedDay ? const Color.fromARGB(255, 127, 76, 175) : primaryColor; // Today's habit day
        }
      } else {
        dayColor = secondaryColor; // Not a habit day
      }

      dayWidgets.add(Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: dayColor,
        ),
      ));
    }

    // Fill the remaining grid with black containers
    while (dayWidgets.length < 42) {
      dayWidgets.add(Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: backgroundColor,
        ),
      ));
    }

    return dayWidgets;
  }

  String monthName(int index) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[index];
  }
}

class YearProgress extends StatelessWidget {
  const YearProgress({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);

    return Card(
      color: const Color.fromRGBO(96, 125, 139, 0.25), // Update the card background color
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last 365 Day Graph Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Update the text color
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4, // Adjust the spacing between circles
              runSpacing: 4, // Adjust the spacing between rows
              children: List.generate(
                habitProvider.yearProgress.length,
                (index) => Container(
                  width: 14, // Increased width of each circle
                  height: 14, // Increased height of each circle
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: habitProvider.yearProgress[index]
                        ? const Color.fromRGBO(3, 218, 198, 1)
                        : const Color.fromRGBO(255, 255, 255, 0.4), // Update the colors
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Reminder'),
      ),
      body: const Center(
        child: Text('Reminder Page'),
      ),
    );
  }
}
