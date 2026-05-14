import 'package:adv_basic/features/budget/models/budget.dart';
import 'package:flutter/material.dart';

class NewBudget extends StatefulWidget {
  const NewBudget({super.key, required this.budget, required this.onSave});

  final Budget budget;
  final Future<void> Function(double limitAmount) onSave;
  @override
  State<NewBudget> createState() => _NewBudgetState();
}

class _NewBudgetState extends State<NewBudget> {
  final budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      budgetController.text = widget.budget.limitAmount.toString();
    }
  }

  Future<void> _submitBudgetdata() async {
    final budgetInvalid =
        budgetController.text.trim().isEmpty ||
        double.parse(budgetController.text.trim()) < 0;
    if (budgetInvalid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid budget amount.')),
      );
      return;
    }
    try {
      await widget.onSave(double.parse(budgetController.text.trim()));
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Thêm budget thất bại: $e')));
    }
  }

  @override
  void dispose() {
    budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    final bgtext = widget.budget.category.toUpperCase();

    return Container(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + keyboardSpace),
        child: Column(
          children: [
            Text("Tháng ${widget.budget.month}/${widget.budget.year}"),
            Text(
              bgtext,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffix: Text("Nghìn VNĐ"),
                labelText: "Giới hạn chi tiêu (VND)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel"),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitBudgetdata,
                    child: Text("Save"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
