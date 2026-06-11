import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';
import '../../utils/routes.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final _washIncomeController = TextEditingController();
  final _drinkIncomeController = TextEditingController();
  final _expensesController = TextEditingController();

  // Temporary local data — will come from backend later
  final List<Map<String, dynamic>> _history = [
    {
      'date': 'Jun 10, 2026',
      'wash': 18000,
      'drinks': 4500,
      'expenses': 2000,
      'profit': 20500
    },
    {
      'date': 'Jun 9, 2026',
      'wash': 15000,
      'drinks': 3200,
      'expenses': 1500,
      'profit': 16700
    },
    {
      'date': 'Jun 8, 2026',
      'wash': 21000,
      'drinks': 5100,
      'expenses': 2500,
      'profit': 23600
    },
  ];

  @override
  void dispose() {
    _washIncomeController.dispose();
    _drinkIncomeController.dispose();
    _expensesController.dispose();
    super.dispose();
  }

  void _saveDailyEntry() {
    final wash = double.tryParse(_washIncomeController.text) ?? 0;
    final drinks = double.tryParse(_drinkIncomeController.text) ?? 0;
    final expenses = double.tryParse(_expensesController.text) ?? 0;
    final profit = wash + drinks - expenses;

    if (wash == 0 && drinks == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one amount.')),
      );
      return;
    }

    setState(() {
      _history.insert(0, {
        'date': 'Today',
        'wash': wash.toInt(),
        'drinks': drinks.toInt(),
        'expenses': expenses.toInt(),
        'profit': profit.toInt(),
      });
      _washIncomeController.clear();
      _drinkIncomeController.clear();
      _expensesController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Today's entry saved!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayProfit = _history.isNotEmpty ? _history.first['profit'] : 0;
    final weekTotal =
        _history.fold<int>(0, (sum, item) => sum + (item['profit'] as int));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.adminDashboard),
        ),
        title: const Text('Finance'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow(todayProfit, weekTotal),
            const SizedBox(height: 24),
            _buildEntryForm(),
            const SizedBox(height: 24),
            Text('History', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ..._history.map((entry) => _buildHistoryCard(entry)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(int todayProfit, int weekTotal) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            label: "Today's Profit",
            value: '$todayProfit F',
            icon: Icons.trending_up,
            color: AppTheme.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            label: 'Recent Total',
            value: '$weekTotal F',
            icon: Icons.account_balance_wallet_outlined,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      {required String label,
      required String value,
      required IconData icon,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Text(label,
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildEntryForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Log Today's Earnings",
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextFormField(
            controller: _washIncomeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Car wash income (F)',
              prefixIcon: Icon(Icons.local_car_wash_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _drinkIncomeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Drinks income (F)',
              prefixIcon: Icon(Icons.local_drink_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _expensesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Expenses (F)',
              prefixIcon: Icon(Icons.money_off_outlined),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _saveDailyEntry,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save Entry'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(entry['date'],
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.successLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('+${entry['profit']} F',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.success)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildMiniStat('Wash', '${entry['wash']} F', AppTheme.primary),
              const SizedBox(width: 16),
              _buildMiniStat(
                  'Drinks', '${entry['drinks']} F', AppTheme.warning),
              const SizedBox(width: 16),
              _buildMiniStat(
                  'Expenses', '${entry['expenses']} F', AppTheme.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}
