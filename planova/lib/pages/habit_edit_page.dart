import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:planova/pages/home.dart';
import 'package:planova/utilities/theme.dart';
import 'package:provider/provider.dart'; // Provider eklendi
import 'habit_page.dart';

class HabitEditPage extends StatefulWidget {
  final String habitId;

  const HabitEditPage({super.key, required this.habitId});

  @override
  _HabitEditPageState createState() => _HabitEditPageState();
}

class _HabitEditPageState extends State<HabitEditPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _friendEmailController = TextEditingController();
  final List<bool> _selectedDays = List.generate(7, (_) => true);
  int _targetDays = 0;
  bool isLoading = true;
  bool _isNameEmpty = false;

  @override
  void initState() {
    super.initState();
    _loadHabitData();
  }

  Future<void> _loadHabitData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('habits')
        .doc(widget.habitId)
        .get();
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data != null) {
      setState(() {
        _nameController.text = data['name'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _startDateController.text = (data['start_date'] as Timestamp)
            .toDate()
            .toString()
            .substring(0, 10);
        _endDateController.text = (data['end_date'] as Timestamp)
            .toDate()
            .toString()
            .substring(0, 10);
        _friendEmailController.text = data['friend_email'] ?? '';
        _selectedDays.setAll(
            0,
            List<bool>.from(
                data['recurring_days'] ?? List.generate(7, (_) => true)));
        _targetDays = data['target_days'] ?? 0;
        isLoading = false;
      });
    }
  }

  void _editHabit() async {
    if (_nameController.text.isEmpty) {
      setState(() {
        _isNameEmpty = true;
      });
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Map<String, dynamic> habitData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'start_date': Timestamp.fromDate(
            DateFormat('yyyy-MM-dd').parse(_startDateController.text)),
        'end_date': Timestamp.fromDate(
            DateFormat('yyyy-MM-dd').parse(_endDateController.text)),
        'target_days': _targetDays,
        'recurring_days': _selectedDays,
        'days': _generateHabitDays(),
        'friend_email': _friendEmailController.text,
        'friends': [],
      };

      if (_friendEmailController.text.isNotEmpty) {
        String friendEmail = _friendEmailController.text;
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('userEmail', isEqualTo: friendEmail)
            .limit(1)
            .get()
            .then((snapshot) => snapshot.docs.first);

        if (userSnapshot.exists) {
          String friendId = userSnapshot.id;
          habitData['friends'].add(friendId);
          _sendNotificationToFriend(friendId);
        }
      }

      FirebaseFirestore.instance
          .collection('habits')
          .doc(widget.habitId)
          .update(habitData)
          .then((value) {
        Navigator.pop(context);
        setState(() {
          isLoading = true;
        });
        _loadHabitData();
      }).catchError((error) {
        // Hata işleme kodları
      });
    }
  }

  void _deleteHabit() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot habitDoc = await FirebaseFirestore.instance
          .collection('habits')
          .doc(widget.habitId)
          .get();
      Map<String, dynamic> habitData = habitDoc.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance.collection('deleted_tasks').add({
        'name': habitData['name'],
        'description': habitData['description'],
        'deletedDate': DateTime.now(),
        'collection': 'habits',
        'docId': widget.habitId,
        'userId': user.uid,
        'data': habitData,
      });

      FirebaseFirestore.instance
          .collection('habits')
          .doc(widget.habitId)
          .delete()
          .then((value) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Homes()),
          (Route<dynamic> route) => false,
        );
      }).catchError((error) {
        // Hata işleme kodları
      });
    }
  }

  Future<void> _sendNotificationToFriend(String friendId) async {
    FirebaseFirestore.instance.collection('notifications').add({
      'toUserId': friendId,
      'message': 'You have been invited to join a habit!',
      'habitId': widget.habitId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Map<String, bool> _generateHabitDays() {
    Map<String, bool> habitDays = {};
    DateTime startDate =
        DateFormat('yyyy-MM-dd').parse(_startDateController.text);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(_endDateController.text);

    for (DateTime date = startDate;
        date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
        date = date.add(const Duration(days: 1))) {
      if (_selectedDays[date.weekday % 7]) {
        habitDays[DateFormat('yyyy-MM-dd').format(date)] = true;
      }
    }
    return habitDays;
  }

  void _selectDate(BuildContext context, TextEditingController controller,
      {DateTime? firstDate}) async {
    DateTime initialDate = DateTime.now();
    if (controller == _endDateController &&
        _startDateController.text.isNotEmpty) {
      initialDate = DateFormat('yyyy-MM-dd').parse(_startDateController.text);
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime.now(),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            dialogBackgroundColor: Theme.of(context).colorScheme.surface,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
        _calculateTargetDays();
      });
    }
  }

  void _calculateTargetDays() {
    if (_startDateController.text.isNotEmpty &&
        _endDateController.text.isNotEmpty) {
      DateTime startDate =
          DateFormat('yyyy-MM-dd').parse(_startDateController.text);
      DateTime endDate =
          DateFormat('yyyy-MM-dd').parse(_endDateController.text);
      int count = 0;
      for (DateTime date = startDate;
          date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
          date = date.add(const Duration(days: 1))) {
        if (_selectedDays[date.weekday % 7]) {
          count++;
        }
      }
      setState(() {
        _targetDays = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Card(
      color: theme.habitDetailEditBackground,
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(color: theme.checkBoxActiveColor),
            )
          : Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: theme.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                        _nameController, _isNameEmpty, "Habit Name", theme),
                    const SizedBox(height: 20),
                    _buildTextField(
                        _descriptionController, false, "Description", theme,
                        maxLines: 3),
                    const SizedBox(height: 20),
                    _buildTextField(
                        _friendEmailController, false, "Friend's Email", theme,
                        enabled: false),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                            child: _buildDateField(
                                _startDateController, "Start Date", theme)),
                        const SizedBox(width: 20),
                        Expanded(
                            child: _buildDateField(
                                _endDateController, "End Date", theme)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Target Days: $_targetDays",
                      style: TextStyle(color: theme.welcomeText, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    _buildDaySelectionSection(theme),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _deleteHabit,
                          child: const Text("Delete Habit"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.addButton,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _editHabit,
                          child: const Text("Update Habit"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, bool isNameEmpty,
      String label, CustomThemeData theme,
      {int maxLines = 1, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              color: theme.welcomeText, fontSize: 15, fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 2),
        TextFormField(
          controller: controller,
          style: TextStyle(color: theme.welcomeText),
          maxLines: maxLines,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: "Enter $label",
            hintStyle: TextStyle(color: theme.welcomeText.withAlpha(150)),
            filled: true,
            fillColor: theme.toDoCardBackground,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: isNameEmpty
                  ? const BorderSide(color: Colors.red)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: isNameEmpty
                  ? const BorderSide(color: Colors.red)
                  : BorderSide.none,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: isNameEmpty
                  ? const BorderSide(color: Colors.red)
                  : BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(TextEditingController controller, String label, CustomThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              color: theme.welcomeText, fontSize: 15, fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: () => _selectDate(context, controller,
              firstDate: controller == _endDateController &&
                      _startDateController.text.isNotEmpty
                  ? DateFormat('yyyy-MM-dd').parse(_startDateController.text)
                  : DateTime.now()),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.45,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.toDoCardBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              controller.text.isEmpty ? "Select Date" : controller.text,
              style: TextStyle(color: theme.welcomeText),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySelectionSection(CustomThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (index) {
        return FilterChip(
          label: Text(
            DateFormat.E().format(DateTime(2021, 1, index + 3)),
            style: TextStyle(color: theme.welcomeText),
          ),
          selected: _selectedDays[index],
          onSelected: (bool selected) {
            setState(() {
              _selectedDays[index] = selected;
              _calculateTargetDays();
            });
          },
          backgroundColor: theme.background,
          selectedColor: theme.focusDayColor,
        );
      }),
    );
  }
}
