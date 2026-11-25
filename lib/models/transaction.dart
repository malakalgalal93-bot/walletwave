
class Transaction {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isExpense;

  Transaction({
    String? id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isExpense,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'isExpense': isExpense,
    };
  }

  factory Transaction.fromMap(Map<dynamic, dynamic> map) {
    return Transaction(
      id: map['id'].toString(),
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      category: map['category'],
      date: DateTime.parse(map['date']),
      isExpense: map['isExpense'],
    );
  }
}
