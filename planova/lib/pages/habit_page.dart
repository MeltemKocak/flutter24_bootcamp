import 'package:flutter/material.dart';

class HabitPage extends StatefulWidget {
  
  const HabitPage({ Key? key }) : super(key: key);

  @override
  _TodayPageState createState() => _TodayPageState();
}

class _TodayPageState extends State<HabitPage> {



 
  @override
  Widget build(BuildContext context) {
    return Card(
          color: const Color.fromARGB(255, 30, 30, 30),
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.only(right: 18),
          child: SizedBox.square(
            child: Column(
              children: [
                Text("...")
                
  ])),
        );
  }
}