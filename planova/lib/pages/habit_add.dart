import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
        'user_id': user.uid,
        'days': _generateHabitDays(),
        'completed_days': {},
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
          // Arkadaşın hesabına da aynı alışkanlığı ekle, ancak isPending true olarak
          FirebaseFirestore.instance.collection('habits').add({
            ...habitData,
            'user_id': friendId,
            'friends': [user.uid], // X kişisinin id'si friends alanına eklenir
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
        // Hata işleme kodları
      });
    }
  }

  Future<void> _sendNotificationToFriend(String friendId) async {
    FirebaseFirestore.instance.collection('notifications').add({
      'toUserId': friendId,
      'message': 'You have been invited to join a habit!',
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
            colorScheme: const ColorScheme.dark(
              primary: Color(0XFF03DAC6),
              onPrimary: Colors.white,
              surface: Color(0XFF1E1E1E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0XFF1E1E1E),
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
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        color: Color(0XFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(_nameController, "Habit Name", _isNameEmpty),
            const SizedBox(height: 20),
            _buildTextField(_descriptionController, "Description", false,
                maxLines: 3),
            const SizedBox(height: 20),
            _buildTextField(_friendEmailController, "Friend's Email", false),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _buildDateField(_startDateController, "Start Date")),
                const SizedBox(width: 20),
                Expanded(
                    child: _buildDateField(_endDateController, "End Date")),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Target Days: $_targetDays",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            _buildDaySelectionSection(),
            const SizedBox(height: 30),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, bool isEmpty,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 2),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: "Enter $label",
            hintStyle:
                const TextStyle(color: Color.fromARGB(150, 255, 255, 255)),
            filled: true,
            fillColor: const Color(0X3F607D8B),
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

  Widget _buildDateField(TextEditingController controller, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w300),
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
              color: const Color(0X3F607D8B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              controller.text.isEmpty ? "Select Date" : controller.text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySelectionSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (index) {
        return FilterChip(
          label: Text(
            DateFormat.E().format(DateTime(2021, 1, index + 3)),
            style: const TextStyle(color: Colors.white),
          ),
          selected: _selectedDays[index],
          onSelected: (bool selected) {
            setState(() {
              _selectedDays[index] = selected;
              _calculateTargetDays();
            });
          },
          backgroundColor: const Color(0XFF607D8B),
          selectedColor: const Color(0XFF03DAC6),
        );
      }),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0XFF03DAC6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _addHabit,
        child: const Text("Confirm Habit"),
      ),
    );
  }
}
