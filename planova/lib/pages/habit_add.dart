import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:planova/utilities/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class HabitAddPage extends StatefulWidget {
  const HabitAddPage({super.key});

  @override
  _HabitAddPageState createState() => _HabitAddPageState();
}

class _HabitAddPageState extends State<HabitAddPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _friendEmailController = TextEditingController();
  final List<bool> _selectedDays = List.generate(7, (_) => true);
  int _targetDays = 0;
  bool _isNameEmpty = false;

  void _addHabit() async {
    if (_nameController.text.isEmpty) {
      setState(() {
        _isNameEmpty = true;
      });
      return;
    }

    DateTime startDate =
        DateFormat('yyyy-MM-dd').parse(_startDateController.text);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(_endDateController.text);

    // Start date and end date check
    if (startDate.isAfter(endDate)) {
      // Error handling: Start date should not be after end date
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(tr("Start date cannot be after end date.")),
      ));
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Map<String, dynamic> habitData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'start_date': Timestamp.fromDate(startDate),
        'end_date': Timestamp.fromDate(endDate),
        'target_days': _targetDays,
        'recurring_days': _selectedDays,
        'user_id': user.uid,
        'days': _generateHabitDays(),
        'completed_days': {},
        'friend_email': _friendEmailController.text,
        'friends': [],
        'isPending': false,
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
          FirebaseFirestore.instance.collection('habits').add({
            ...habitData,
            'user_id': friendId,
            'friends': [user.uid],
            'isPending': true,
          });
        }
      }

      FirebaseFirestore.instance
          .collection('habits')
          .add(habitData)
          .then((value) {
        Navigator.pop(context);
      }).catchError((error) {
        // Error handling
      });
    }
  }

  Future<void> _sendNotificationToFriend(String friendId) async {
    FirebaseFirestore.instance.collection('notifications').add({
      'toUserId': friendId,
      'message': tr("You have been invited to join a habit!"),
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    CustomThemeData theme = ThemeColors.getTheme(themeProvider.themeValue);

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
              primary: theme.focusDayColor,
              onPrimary: theme.addButtonIcon,
              surface: theme.background,
              onSurface: theme.calenderNumbers,
            ),
            dialogBackgroundColor: theme.background,
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    CustomThemeData theme = ThemeColors.getTheme(themeProvider.themeValue);

    return Container(
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
                _nameController, tr("Habit Name"), _isNameEmpty, theme),
            const SizedBox(height: 20),
            _buildTextField(
                _descriptionController, tr("Description"), false, theme,
                maxLines: 3),
            const SizedBox(height: 20),
            _buildTextField(
                _friendEmailController, tr("Friend's Email"), false, theme),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _buildDateField(
                        _startDateController, tr("Start Date"), theme)),
                const SizedBox(width: 20),
                Expanded(
                    child: _buildDateField(
                        _endDateController, tr("End Date"), theme)),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "${tr("Target Days")}: $_targetDays",
              style:
                  GoogleFonts.didactGothic(color: theme.subText, fontSize: 16),
            ),
            const SizedBox(height: 20),
            _buildDaySelectionSection(theme),
            const SizedBox(height: 30),
            _buildConfirmButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      bool isEmpty, CustomThemeData theme,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.didactGothic(
              color: theme.subText, fontSize: 15, fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 2),
        TextFormField(
          controller: controller,
          style: GoogleFonts.didactGothic(color: theme.welcomeText),
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: "${tr("Enter")} $label",
            hintStyle: GoogleFonts.didactGothic(
                color: theme.welcomeText.withOpacity(0.6)),
            filled: true,
            fillColor: theme.toDoCardBackground.withOpacity(1),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: isEmpty
                  ? const BorderSide(color: Colors.red)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: isEmpty
                  ? const BorderSide(color: Colors.red)
                  : BorderSide.none,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: isEmpty
                  ? const BorderSide(color: Colors.red)
                  : BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
      TextEditingController controller, String label, CustomThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.didactGothic(
              color: theme.subText, fontSize: 15, fontWeight: FontWeight.w300),
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
              color: theme.toDoCardBackground.withOpacity(1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              controller.text.isEmpty ? tr("Select Date") : controller.text,
              style: GoogleFonts.didactGothic(color: theme.welcomeText),
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
            _getDayName(index).tr(),
            style: GoogleFonts.didactGothic(color: theme.addButtonIcon),
          ),
          selected: _selectedDays[index],
          onSelected: (bool selected) {
            setState(() {
              _selectedDays[index] = selected;
              _calculateTargetDays();
            });
          },
          backgroundColor: theme.toDoCardBackground,
          selectedColor: theme.focusDayColor,
        );
      }),
    );
  }

  String _getDayName(int index) {
    switch (index) {
      case 0:
        return tr("Mon");
      case 1:
        return tr("Tue");
      case 2:
        return tr("Wed");
      case 3:
        return tr("Thu");
      case 4:
        return tr("Fri");
      case 5:
        return tr("Sat");
      case 6:
        return tr("Sun");
      default:
        return "";
    }
  }

  Widget _buildConfirmButton(CustomThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.addButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _addHabit,
        child: Text("Confirm Habit",
                style: GoogleFonts.didactGothic(
                    color: theme.addButtonIcon, fontWeight: FontWeight.w800))
            .tr(),
      ),
    );
  }
}
