import 'dart:math';
import 'package:normal/normal.dart';

class InstallmentCalculator {

  static int getOptimalNumberOfSplits(List<double> installments, double price, double income, double cash, double savingsGoal) {
    int smallestInstallment = getSmallestRecommendedInstallments(installments, price, income, savingsGoal, cash);
    print("Smallest installment: " + smallestInstallment.toString());

    double minProbBankrupcy = 1;
    int optimalInstallments;

    // check for errors
    if (smallestInstallment == -1) {
      return -1;
    }

    // start looking forward from here
    for (int i = smallestInstallment; i < 12; i++) {
      double newProbBankrupcy = getProbOfBankrupcy(cash, price, i);
      print(i);
      print(newProbBankrupcy);
      if (newProbBankrupcy < minProbBankrupcy) {
        minProbBankrupcy = newProbBankrupcy;
        optimalInstallments = i;
      }
    }

    return optimalInstallments;
  }

  static double getProbOfBankrupcy(double cash, double price, int nInstallments) {
    double variance = 0.10 * cash;
    double std = (cash - price / nInstallments) / (nInstallments * variance);
    double pBankrupcy = 2 * (1 - Normal.cdf(std));

    return pBankrupcy;

  }

  static int getSmallestRecommendedInstallments(
      List<double> installments, double price, double income, double savingsGoal, double cash) {

    for (int i = 1; i < 13; i++) {
      List<double> postInstallments = getInstallmentsAfterSplittingNTimes(installments, price, i);
      if (areUnder30Line(income, postInstallments, cash) && postInstallments[0] < income - savingsGoal) {
        return i;
      }
    }
    return -1;

  }


  static bool areUnder30Line(double income, List<double> installments, double cash) {
    List<double> line = gen30Line(income, cash);
    for (int i = 0; i < line.length; i ++) {
      if (installments[i] > line[i]) {
        return false;
      }
    }
    return true;

  }

  static List<double> gen30Line(double income, double cash) {
    List<double> line = [];
    double recom = 0.30 * income;
    double c = recom * min(2/3, cash / income);
    for (int i = 0; i < 12; i++) {
      double val = (recom/ (i + 1)) + c / (i + 1) * log(i + 1);
      line.add(val);
    }
    return line;
  }

  static List<double> getInstallmentsAfterSplittingNTimes(List<double> installments, double price, int nInstallments) {
    List<double> newInstallments = [];
    for (int i = 0; i < installments.length; i++) {
      newInstallments.add(installments[i]);
      if (i < nInstallments) {
        newInstallments[i] += price / nInstallments;
      }
    }
    return newInstallments;
  }
}
