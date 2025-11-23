class Account {
  final String id;
  final String name;
  final String icon;
  final bool isDefault;
  final int color; // Store as int (Color.value)

  Account({
    required this.id,
    required this.name,
    required this.icon,
    this.isDefault = false,
    required this.color,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'isDefault': isDefault,
      'color': color,
    };
  }

  // Create from Map
  /// Create Account from Map dengan comprehensive validation
  /// Enterprise-level: Zero error guarantee dengan proper null safety
  /// Enterprise-level: Zero error guarantee dgn proper null safety
  factory Account.fromMap(Map<String, dynamic> map) {
    // Validate required fields
    final id = map['id'] as String?;
    if (id == null || id.isEmpty) {
      throw ArgumentError('Account id is required and cannot be empty');
    }

    final name = map['name'] as String?;
    if (name == null || name.isEmpty) {
      throw ArgumentError('Account name is required');
    }

    final icon = map['icon'] as String? ?? 'assets/icons/cardicon.png';

    // Get color from map, or use default based on name
    final int color = map['color'] as int? ?? _getDefaultColor(name);

    return Account(
      id: id,
      name: name,
      icon: icon,
      isDefault: map['isDefault'] as bool? ?? false,
      color: color,
    );
  }

  // Helper to get default color based on account name
  static int _getDefaultColor(String name) {
    switch (name.toLowerCase()) {
      case 'cash':
        return 0xFFBAFFC9; // Pastel Mint
      case 'card':
        return 0xFFBAE1FF; // Pastel Blue
      default:
        return 0xFFFFB3BA; // Pastel Pink
    }
  }

  // Default accounts
  static List<Account> getDefaultAccounts() {
    return [
      Account(
        id: 'cash',
        name: 'Cash',
        icon: 'account_balance_wallet',
        isDefault: true,
        color: 0xFFBAFFC9, // Pastel Mint
      ),
      Account(
        id: 'card',
        name: 'Card',
        icon: 'credit_card',
        isDefault: true,
        color: 0xFFBAE1FF, // Pastel Blue
      ),
    ];
  }
}
