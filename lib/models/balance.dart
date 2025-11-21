class Balance {
  final double total;
  final double income;
  final double expense;

  Balance({
    required this.total,
    required this.income,
    required this.expense,
  });

  Balance.zero()
      : total = 0.0,
        income = 0.0,
        expense = 0.0;

  Balance copyWith({
    double? total,
    double? income,
    double? expense,
  }) {
    return Balance(
      total: total ?? this.total,
      income: income ?? this.income,
      expense: expense ?? this.expense,
    );
  }
}












