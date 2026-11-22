import 'package:flutter/material.dart';

import '../data/sample_transactions.dart';
import '../models/transaction.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late List<Transaction> transactions;

  @override
  void initState() {
    super.initState();
    transactions = List.from(sampleTransactions);
  }

  double get income => transactions
      .where((t) => !t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get expenses => transactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => income - expenses;

  Future<void> _addTransaction() async {
    final result = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
    );

    if (!mounted || result == null) return;

    setState(() {
      transactions.insert(0, result);
    });
  }

  Future<void> _editTransaction(int index) async {
    final result = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddTransactionScreen(existingTransaction: transactions[index]),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      transactions[index] = result;
    });
  }

  void _deleteTransaction(int index) {
    final deletedTransaction = transactions[index];

    setState(() {
      transactions.removeAt(index);
    });

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final snackBarController = messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Text('${deletedTransaction.title} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              transactions.insert(
                index.clamp(0, transactions.length),
                deletedTransaction,
              );
            });
          },
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      snackBarController.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F4),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6F4),
        title: const Text(
          'WalletWave',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF173D35),
          ),
        ),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BalanceCard(balance: balance, income: income, expenses: expenses),

            const SizedBox(height: 28),

            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173D35),
              ),
            ),

            const SizedBox(height: 12),

            if (transactions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Text('No transactions yet'),
                ),
              ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];

                return Dismissible(
                  key: ObjectKey(transaction),
                  direction: DismissDirection.endToStart,

                  background: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),

                  onDismissed: (_) {
                    _deleteTransaction(index);
                  },

                  child: Card(
                    color: Colors.white,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _editTransaction(index),
                      child: TransactionTile(transaction: transaction),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addTransaction,
        backgroundColor: const Color(0xFF173D35),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
