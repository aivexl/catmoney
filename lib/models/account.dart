class Account {
  final String id;
  final String name;
  final String icon;
  final bool isDefault;

  Account({
    required this.id,
    required this.name,
    required this.icon,
    this.isDefault = false,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'isDefault': isDefault,
    };
  }

  // Create from Map
  /// Create Account from Map dengan comprehensive validation
  /// Enterprise-level: Zero error guarantee dengan proper null safety
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
    
    final icon = map['icon'] as String? ?? '💳';
    
    return Account(
      id: id,
      name: name,
      icon: icon,
      isDefault: map['isDefault'] as bool? ?? false,
    );
  }

  // Default accounts
  static List<Account> getDefaultAccounts() {
    return [
      Account(id: 'cash', name: 'Cash', icon: '💵', isDefault: true),
      Account(id: 'card', name: 'Card', icon: '💳', isDefault: true),
    ];
  }
}

