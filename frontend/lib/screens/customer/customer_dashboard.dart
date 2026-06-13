import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';
import '../../utils/routes.dart';
import '../../services/auth_service.dart';
import '../../services/reservation_service.dart';
import '../../services/spaces_service.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  List<Map<String, dynamic>> _reservations = [];
  int _emptyBays = 0;
  int _totalBays = 6;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final reservationsResult = await ReservationService.getMyReservations();
    final spacesResult = await SpacesService.getBays();

    if (reservationsResult['success']) {
      _reservations =
          List<Map<String, dynamic>>.from(reservationsResult['data']);
    }

    if (spacesResult['success']) {
      final bays = List<Map<String, dynamic>>.from(spacesResult['data']);
      _totalBays = bays.length;
      _emptyBays = bays.where((b) => b['status'] == 'empty').length;
    }

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
                  _buildAvailability(context),
                  const SizedBox(height: 24),
                  _buildBookButton(context),
                  const SizedBox(height: 24),
                  _buildMyReservations(context),
                ],
              ),
            ),
    );
  }

  Widget _buildWelcome(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome back 👋', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text('Ready to get your car washed?',
            style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildAvailability(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Available Bays',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text('$_emptyBays of $_totalBays',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const SizedBox(height: 2),
              const Text('bays free right now',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                const Icon(Icons.local_car_wash, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        await context.push(AppRoutes.reservation);
        _loadData(); // Refresh when coming back
      },
      icon: const Icon(Icons.add_circle_outline),
      label: const Text('Book a Reservation'),
    );
  }

  Widget _buildMyReservations(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Reservations', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        if (_reservations.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text('No reservations yet. Book one above!',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ),
          )
        else
          ..._reservations.map((r) => _buildReservationCard(context, r)),
      ],
    );
  }

  Widget _buildReservationCard(BuildContext context, Map<String, dynamic> r) {
    final status = r['status'] as String;
    final isPending = status == 'pending';
    final time = DateTime.parse(r['reservation_time']);
    final formattedTime =
        '${time.day}/${time.month} • ${time.hour}:${time.minute.toString().padLeft(2, '0')}';

    Color statusColor;
    Color statusBg;
    switch (status) {
      case 'done':
        statusColor = AppTheme.success;
        statusBg = AppTheme.successLight;
        break;
      case 'active':
        statusColor = AppTheme.primary;
        statusBg = AppTheme.primaryLight;
        break;
      case 'cancelled':
        statusColor = AppTheme.error;
        statusBg = AppTheme.errorLight;
        break;
      default:
        statusColor = AppTheme.warning;
        statusBg = AppTheme.warningLight;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.directions_car,
                color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r['car_plate'],
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${r['service_type']} • $formattedTime',
                    style:
                        TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status[0].toUpperCase() + status.substring(1),
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor),
            ),
          ),
        ],
      ),
    );
  }
}
