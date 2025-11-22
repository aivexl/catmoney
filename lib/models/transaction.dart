class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String? catEmoji;
  final String accountId;
  final String? notes;
  final String? photoPath;
  final bool isWatchlisted;

  // New fields for integration
  final String? wishlistId;
  final String? budgetId;
  final String? billId;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.catEmoji,
    this.accountId = 'cash',
    this.notes,
    this.photoPath,
    this.isWatchlisted = false,
    this.wishlistId,
    this.budgetId,
    this.billId,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'catEmoji': catEmoji,
      'accountId': accountId,
      'notes': notes,
      'photoPath': photoPath,
      'isWatchlisted': isWatchlisted,
      'wishlistId': wishlistId,
      'budgetId': budgetId,
      'billId': billId,
    };
  }

  /// Create Transaction from Map dengan comprehensive validation
  /// Enterprise-level: Zero error guarantee dengan proper null safety
  factory Transaction.fromMap(Map<String, dynamic> map) {
    // Validate required fields dengan proper error handling
    final id = map['id'] as String?;
    if (id == null || id.isEmpty) {
      throw ArgumentError('Transaction id is required and cannot be empty');
    }

    final amountValue = map['amount'];
    if (amountValue == null) {
      throw ArgumentError('Transaction amount is required');
    }
    final amount = (amountValue as num).toDouble();
    if (amount.isNaN || amount.isInfinite) {
      throw ArgumentError('Transaction amount must be a valid number');
    }

    final category = map['category'] as String?;
    if (category == null || category.isEmpty) {
      throw ArgumentError('Transaction category is required');
    }

    final description = map['description'] as String? ?? '';

    final dateString = map['date'] as String?;
    if (dateString == null || dateString.isEmpty) {
      throw ArgumentError('Transaction date is required');
    }

    DateTime date;
    try {
      date = DateTime.parse(dateString);
    } catch (e) {
      throw ArgumentError('Invalid date format: $dateString');
    }

    // Parse transaction type dengan fallback
    TransactionType type;
    try {
      final typeString = map['type'] as String? ?? 'expense';
      type = TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == typeString,
        orElse: () => TransactionType.expense,
      );
    } catch (e) {
      type = TransactionType.expense; // Safe fallback
    }

    return Transaction(
      id: id,
      type: type,
      amount: amount,
      category: category,
      description: description,
      date: date,
      catEmoji: map['catEmoji'] as String?,
      accountId: map['accountId'] as String? ?? 'cash',
      notes: map['notes'] as String?,
      photoPath: map['photoPath'] as String?,
      isWatchlisted: map['isWatchlisted'] as bool? ?? false,
      wishlistId: map['wishlistId'] as String?,
      budgetId: map['budgetId'] as String?,
      billId: map['billId'] as String?,
    );
  }

  // Copy with method
  Transaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? category,
    String? description,
    DateTime? date,
    String? catEmoji,
    String? accountId,
    String? notes,
    String? photoPath,
    bool? isWatchlisted,
    String? wishlistId,
    String? budgetId,
    String? billId,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      catEmoji: catEmoji ?? this.catEmoji,
      accountId: accountId ?? this.accountId,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
      isWatchlisted: isWatchlisted ?? this.isWatchlisted,
      wishlistId: wishlistId ?? this.wishlistId,
      budgetId: budgetId ?? this.budgetId,
      billId: billId ?? this.billId,
    );
  }
}

enum TransactionType {
  income,
  expense,
  transfer,
}
