import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';
import '../../utils/routes.dart';

class SpacesScreen extends StatefulWidget {
  const SpacesScreen({super.key});

  @override
  State<SpacesScreen> createState() => _SpacesScreenState();
}

class _SpacesScreenState extends State<SpacesScreen> {
  // Temporary local data — will come from backend later
  final List<Map<String, dynamic>> _bays = [
    {
      'number': 1,
      'status': 'occupied',
      'plate': 'CE 123 AB',
      'service': 'Full Wash'
    },
    {
      'number': 2,
      'status': 'occupied',
      'plate': 'CE 456 CD',
      'service': 'Basic Wash'
    },
    {'number': 3, 'status': 'empty', 'plate': null, 'service': null},
    {
      'number': 4,
      'status': 'occupied',
      'plate': 'CE 789 EF',
      'service': 'Full Wash'
    },
    {'number': 5, 'status': 'empty', 'plate': null, 'service': null},
    {
      'number': 6,
      'status': 'occupied',
      'plate': 'CE 321 GH',
      'service': 'Premium Wash'
    },
  ];

  void _toggleBay(int index) {
    setState(() {
      if (_bays[index]['status'] == 'empty') {
        _bays[index]['status'] = 'occupied';
        _bays[index]['plate'] = 'New Car';
        _bays[index]['service'] = 'Basic Wash';
      } else {
        _bays[index]['status'] = 'empty';
        _bays[index]['plate'] = null;
        _bays[index]['service'] = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final occupied = _bays.where((b) => b['status'] == 'occupied').length;
    final empty = _bays.length - occupied;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.adminDashboard),
        ),
        title: const Text('Manage Bays'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow(occupied, empty),
            const SizedBox(height: 24),
            Text('All Bays', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Tap a bay to toggle its status',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _bays.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) => _buildBayCard(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(int occupied, int empty) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            label: 'Occupied',
            value: '$occupied',
            icon: Icons.directions_car,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            label: 'Empty',
            value: '$empty',
            icon: Icons.garage_outlined,
            color: AppTheme.success,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700)),
              Text(label,
                  style:
                      TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBayCard(int index) {
    final bay = _bays[index];
    final isOccupied = bay['status'] == 'occupied';

    return GestureDetector(
      onTap: () => _toggleBay(index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isOccupied ? AppTheme.primaryLight : AppTheme.successLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOccupied ? AppTheme.primary : AppTheme.success,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bay ${bay['number']}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                Icon(
                  isOccupied
                      ? Icons.directions_car
                      : Icons.check_circle_outline,
                  color: isOccupied ? AppTheme.primary : AppTheme.success,
                  size: 22,
                ),
              ],
            ),
            if (isOccupied) ...[
              Text(bay['plate'],
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              Text(bay['service'],
                  style:
                      TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ] else
              Text('Available',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.success)),
          ],
        ),
      ),
    );
  }
}
