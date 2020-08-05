import 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';

class FinanceTipsPage extends StatefulWidget {

  @override
  _FinanceTipsPageState createState() => _FinanceTipsPageState();
}

class _FinanceTipsPageState extends State<FinanceTipsPage> {

  DatabaseReference tips = FirebaseDatabase.instance.reference().child("tips");
  List<String> loadedTips = ["Try to use more cash!"];

  void initState() {
    tips.onChildAdded.listen(_addTips);
    print("Registered listner");
  }

  void _addTips(Event e) {
    loadedTips.add(e.snapshot.key.toString());
    // Dont try and set the state if this page isn't displayed
    if (this.mounted) {
      setState(() {});
    }
  }


  @override
  Widget build(BuildContext context) {
    var rng = new Random();

    int index = rng.nextInt(loadedTips.length);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                loadedTips[index],
                style: Theme.of(context).textTheme.headline4,
              ),
            )
          ],
        ),
      ),
    );
  }
}
