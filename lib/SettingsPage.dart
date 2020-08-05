import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with AutomaticKeepAliveClientMixin{
  DatabaseReference dbuser;

  double _income = 0;
  double _savingsGoal = 0;
  double _fixedExpenses = 0;
  double _savingsGoalSlider = 0;
  bool wantKeepAlive = true;

  TextEditingController priceController = new TextEditingController();

  final _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    dbuser =
        FirebaseDatabase.instance.reference().child("user_nu").child("u142652");
    dbuser.onChildAdded.listen(_saveValues);
  }

  void _saveValues(Event event) async {
    DataSnapshot ds = event.snapshot;
    if (ds.key == "income") {
      _income = double.parse(ds.value.toString());
    }
    if (ds.key == "savingsgoal") {
      _savingsGoal = double.parse(ds.value.toString());
    }
    if (ds.key == "fixedexpenses") {
      _fixedExpenses = double.parse(ds.value.toString());
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  String _displayDoubleAsMoney(double value) {
    return 'R\$' + value.toStringAsFixed(2);
  }

  void _updateFirebase() {
    dbuser.update({"savingsgoal": _savingsGoalSlider});
    _savingsGoal = _savingsGoalSlider;
    setState(() {});
  }

  Widget displaySlider() {
    return Column(children: <Widget>[
      Text("Novo objetivo de economia: " + _displayDoubleAsMoney(_savingsGoalSlider),
          style: Theme.of(context).textTheme.headline5,
      textAlign: TextAlign.center,),
      Slider(
        min: 0.0,
        max: (((_income - _fixedExpenses) ~/ 50) * 50).toDouble(),
        divisions: ((_income - _fixedExpenses) ~/ 50).toInt() == 0 ? 1 : ((_income - _fixedExpenses) ~/ 50).toInt(),
        value: _savingsGoalSlider.toInt().toDouble(),
        onChanged: (newValue) {
          setState(() {
            _savingsGoalSlider = (newValue.toInt()).toDouble();
          });
        },
        activeColor: Theme.of(context).primaryColor,
        inactiveColor: Theme.of(context).secondaryHeaderColor,
      )
    ]);
  }

  Widget displayForm() {
    return Padding(
        padding: EdgeInsets.fromLTRB(50.0, 20.0, 50.0, 0.0),
        child: Column(children: <Widget>[
          displaySlider(),
          new RaisedButton(
              onPressed: _updateFirebase, child: Text("Atualizar objetivo de economia")),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: <Widget>[
      Padding(
          padding: EdgeInsets.fromLTRB(20.0, 100.0, 20.0, 0.0),
          child: Text(
              "Objetivo de economia mensal: " + _displayDoubleAsMoney(_savingsGoal),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline4)),
      displayForm()
    ]));
  }
}
