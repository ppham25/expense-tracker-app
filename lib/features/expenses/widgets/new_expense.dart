import 'package:adv_basic/features/categories/models/category_model.dart';
import 'package:adv_basic/features/categories/services/category_service.dart';
import 'package:adv_basic/features/expenses/models/expense.dart';
import 'package:flutter/material.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({super.key, required this.onAddExpense, this.expense});

  final Expense? expense;

  final Future<void> Function({
    required String title,
    required double amount,
    required DateTime date,
    required int categoryId,
  })
  onAddExpense;

  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final CategoryService _categoryService = CategoryService();

  DateTime? _selectedDate;
  ExpenseCategory? _selectedCategory;
  List<ExpenseCategory> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
      _selectedDate = widget.expense!.date;
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _isLoadingCategories = false;

        if (widget.expense != null) {
          _selectedCategory = categories.cast<ExpenseCategory?>().firstWhere(
            (category) => category?.id == widget.expense!.categoryId,
            orElse: () => categories.isNotEmpty ? categories.first : null,
          );
        } else if (categories.isNotEmpty) {
          _selectedCategory = categories.first;
        }
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingCategories = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tải được danh mục: $error')),
      );
    }
  }

  void _showInvalidInputDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Invalid Input'),
            content: const Text(
              'Please enter a valid title, amount, date and category.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text('Okay'),
              ),
            ],
          ),
    );
  }

  Future<void> _showAddCategoryDialog() async {
    final categoryController = TextEditingController();

    final categoryName = await showDialog<String>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Thêm danh mục'),
            content: TextField(
              controller: categoryController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Tên danh mục',
                hintText: 'Ví dụ: học tập',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx, categoryController.text.trim());
                },
                child: const Text('Lưu'),
              ),
            ],
          ),
    );

    categoryController.dispose();

    if (categoryName == null || categoryName.isEmpty) return;

    try {
      final newCategory = await _categoryService.addCategory(categoryName);

      if (!mounted) return;

      setState(() {
        _categories.add(newCategory);
        _selectedCategory = newCategory;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã thêm danh mục mới')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Thêm danh mục thất bại: $error')));
    }
  }

  Future<void> _submitExpenseData() async {
    final enteredAmount = double.tryParse(_amountController.text.trim());
    final amountIsInvalid = enteredAmount == null || enteredAmount <= 0;

    if (_titleController.text.trim().isEmpty ||
        amountIsInvalid ||
        _selectedDate == null ||
        _selectedCategory == null) {
      _showInvalidInputDialog();
      return;
    }

    try {
      await widget.onAddExpense(
        title: _titleController.text.trim(),
        amount: enteredAmount,
        date: _selectedDate!,
        categoryId: _selectedCategory!.id,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Thêm chi tiêu thất bại: $error')));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

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
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          suffixText: 'Nghìn VNĐ',
                          labelText: 'Số tiền',
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
                          IconButton(
                            onPressed: _presentDatePicker,
                            icon: const Icon(Icons.calendar_month),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (_isLoadingCategories)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      DropdownButton<int>(
                        value: _selectedCategory?.id,
                        hint: const Text('Category'),
                        items: [
                          ..._categories.map(
                            (category) => DropdownMenuItem<int>(
                              value: category.id,
                              child: Text(category.name.toUpperCase()),
                            ),
                          ),
                          const DropdownMenuItem<int>(
                            value: -1,
                            child: Row(
                              children: [
                                Icon(Icons.add, size: 18),
                                SizedBox(width: 6),
                                Text('THÊM DANH MỤC'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) async {
                          if (value == null) return;

                          if (value == -1) {
                            await _showAddCategoryDialog();
                            return;
                          }

                          setState(() {
                            _selectedCategory = _categories.firstWhere(
                              (category) => category.id == value,
                            );
                          });
                        },
                      ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
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
