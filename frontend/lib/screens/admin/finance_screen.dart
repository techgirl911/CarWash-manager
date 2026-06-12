import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';
import '../../utils/routes.dart';
import '../../services/finance_service.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final _washIncomeController = TextEditingController();
  final _drinkIncomeController = TextEditingController();
  final _expensesController = TextEditingController();

  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _washIncomeController.dispose();
    _drinkIncomeController.dispose();
    _expensesController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    final result = await FinanceService.getHistory();

    if (result['success']) {
      setState(() {
        _history = List<Map<String, dynamic>>.from(result['data']);
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
      });
    }
  }

  Future<void> _saveDailyEntry() async {
    final wash = double.tryParse(_washIncomeController.text) ?? 0;
    final drinks = double.tryParse(_drinkIncomeController.text) ?? 0;
    final expenses = double.tryParse(_expensesController.text) ?? 0;

    if (wash == 0 && drinks == 0 && expenses == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one amount.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final result = await FinanceService.saveEntry(
      washIncome: wash,
      drinkIncome: drinks,
      expenses: expenses,
    );

    setState(() => _isSaving = false);

    if (result['success']) {
      _washIncomeController.clear();
      _drinkIncomeController.clear();
      _expensesController.clear();
      _loadHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Entry saved!")),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayProfit = _history.isNotEmpty
        ? double.parse(_history.first['profit'].toString()).toInt()
        : 0;
    final weekTotal = _history.fold<int>(0,
        (sum, item) => sum + double.parse(item['profit'].toString()).toInt());

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.adminDashboard),
        ),
        title: const Text('Finance'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadHistory),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow(todayProfit, weekTotal),
                  const SizedBox(height: 24),
                  _buildEntryForm(),
                  const SizedBox(height: 24),
                  Text('History',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  if (_history.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text('No entries yet.',
                            style: TextStyle(color: AppTheme.textSecondary)),
                      ),
                    )
                  else
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
          Text("Add to Today's Earnings",
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Values add to existing totals for today',
              style: Theme.of(context).textTheme.bodySmall),
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
            onPressed: _isSaving ? null : _saveDailyEntry,
            icon: _isSaving
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save_outlined),
            label: Text(_isSaving ? 'Saving...' : 'Save Entry'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> entry) {
    final date = DateTime.parse(entry['entry_date']);
    final formattedDate = '${date.day}/${date.month}/${date.year}';
    final profit = double.parse(entry['profit'].toString()).toInt();
    final wash = double.parse(entry['wash_income'].toString()).toInt();
    final drinks = double.parse(entry['drink_income'].toString()).toInt();
    final expenses = double.parse(entry['expenses'].toString()).toInt();

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
              Text(formattedDate,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.successLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('+$profit F',
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
              _buildMiniStat('Wash', '$wash F', AppTheme.primary),
              const SizedBox(width: 16),
              _buildMiniStat('Drinks', '$drinks F', AppTheme.warning),
              const SizedBox(width: 16),
              _buildMiniStat('Expenses', '$expenses F', AppTheme.error),
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
