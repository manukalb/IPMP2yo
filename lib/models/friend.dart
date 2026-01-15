class Friend {
  final int? id;
  final String name;
  final String? email;
  final double? creditBalance;
  final double? debitBalance;

  Friend({
    this.id,
    required this.name,
    this.email,
    this.creditBalance,
    this.debitBalance,
  });

  double get balance {
    return (creditBalance ?? 0.0) - (debitBalance ?? 0.0);
  }

  String get balanceStatus {
    if (balance > 0) {
      return 'Te debe €${balance.toStringAsFixed(2)}';
    } else if (balance < 0) {
      return 'Le debes €${(-balance).toStringAsFixed(2)}';
    } else {
      return 'Sin deudas';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (email != null) 'email': email,
      if (creditBalance != null) 'credit_balance': creditBalance,
      if (debitBalance != null) 'debit_balance': debitBalance,
    };
  }

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as int?,
      name: json['name'] as String,
      email: json['email'] as String?,
      creditBalance: (json['credit_balance'] as num?)?.toDouble(),
      debitBalance: (json['debit_balance'] as num?)?.toDouble(),
    );
  }

  @override
  String toString() {
    return '$id | $name | $creditBalance | $debitBalance';
  }

  @override
  bool operator ==(Object other) {
    return other is Friend && other.id == id && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
