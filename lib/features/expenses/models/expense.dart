import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat.yMd();

const categoryIcons = {
  'food': Icons.lunch_dining,
  'travel': Icons.flight,
  'leisure': Icons.movie_creation_outlined,
  'work': Icons.work,
};

String formatCategoryName(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return 'Ăn uống';
    case 'travel':
      return 'Di chuyển';
    case 'leisure':
      return 'Giải trí';
    case 'work':
      return 'Công việc';
    default:
      return category;
  }
}

class Expense {
  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.category,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final int categoryId;
  final String category;

  String get formattedDate {
    return formatter.format(date);
  }

  IconData get icon {
    return categoryIcons[category.toLowerCase()] ?? Icons.category;
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'].toString(),
      title: json['title'],
      amount: double.parse(json['amount'].toString()),
      date: DateTime.parse(json['expense_date']),
      categoryId: int.parse(
        (json['categoryId'] ?? json['category_id'] ?? 0).toString(),
      ),
      category: (json['category'] ?? '').toString(),
    );
  }
}

class ExpenseBucket {
  const ExpenseBucket({required this.category, required this.expenses});

  ExpenseBucket.forCategory(List<Expense> allExpense, this.category)
    : expenses =
          allExpense.where((expense) => expense.category == category).toList();

  final String category;
  final List<Expense> expenses;

  double get totalExpenses {
    double sum = 0;

    for (final expense in expenses) {
      sum += expense.amount;
    }
    return sum;
  }
}
