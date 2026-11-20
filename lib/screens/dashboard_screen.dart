
import 'package:flutter/material.dart';

import '../data/sample_transactions.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final income = sampleTransactions
        .where((transaction) => !transaction.isExpense)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);

    final expenses = sampleTransactions
        .where((transaction) => transaction.isExpense)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);

    final balance = income - expenses;

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
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BalanceCard(
              balance: balance,
              income: income,
              expenses: expenses,
            ),

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

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sampleTransactions.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: TransactionTile(
                    transaction: sampleTransactions[index],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
