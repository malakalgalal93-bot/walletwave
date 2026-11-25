import 'package:flutter/material.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? existingTransaction;

  const AddTransactionScreen({super.key, this.existingTransaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _amountController;

  final List<String> categories = [
    'Food',
    'Bills',
    'Transport',
    'Shopping',
    'Salary',
    'Work',
    'Gift',
    'Other',
  ];

  late String selectedCategory;
  late bool isExpense;
  late DateTime selectedDate;

  bool get isEditing => widget.existingTransaction != null;

  @override
  void initState() {
    super.initState();

    final transaction = widget.existingTransaction;

    _titleController = TextEditingController(text: transaction?.title ?? '');

    _amountController = TextEditingController(
      text: transaction?.amount.toString() ?? '',
    );

    selectedCategory = transaction?.category ?? 'Food';
    isExpense = transaction?.isExpense ?? true;
    selectedDate = transaction?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newTransaction = Transaction(
      id: widget.existingTransaction?.id,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      category: selectedCategory,
      date: selectedDate,
      isExpense: isExpense,
    );

    Navigator.pop(context, newTransaction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F4),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6F4),
        title: Text(
          isEditing ? 'Edit Transaction' : 'Add Transaction',
          style: const TextStyle(
            color: Color(0xFF173D35),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF173D35)),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transaction Title',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter transaction title',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Amount',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                  prefixText: '₹ ',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Amount is required';
                  }

                  final amount = double.tryParse(value.trim());

                  if (amount == null) {
                    return 'Enter a valid number';
                  }

                  if (amount <= 0) {
                    return 'Amount must be greater than zero';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCategory = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Transaction Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(isExpense ? 'Expense' : 'Income'),
                subtitle: const Text('Turn on for expense, off for income'),
                value: isExpense,
                activeThumbColor: const Color(0xFF173D35),
                onChanged: (value) {
                  setState(() {
                    isExpense = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              const Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 8),

              OutlinedButton.icon(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF173D35),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF173D35),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Update Transaction' : 'Save Transaction',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
