
import '../models/transaction.dart';

final List<Transaction> sampleTransactions = [
  Transaction(
    title: 'Monthly Salary',
    amount: 50000,
    category: 'Salary',
    date: DateTime(2026, 11, 1),
    isExpense: false,
  ),
  Transaction(
    title: 'Grocery Shopping',
    amount: 2500,
    category: 'Food',
    date: DateTime(2026, 11, 3),
    isExpense: true,
  ),
  Transaction(
    title: 'Electricity Bill',
    amount: 1200,
    category: 'Bills',
    date: DateTime(2026, 11, 5),
    isExpense: true,
  ),
  Transaction(
    title: 'Freelance Work',
    amount: 10000,
    category: 'Work',
    date: DateTime(2026, 11, 7),
    isExpense: false,
  ),
  Transaction(
    title: 'Transportation',
    amount: 800,
    category: 'Transport',
    date: DateTime(2026, 11, 9),
    isExpense: true,
  ),
  Transaction(
    title: 'Shopping',
    amount: 3000,
    category: 'Shopping',
    date: DateTime(2026, 11, 12),
    isExpense: true,
  ),
  Transaction(
    title: 'Internet Bill',
    amount: 500,
    category: 'Bills',
    date: DateTime(2026, 11, 15),
    isExpense: true,
  ),
  Transaction(
    title: 'Gift Received',
    amount: 2000,
    category: 'Gift',
    date: DateTime(2026, 11, 18),
    isExpense: false,
  ),
];
