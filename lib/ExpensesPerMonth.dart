import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ExpensesPerMonth {
  final String month;
  final double expense;
  final charts.Color color;

  ExpensesPerMonth(this.month, this.expense, Color color)
      : this.color = new charts.Color(
      r: color.red, g: color.green, b: color.blue, a: color.alpha);
}