class Transaction {
  final int id;
  final double amount;
  final String description;
  final String date;
  final String type;
  final String accountName;

  Transaction({required this.id, required this.amount, required this.description,
    required this.date, required this.type, required this.accountName});

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    amount: (json['amount'] as num).toDouble(),
    description: json['description'],
    date: json['date'],
    type: json['type'],
    accountName: json['account']?['name'] ?? '',
  );
}
