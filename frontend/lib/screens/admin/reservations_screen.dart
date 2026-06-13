import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';
import '../../utils/routes.dart';
import '../../services/reservation_service.dart';
import '../../services/spaces_service.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  List<Map<String, dynamic>> _reservations = [];
  List<Map<String, dynamic>> _bays = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final reservationsResult = await ReservationService.getAllReservations();
    final spacesResult = await SpacesService.getBays();

    if (reservationsResult['success']) {
      _reservations =
          List<Map<String, dynamic>>.from(reservationsResult['data']);
    }
    if (spacesResult['success']) {
      _bays = List<Map<String, dynamic>>.from(spacesResult['data']);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _markActive(Map<String, dynamic> reservation) async {
    final emptyBays = _bays.where((b) => b['status'] == 'empty').toList();

    if (emptyBays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No empty bays available!')),
      );
      return;
    }

    final selectedBay = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Assign a Bay'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: emptyBays.map((bay) {
            return ListTile(
              leading: const Icon(Icons.garage_outlined),
              title: Text('Bay ${bay['bay_number']}'),
              onTap: () => Navigator.pop(context, bay),
            );
          }).toList(),
        ),
      ),
    );

    if (selectedBay == null) return;

    final result = await ReservationService.updateStatusWithBay(
      reservationId: reservation['id'],
      status: 'active',
      bayId: selectedBay['id'],
    );

    if (result['success']) {
      _loadData();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to assign bay')),
      );
    }
  }

  Future<void> _markDone(Map<String, dynamic> reservation) async {
    final result = await ReservationService.updateStatusWithBay(
      reservationId: reservation['id'],
      status: 'done',
      bayId: null,
    );

    if (result['success']) {
      _loadData();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to update')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.adminDashboard),
        ),
        title: const Text('Reservations'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reservations.isEmpty
              ? Center(
                  child: Text('No reservations yet.',
                      style: TextStyle(color: AppTheme.textSecondary)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _reservations.length,
                  itemBuilder: (context, index) =>
                      _buildCard(_reservations[index]),
                ),
    );
  }

  Widget _buildCard(Map<String, dynamic> r) {
    final status = r['status'] as String;
    final time = DateTime.parse(r['reservation_time']);
    final formattedTime =
        '${time.day}/${time.month}/${time.year} • ${time.hour}:${time.minute.toString().padLeft(2, '0')}';

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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r['car_plate'],
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    Text(r['customer_name'] ?? '',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
          const SizedBox(height: 8),
          Text('${r['service_type']} • $formattedTime • ${r['price']} F',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          if (status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _markActive(r),
                    child: const Text('Start (Assign Bay)'),
                  ),
                ),
              ],
            ),
          ],
          if (status == 'active') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success),
                    onPressed: () => _markDone(r),
                    child: const Text('Mark as Done'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
