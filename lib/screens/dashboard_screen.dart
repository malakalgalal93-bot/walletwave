import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../data/sample_transactions.dart';
import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TransactionRepository _repository = TransactionRepository();

  List<Transaction> transactions = [];

  bool isLoading = true;
  String? errorMessage;

  late DateTime selectedMonth;

  @override
  void initState() {
    super.initState();

    selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

    _loadTransactions();
  }

  // تحميل المعاملات من قاعدة البيانات
  Future<void> _loadTransactions() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // صندوق خاص لمعرفة هل أضفنا البيانات التجريبية سابقاً
      final settingsBox = await Hive.openBox('walletwave_settings');

      final alreadySeeded = settingsBox.get(
        'sampleDataSeeded',
        defaultValue: false,
      );

      // إضافة البيانات التجريبية مرة واحدة فقط
      if (alreadySeeded != true) {
        for (final transaction in sampleTransactions) {
          await _repository.add(transaction);
        }

        await settingsBox.put('sampleDataSeeded', true);
      }

      // استرجاع المعاملات المحفوظة
      final savedTransactions = await _repository.getAll();

      if (!mounted) return;

      setState(() {
        transactions = savedTransactions;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Could not load transactions.';
      });
    }
  }

  // معاملات الشهر المحدد فقط
  List<Transaction> get monthlyTransactions {
    return transactions.where((transaction) {
      return transaction.date.year == selectedMonth.year &&
          transaction.date.month == selectedMonth.month;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  // إجمالي الدخل للشهر
  double get income => monthlyTransactions
      .where((t) => !t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  // إجمالي المصروفات للشهر
  double get expenses => monthlyTransactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  // الرصيد للشهر
  double get balance => income - expenses;

  // الانتقال للشهر السابق
  void _previousMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    });
  }

  // الانتقال للشهر التالي
  void _nextMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
    });
  }

  // عرض رسالة الخطأ
  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // إضافة معاملة
  Future<void> _addTransaction() async {
    final result = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
    );

    if (!mounted || result == null) return;

    try {
      await _repository.add(result);

      if (!mounted) return;

      setState(() {
        transactions.add(result);
      });

      _showError('Transaction saved successfully.');
    } catch (e) {
      if (!mounted) return;
      _showError('Could not save transaction.');
    }
  }

  // تعديل معاملة
  Future<void> _editTransaction(Transaction transaction) async {
    final result = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddTransactionScreen(existingTransaction: transaction),
      ),
    );

    if (!mounted || result == null) return;

    try {
      await _repository.update(result);

      if (!mounted) return;

      setState(() {
        final index = transactions.indexWhere((t) => t.id == result.id);

        if (index != -1) {
          transactions[index] = result;
        }
      });
    } catch (e) {
      if (!mounted) return;
      _showError('Could not update transaction.');
    }
  }

  // حذف مع إمكانية التراجع
  Future<void> _deleteTransaction(Transaction transaction) async {
    setState(() {
      transactions.removeWhere((t) => t.id == transaction.id);
    });

    try {
      await _repository.delete(transaction.id);

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);

      final snackBarController = messenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          content: Text('${transaction.title} deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              try {
                await _repository.add(transaction);

                if (!mounted) return;

                setState(() {
                  transactions.add(transaction);
                });
              } catch (e) {
                if (!mounted) return;
                _showError('Could not restore transaction.');
              }
            },
          ),
        ),
      );

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          snackBarController.close();
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        transactions.add(transaction);
      });

      _showError('Could not delete transaction.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthTransactions = monthlyTransactions;

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

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF173D35)),
            )
          : errorMessage != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(errorMessage!),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadTransactions,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اختيار الشهر
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _previousMonth,
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Color(0xFF173D35),
                        ),
                      ),

                      Text(
                        DateFormat('MMMM yyyy').format(selectedMonth),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF173D35),
                        ),
                      ),

                      IconButton(
                        onPressed: _nextMonth,
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF173D35),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // بطاقة الرصيد
                  BalanceCard(
                    balance: balance,
                    income: income,
                    expenses: expenses,
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Transactions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173D35),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // حالة القائمة الفارغة
                  if (monthTransactions.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No transactions this month',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // قائمة المعاملات
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: monthTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = monthTransactions[index];

                      return Dismissible(
                        key: ValueKey(transaction.id),
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
                          _deleteTransaction(transaction);
                        },

                        child: Card(
                          color: Colors.white,
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _editTransaction(transaction),
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
        onPressed: isLoading || errorMessage != null ? null : _addTransaction,
        backgroundColor: const Color(0xFF173D35),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
