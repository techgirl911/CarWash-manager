import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';
import '../../utils/routes.dart';
import '../../services/auth_service.dart';
import '../../services/spaces_service.dart';
import '../../services/finance_service.dart';
import '../../services/reservation_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _occupiedBays = 0;
  int _emptyBays = 0;
  double _todayProfit = 0;
  int _todayReservations = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final spacesResult = await SpacesService.getBays();
    final financeResult = await FinanceService.getToday();
    final reservationCount = await ReservationService.getTodayCount();

    if (spacesResult['success']) {
      final bays = List<Map<String, dynamic>>.from(spacesResult['data']);
      _occupiedBays = bays.where((b) => b['status'] == 'occupied').length;
      _emptyBays = bays.where((b) => b['status'] == 'empty').length;
    }

    if (financeResult['success'] && financeResult['data'] != null) {
      _todayProfit =
          double.tryParse(financeResult['data']['profit'].toString()) ?? 0;
    }

    _todayReservations = reservationCount;

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Lulu's Car Wash"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcome(context),
                  const SizedBox(height: 24),
                  _buildStatsRow(context),
                  const SizedBox(height: 24),
                  _buildMenuGrid(context),
                ],
              ),
            ),
    );
  }

  Widget _buildWelcome(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Good morning, Admin 👋',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text('Here is what is happening today.',
            style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's Overview",
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(context,
                label: 'Cars in Wash',
                value: '$_occupiedBays',
                icon: Icons.directions_car,
                color: AppTheme.primary),
            _buildStatCard(context,
                label: 'Empty Bays',
                value: '$_emptyBays',
                icon: Icons.garage_outlined,
                color: AppTheme.success),
            _buildStatCard(context,
                label: "Today's Revenue",
                value: '${_todayProfit.toInt()} F',
                icon: Icons.payments_outlined,
                color: AppTheme.warning),
            _buildStatCard(context,
                label: 'Reservations',
                value: '$_todayReservations',
                icon: Icons.calendar_today_outlined,
                color: AppTheme.accent),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final items = [
      {
        'label': 'Manage Bays',
        'subtitle': 'Track car spaces',
        'icon': Icons.garage_outlined,
        'color': AppTheme.primary,
        'route': AppRoutes.spaces,
      },
      {
        'label': 'Finance',
        'subtitle': 'Revenue & profits',
        'icon': Icons.bar_chart_outlined,
        'color': AppTheme.success,
        'route': AppRoutes.finance,
      },
      {
        'label': 'Drinks',
        'subtitle': 'Inventory & sales',
        'icon': Icons.local_drink_outlined,
        'color': AppTheme.warning,
        'route': AppRoutes.drinks,
      },
      {
        'label': 'Reservations',
        'subtitle': 'All bookings',
        'icon': Icons.calendar_month_outlined,
        'color': AppTheme.accent,
        'route': AppRoutes.reservationsAdmin,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Manage', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: items.map((item) {
            return GestureDetector(
              onTap: () async {
                await context.push(item['route'] as String);
                _loadData();
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item['icon'] as IconData,
                          color: item['color'] as Color, size: 24),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['label'] as String,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary)),
                        Text(item['subtitle'] as String,
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
