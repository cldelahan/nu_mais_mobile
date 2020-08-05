import 'package:firebase_database/firebase_database.dart';

class Transaction {

  double amount;
  String category;
  DateTime date;
  String description;
  int nPart;
  int nTotal;
  String user;


  Transaction({
    this.amount, this.category, this.date, this.description, this.nPart, this.nTotal, this.user
  });


  static Future<Transaction> populateTransaction(DataSnapshot ds) async {
    Map entry = ds.value;

    String dateRep = entry["date"];
    int year = int.parse(dateRep.substring(0, 4));
    int month = int.parse(dateRep.substring(5, 7));
    int day = int.parse(dateRep.substring(8));


    Transaction temp = Transaction(
      amount: entry["amount"].toDouble(),
      category: entry["category"],
      date: DateTime(year = year, month = month, day = day),
      description: entry["description"],
      nPart: entry["nPart"],
      nTotal: entry["nTotal"],
      user: entry["user"]
    );

    return temp;
  }
}
