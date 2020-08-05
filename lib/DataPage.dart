import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:down/Transaction.dart';
import 'package:normal/normal.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:down/ExpensesPerMonth.dart';
import 'package:down/InstallmentCalculator.dart';

class DataPage extends StatefulWidget {
  double _price;

  DataPage(this._price);

  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  DatabaseReference dbTransactions;
  DatabaseReference dbUser;

  List<Transaction> transactions = [];

  double _accBalance = 0;
  List<double> _moInstallments = [];
  double _fixedExpenses = 0;
  int _optInstallments = 0;

  double _income = 0;
  double _savingsGoal = 0;

  List<ExpensesPerMonth> _seriesData = [];
  var _series;

  bool _includeExpenses = false;

  // its a double for the slider
  // always round it when using
  double _nInstallments = 1;

  @override
  void initState() {
    dbTransactions =
        FirebaseDatabase.instance.reference().child("transactions_nu");
    dbTransactions.onChildAdded.listen(_addTransaction);

    dbUser =
        FirebaseDatabase.instance.reference().child("user_nu").child("u142652");
    dbUser.onChildAdded.listen(_saveValues);
  }

  void _addTransaction(Event event) async {
    Transaction temp = await Transaction.populateTransaction(event.snapshot);
    transactions.add(temp);
    setState(() {});
  }

  void _saveValues(Event event) async {
    DataSnapshot ds = event.snapshot;
    if (ds.key == "income") {
      _income = double.parse(ds.value.toString());
    }

    if (ds.key == "savingsgoal") {
      _savingsGoal = double.parse(ds.value.toString());
    }
    setState(() {});
  }

  String _displayDoubleAsMoney(double value) {
    return 'R\$' + value.toStringAsFixed(2);
  }

  double _populateBalanceOfAccount() {
    double balance = 0.0;
    for (Transaction t in transactions) {
      if (t.date.isBefore(DateTime.now())) {
        balance += t.amount;
      }
    }
    this._accBalance = balance;
    return balance;
  }

  /*int _getOptimalNumberOfSplits() {
    double cash = _getBalanceOfAccount();
    double variance = 0.15 * cash;
    double minProb = 1;
    int optInstallments = 0;

    for (int i = 1; i < 20; i++) {
      double std = (cash - widget._price / i) / (i * variance);
      double pBankrupcy = 2 * (1 - Normal.cdf(std));

      if (pBankrupcy < minProb) {
        minProb = pBankrupcy;
        optInstallments = i;
      }
    }
    this._optInstallments = optInstallments;
    return optInstallments;
  }*/

  void _populateVariables() {
    // ---------------------------------
    // first get the monthly installments
    // ---------------------------------

    double amt_fixed = 0;
    List<double> amt_installments = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    DateTime now = DateTime.now();
    DateTime startOfMonthBefore = DateTime(now.year, now.month - 1, 1);
    DateTime endOfMonthBefore = DateTime(now.year, now.month, 1);

    for (Transaction t in transactions) {
      // Is the trasaction in the last month
      if (t.date.isBefore(endOfMonthBefore) &&
          t.date.isAfter(startOfMonthBefore)) {
        // Does the transaction have months left?
        if (t.nPart < t.nTotal) {
          // Add this expense-to-happen to the amt_installments
          for (int m = 0; m < t.nTotal - t.nPart; m++) {
            amt_installments[m] += -1 * t.amount;
          }
        }
        // Use the last month as a proxy for future fixed expenses
        if (t.category == "Utilities" || t.category == "Housing") {
          amt_fixed += -1 * t.amount;
        }
      }
      // Is the transaction this month?
      if (t.date.isBefore(now) && t.date.isAfter(endOfMonthBefore)) {
        // Is it the first transaction for this month and are there more
        if (t.nPart == 1 && t.nTotal > 1) {
          // Add to future transactions
          for (int m = 0; m < t.nTotal - t.nPart; m++) {
            amt_installments[m] += -1 * t.amount;
          }
        }
      }
    }

    // finally consider this transaction
    /*for (int i = 0; i < _nInstallments.round(); i++) {
      amt_installments[i] += widget._price / _nInstallments.round();
    }*/

    print(amt_fixed);
    this._moInstallments = amt_installments;
    this._fixedExpenses = amt_fixed;

    // ---------------------------------
    // set the balance of account
    // ---------------------------------

    _populateBalanceOfAccount();

    // ---------------------------------
    // next get optimal number installments
    // ---------------------------------

    this._optInstallments = InstallmentCalculator.getOptimalNumberOfSplits(
        this._moInstallments,
        widget._price,
        _income,
        _accBalance,
        _savingsGoal);

    // ---------------------------------
    // finally generate the series for the graph
    // ---------------------------------

    _populateSeries();
  }

  void _populateSeries() {
    List<String> months = [
      "Ago",
      "Set",
      "Out",
      "Nov",
      "Dez",
      "Jan",
      "Fev",
      "Mar",
      "Abr",
      "Mai",
      "Jun",
      "Jul"
    ];

    _seriesData = [];

    List<double> line = InstallmentCalculator.gen30Line(_income, _accBalance);
    for (int i = 0; i < _moInstallments.length; i++) {
      double nValue = 0;
      if (i < _nInstallments.round()) {
        nValue += widget._price / _nInstallments.round();
      }
      if (_includeExpenses) {
        nValue += _moInstallments[i] + _fixedExpenses;
      } else {
        nValue += _moInstallments[i];
      }

      if (_includeExpenses) {
        this._seriesData.add(new ExpensesPerMonth(months[i], nValue,
            nValue > _income - _savingsGoal ? Colors.red : Colors.green));
      } else {
        this._seriesData.add(new ExpensesPerMonth(
            months[i], nValue, nValue > line[i] ? Colors.red : Colors.green));
      }
    }

    _series = [
      new charts.Series(
          id: 'Expenses',
          domainFn: (ExpensesPerMonth data, _) => data.month,
          measureFn: (ExpensesPerMonth data, _) => data.expense,
          colorFn: (ExpensesPerMonth data, _) => data.color,
          data: _seriesData)
    ];
  }

  Widget createSlider() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
        child: Column(children: <Widget>[
          Text(
              _nInstallments == 1
                  ? _nInstallments.toInt().toString() +
                      " parcela de " +
                      _displayDoubleAsMoney(widget._price / _nInstallments)
                  : _nInstallments.toInt().toString() +
                      " parcelas de " +
                      _displayDoubleAsMoney(widget._price / _nInstallments),
              style: Theme.of(context).textTheme.headline),
          Slider(
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Theme.of(context).secondaryHeaderColor,
              value: _nInstallments,
              onChanged: (double newValue) {
                setState(() {
                  _nInstallments = newValue;
                });
              },
              min: 1,
              max: 12,
              divisions: 11)
        ]));
  }

  Widget createChart() {
    if (_series.length == 0) {
      return Container(color: Colors.transparent);
    }

    var chart = new charts.BarChart(_series, animate: true);

    return new Padding(
      padding: new EdgeInsets.all(32.0),
      child: new SizedBox(
        height: 200.0,
        child: chart,
      ),
    );
  }

  Widget createTextHeader() {
    return Column(children: <Widget>[
      Text(
        "Esse item representa " +
            (100 * widget._price / _income).toStringAsFixed(1) +
            "% da sua renda mensal",
        style: Theme.of(context).textTheme.headline5,
        textAlign: TextAlign.center,
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
        child: Text("Valor da compra: " + _displayDoubleAsMoney(widget._price),
            style: Theme.of(context).textTheme.headline5),
      )
    ]);
  }

  Widget createOptimalSplitDisplay() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
      child: _optInstallments == -1
          ? Text("Talvez agora não seja o melhor momento para essa compra",
              style: Theme.of(context).textTheme.headline5)
          : Text(
              "Número recomendado de parcelas: " + _optInstallments.toString(),
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center,
            ),
    );
  }

  Widget createToggle() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Text(
        "Incluir estimativa de despesas? ",
        style: Theme.of(context).textTheme.bodyText2,
        textAlign: TextAlign.center,
      ),
      Switch(
        value: _includeExpenses,
        onChanged: (bool newValue) {
          setState(() {
            _includeExpenses = newValue;
          });
        },
        activeColor: Theme.of(context).primaryColor,
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    _populateVariables();
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(title: Text("Visualizar parcelas")),
            body: Padding(
                padding: EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 0.0),
                  child: Container(
                  child: Column(
                    children: <Widget>[
                      createTextHeader(),
                      createToggle(),
                      createSlider(),
                      createChart(),
                      createOptimalSplitDisplay(),
                    ],
                  ),
                ))));
  }
}
