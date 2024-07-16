import 'package:flutter/material.dart';

class HabitPage extends StatefulWidget {
  
  const HabitPage({ super.key });

  @override
  _TodayPageState createState() => _TodayPageState();
}

class _TodayPageState extends State<HabitPage> {



 
  @override
  Widget build(BuildContext context) {
    return const Card(
          color: Color.fromARGB(255, 30, 30, 30),
          shadowColor: Colors.transparent,
          margin: EdgeInsets.only(right: 18),
          child: SizedBox.square(
            child: Column(
              children: [
                Text("...")
                
  ])),
        );
  }
}