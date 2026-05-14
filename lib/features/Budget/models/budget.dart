import 'dart:math';

enum BudgetStatus { noBudget, safe, watch, warning, over }

BudgetStatus budgetStatusFromString(String value) {
  switch (value) {
    case 'safe':
      return BudgetStatus.safe;
    case 'watch':
      return BudgetStatus.watch;
    case 'warning':
      return BudgetStatus.warning;
    case 'over':
      return BudgetStatus.over;
    case 'no_budget':
    default:
      return BudgetStatus.noBudget;
  }
}

class Budget {
  Budget({
    this.id,
    required this.category,
    required this.hasBudget,
    this.limitAmount,
    required this.spent,
    this.remaining,
    this.percentageUsed,
    required this.status,
    required this.month,
    required this.year,
  });

  final int? id;
  final String category;
  final bool hasBudget;
  final double? limitAmount;
  final double spent;
  final double? remaining;
  final int? percentageUsed;
  final BudgetStatus status;
  final int month;
  final int year;

  static const List<String> noBudgetMessages = [
    'Ví chưa có hàng rào bảo vệ đó 😆 Đặt budget ngay thôi!',
    'Chi tiêu đang chạy tự do rồi nha, set budget để kiểm soát ví nào!',
    'Chưa có budget mà vẫn tiêu đều tay, ví hơi run rồi đó 😅',
  ];

  static const List<String> safeMessages = [
    'Ổn áp, ví vẫn đang thở đều 😎',
    'Chi tiêu đang rất đẹp, cứ giữ phong độ này nhé!',
    'Ví còn khỏe, bạn đang kiểm soát tốt đó.',
  ];

  static const List<String> watchMessages = [
    'Bắt đầu cần để ý rồi nha 👀',
    'Ví đang nhắc nhẹ: tiêu chậm lại chút nào.',
    'Chưa nguy hiểm, nhưng cũng không nên chủ quan đâu.',
  ];

  static const List<String> warningMessages = [
    'Cẩn thận, ví bắt đầu rén rồi đó 😬',
    'Sắp chạm giới hạn rồi, đi nhẹ nói khẽ tiêu ít thôi.',
    'Budget đang đỏ mặt rồi nha!',
  ];

  static const List<String> overMessages = [
    'Cháy ví rồi! Tháng này hơi căng nha 🔥',
    'Vượt budget rồi, ví cần được cấp cứu!',
    'Tháng này tiêu hơi sung rồi đó 😭',
  ];

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      category: json['category'],
      hasBudget: json['hasBudget'] ?? false,
      limitAmount:
          json['limitAmount'] != null
              ? double.tryParse(json['limitAmount'].toString())
              : null,
      spent: double.tryParse(json['spent'].toString()) ?? 0.0,
      remaining:
          json['remaining'] != null
              ? double.tryParse(json['remaining'].toString())
              : null,
      percentageUsed:
          json['percentageUsed'] != null
              ? int.tryParse(json['percentageUsed'].toString())
              : null,
      status: budgetStatusFromString(json['status']),
      month: json['month'],
      year: json['year'],
    );
  }
  double get progressValue {
    if (percentageUsed == null) {
      return 0;
    }
    final progress = percentageUsed! / 100;

    return progress > 1 ? 1 : progress;
  }

  bool get isNoBudget => status == BudgetStatus.noBudget;

  String get funMessage {
    final mess = switch (status) {
      BudgetStatus.noBudget => noBudgetMessages,
      BudgetStatus.safe => safeMessages,
      BudgetStatus.watch => watchMessages,
      BudgetStatus.warning => warningMessages,
      BudgetStatus.over => overMessages,
    };
    final index = (Random().nextInt(20)) % mess.length;
    return mess[index];
  }
}
