import 'dart:io';

import 'package:adv_basic/features/expenses/models/expense.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({super.key, required this.onAddExpense, this.expense});

  final Expense? expense;

  final Future<void> Function({
    required String title,
    required double amount,
    required DateTime date,
    required Category category,
  })
  onAddExpense;
  //final Expense expense;
  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
      _selectedDate = widget.expense!.date;
      _selectedCategory = widget.expense!.category;
    }
  }

  void _showDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder:
            (ctx) => CupertinoAlertDialog(
              title: Text('Invalid Input'),
              content: Text('Please enter a valid title, amount and date.'),
              actions: [
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: Text('Okay'),
                ),
              ],
            ),
      );
    } else {
      showDialog(
        context: context,
        builder:
            (cxt) => AlertDialog(
              title: Text('Invalid Input'),
              content: Text('Please enter a valid title, amount and date.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(cxt);
                  },
                  child: Text('Okay'),
                ),
              ],
            ),
      );
    }
  }

  Future<void> _submitExpenseData() async {
    final amountIsValid =
        (double.tryParse(_amountController.text.trim()) == null) ||
        (double.tryParse(_amountController.text.trim())! <= 0);
    if (_titleController.text.trim().isEmpty ||
        amountIsValid ||
        _selectedDate == null) {
      _showDialog();
      return;
    }
    await widget.onAddExpense(
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      date: _selectedDate!,
      category: _selectedCategory,
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  DateTime? _selectedDate;
  Category _selectedCategory = Category.leisure;
  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0, 40, 16.0, keyboardSpace + 16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Title'),
                  controller: _titleController,
                ),
                SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          prefix: Text('\$ '),
                          labelText: 'Amount',
                        ),
                        keyboardType: TextInputType.number,
                        controller: _amountController,
                      ),
                    ),

                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _selectedDate == null
                                ? 'Select Date'
                                : formatter.format(_selectedDate!),
                          ),
                          //const Spacer(),
                          IconButton(
                            onPressed: _presentDatePicker,
                            icon: Icon(Icons.calendar_month),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    DropdownButton(
                      value: _selectedCategory,
                      items:
                          Category.values
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category.name.toUpperCase()),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          if (value == null) return;
                          _selectedCategory = value;
                        });
                      },
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _submitExpenseData,
                      child: const Text('Save Expense'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
