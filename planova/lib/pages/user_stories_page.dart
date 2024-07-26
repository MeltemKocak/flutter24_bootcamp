import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class UserStoriesPage extends StatefulWidget {
  @override
  _UserStoriesPageState createState() => _UserStoriesPageState();
}

class _UserStoriesPageState extends State<UserStoriesPage> {
  late final Gemini gemini;
  String response = "Hey! Create Your Story.";
  bool _isLoading = false;
  String userName = "";
  bool storyExists = false;
  List<Map<String, dynamic>> stories = [];
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Gemini.init(apiKey: "AIzaSyCc49bDki47KVW42vhvxMNyi7mO9dy0OLI");
    gemini = Gemini.instance;
    _fetchUserName();
    _fetchStory();
  }

  Future<void> _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        userName = userDoc['name'] ?? 'User';
      });
    }
  }

  Future<void> _fetchStory() async {
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user!.uid;
    String selectedDateString = DateFormat('yyyy-MM-dd').format(selectedDate);

    QuerySnapshot storySnapshot = await FirebaseFirestore.instance
        .collection('stories')
        .where('user_id', isEqualTo: userId)
        .where('date', isEqualTo: selectedDateString)
        .get();

    setState(() {
      stories = storySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      storyExists = storySnapshot.docs.isNotEmpty;
    });
  }

  Future<void> _sendMessage() async {
    setState(() {
      _isLoading = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    String userId = user!.uid;
    String user_data = await _getUserData(userId);
    String prompt =
        "girdiğim verilere dayanarak bana bir kişiselleştirilmiş bir hikaye yaz. olabildiğince girilen verileri hikayeye dahil et. benzetmeler kullan, ilham verici bir hava kat. futuristik, ortaçağ, gibi temalardan biri ile kurgusal bir hava yarat! hikaye kısa olsun, tek parafraf maksimum 100 kelime, kafana göre karakter ismi uydurma benim için isimsiz bir şekilde hikaye oluştur. 2. tekil şahıs kullan.";

    if (user_data.isEmpty) {
      setState(() {
        response = "Start Using Planova to Create Your Story!";
        _isLoading = false;
      });
    } else {
      try {
        String fullResponse = "";
        await for (var event
            in gemini.streamGenerateContent(user_data + prompt)) {
          fullResponse += event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "No content received";
        }

        setState(() {
          response = fullResponse;
          _isLoading = false;
          storyExists = true;
        });

        // Store the story in Firestore
        String selectedDateString =
            DateFormat('yyyy-MM-dd').format(selectedDate);
        await FirebaseFirestore.instance.collection('stories').add({
          'user_id': userId,
          'date': selectedDateString,
          'story': fullResponse,
        });

        // Fetch updated stories
        _fetchStory();
      } catch (e) {
        setState(() {
          response = "Error: $e";
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _getUserData(String userId) async {
    String userData = "";
    var habitsSnapshot = await FirebaseFirestore.instance
        .collection('habits')
        .where('user_id', isEqualTo: userId)
        .get();
    var journalSnapshot = await FirebaseFirestore.instance
        .collection('journal')
        .where('user_id', isEqualTo: userId)
        .get();
    var todosSnapshot = await FirebaseFirestore.instance
        .collection('todos')
        .where('userId', isEqualTo: userId)
        .get();

    habitsSnapshot.docs.forEach((doc) {
      var data = doc.data();
      if (data.containsKey('name') && data.containsKey('description')) {
        userData += "Habit: ${data['name']}: ${data['description']}\n";
      }
    });
    journalSnapshot.docs.forEach((doc) {
      var data = doc.data();
      if (data.containsKey('name') && data.containsKey('description')) {
        userData += "Journal: ${data['name']}: ${data['description']}\n";
      }
    });
    todosSnapshot.docs.forEach((doc) {
      var data = doc.data();
      if (data.containsKey('taskName') && data.containsKey('taskDescription')) {
        userData += "Todo: ${data['taskName']}: ${data['taskDescription']}\n";
      }
    });

    return userData;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color.fromARGB(255, 0, 0, 0),
              onPrimary: Colors.white,
              surface: Colors.teal,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      await _fetchStory();
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('d MMMM').format(selectedDate);

    return Scaffold(
      backgroundColor: const Color(0XFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: null,
        toolbarHeight: 100,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                  const Icon(
                    Icons.arrow_back_ios,
                    color: Color.fromARGB(255, 3, 218, 198),
                    size: 28,
                  ),
                  const Text(
                    'Geri',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      color: Color.fromARGB(255, 3, 218, 198),
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text("Select Date"),
            ),
            const SizedBox(height: 30),
            if (storyExists)
              for (var story in stories)
                _buildStoryCard(userName, story['date'], story['story'])
            else if (selectedDate.isAtSameMomentAs(DateTime.now()) ||
                selectedDate.isBefore(DateTime.now()))
              _buildCreateStoryButton()
            else
              _buildNoStoryMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCard(String userName, String date, String story) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, 17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        gradient: LinearGradient(
          begin: Alignment(-1, 0),
          end: Alignment(1, 0),
          colors: <Color>[
            Color(0xFF004942),
            Color(0xFF005C54),
            Color.fromARGB(166, 1, 143, 131),
            Color.fromARGB(136, 3, 218, 197)
          ],
          stops: <double>[0.331, 0.536, 0.821, 1],
        ),
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(13, 17, 19, 17),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 17),
              child: Text(
                '$userName\'s Story',
                style: GoogleFonts.getFont(
                  'Exo 2',
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  height: 1,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 17),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  DateFormat('d MMMM').format(DateTime.parse(date)),
                  style: GoogleFonts.getFont(
                    'Exo 2',
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    height: 1,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 15.7, 0),
              child: Text(
                story,
                style: GoogleFonts.getFont(
                  'Exo 2',
                  fontWeight: FontWeight.w200,
                  fontSize: 14,
                  height: 1,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateStoryButton() {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sendMessage,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : Text(
                'Create Story',
                style: GoogleFonts.getFont(
                  'Exo 2',
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildNoStoryMessage() {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 20),
      child: Text(
        'No story available for this date.',
        style: GoogleFonts.getFont(
          'Exo 2',
          fontWeight: FontWeight.w500,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}
