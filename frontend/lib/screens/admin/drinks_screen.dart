import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';
import '../../utils/routes.dart';
import '../../services/drinks_service.dart';

class DrinksScreen extends StatefulWidget {
  const DrinksScreen({super.key});

  @override
  State<DrinksScreen> createState() => _DrinksScreenState();
}

class _DrinksScreenState extends State<DrinksScreen> {
  List<Map<String, dynamic>> _drinks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDrinks();
  }

  Future<void> _loadDrinks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await DrinksService.getDrinks();

    if (result['success']) {
      setState(() {
        _drinks = List<Map<String, dynamic>>.from(result['data']);
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
      });
    }
  }

  Future<void> _adjustStock(int index, int delta) async {
    final drink = _drinks[index];

    final result =
        await DrinksService.adjustStock(drinkId: drink['id'], delta: delta);

    if (result['success']) {
      _loadDrinks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  void _showAddDrinkDialog() {
    final nameController = TextEditingController();
    final stockController = TextEditingController();
    final priceController = TextEditingController();
    final thresholdController = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Drink'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Drink name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Initial stock'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Price per unit (F)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: thresholdController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Low stock alert level'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;

              final result = await DrinksService.addDrink(
                name: nameController.text,
                stock: int.tryParse(stockController.text) ?? 0,
                price: double.tryParse(priceController.text) ?? 0,
                threshold: int.tryParse(thresholdController.text) ?? 10,
              );

              if (context.mounted) Navigator.pop(context);

              if (result['success']) {
                _loadDrinks();
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'])),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lowStockItems =
        _drinks.where((d) => d['stock'] <= d['low_stock_threshold']).toList();
    final totalValue = _drinks.fold<double>(
        0,
        (sum, d) =>
            sum +
            (d['stock'] as int) * double.parse(d['unit_price'].toString()));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.adminDashboard),
        ),
        title: const Text('Drinks Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showAddDrinkDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryRow(
                          totalValue.toInt(), lowStockItems.length),
                      if (lowStockItems.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildLowStockAlert(lowStockItems),
                      ],
                      const SizedBox(height: 24),
                      Text('All Drinks',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      if (_drinks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text('No drinks yet. Tap + to add one.',
                                style:
                                    TextStyle(color: AppTheme.textSecondary)),
                          ),
                        )
                      else
                        ..._drinks
                            .asMap()
                            .entries
                            .map((e) => _buildDrinkCard(e.key, e.value)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryRow(int totalValue, int lowStockCount) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            label: 'Stock Value',
            value: '$totalValue F',
            icon: Icons.inventory_2_outlined,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            label: 'Low Stock Items',
            value: '$lowStockCount',
            icon: Icons.warning_amber_outlined,
            color: lowStockCount > 0 ? AppTheme.error : AppTheme.success,
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

  Widget _buildLowStockAlert(List<Map<String, dynamic>> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active_outlined,
              color: AppTheme.error, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Low Stock Alert',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.error)),
                const SizedBox(height: 2),
                Text(
                  '${items.map((e) => e['name']).join(', ')} running low',
                  style: TextStyle(fontSize: 12, color: AppTheme.error),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrinkCard(int index, Map<String, dynamic> drink) {
    final isLow = drink['stock'] <= drink['low_stock_threshold'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLow ? AppTheme.error.withOpacity(0.4) : AppTheme.border,
          width: isLow ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_drink_outlined,
                color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(drink['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${drink['unit_price']} F per unit',
                    style:
                        TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                if (isLow) ...[
                  const SizedBox(height: 4),
                  Text('Low stock!',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.error)),
                ],
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                color: AppTheme.error,
                onPressed: () => _adjustStock(index, -1),
              ),
              Text('${drink['stock']}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: AppTheme.success,
                onPressed: () => _adjustStock(index, 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
