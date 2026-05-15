class ExpenseCategory {
  const ExpenseCategory({required this.id, required this.name});

  final int id;
  final String name;

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: int.parse(json['id'].toString()),
      name: json['name'].toString(),
    );
  }
}
