class Account {
  final int id;
  final String name;
  final String type;
  final double balance;
  final String currency;

  Account({required this.id, required this.name, required this.type,
    required this.balance, required this.currency});

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    balance: (json['balance'] as num).toDouble(),
    currency: json['currency'] ?? 'USD',
  );
}
