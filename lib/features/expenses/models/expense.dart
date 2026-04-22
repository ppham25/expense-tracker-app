import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat.yMd();

enum Category { food, travel, leisure, work }

const categoryIcons = {
  Category.food: Icons.lunch_dining,
  Category.travel: Icons.flight,
  Category.leisure: Icons.movie_creation_outlined,
  Category.work: Icons.work,
};

class Expense {
  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  String get formattedDate {
    return formatter.format(date);
  }

  IconData get icon {
    return categoryIcons[category]!;
  }

  static Category _parseCategory(String category) {
    switch (category) {
      case 'food':
        return Category.food;
      case 'travel':
        return Category.travel;
      case 'leisure':
        return Category.leisure;
      case 'work':
        return Category.work;
      default:
        throw Exception('Invalid category: $category');
    }
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'].toString(),
      title: json['title'],
      amount: double.parse(json['amount'].toString()),
      date: DateTime.parse(json['expense_date']),
      category: _parseCategory(json['category']),
    );
  }
}

class ExpenseBucket {
  const ExpenseBucket({required this.category, required this.expenses});

  ExpenseBucket.forCategory(List<Expense> allExpense, this.category)
    : expenses =
          allExpense.where((expense) => expense.category == category).toList();

  final Category category;
  final List<Expense> expenses;

  double get totalExpenses {
    double sum = 0;

    for (final expense in expenses) {
      sum += expense.amount;
    }
    return sum;
  }
}
