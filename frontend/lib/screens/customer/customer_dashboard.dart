import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';
import '../../utils/routes.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Lulu's Car Wash"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go(AppRoutes.login),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
              Text('2 of 6',
                  style: GoogleFontsFallback.style(
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
      onPressed: () => context.go(AppRoutes.reservation),
      icon: const Icon(Icons.add_circle_outline),
      label: const Text('Book a Reservation'),
    );
  }

  Widget _buildMyReservations(BuildContext context) {
    final reservations = [
      {
        'plate': 'CE 123 AB',
        'service': 'Full Wash',
        'status': 'Pending',
        'time': 'Today, 2:00 PM'
      },
      {
        'plate': 'CE 456 CD',
        'service': 'Basic Wash',
        'status': 'Done',
        'time': 'Yesterday, 10:00 AM'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Reservations', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ...reservations.map((r) => _buildReservationCard(context, r)),
      ],
    );
  }

  Widget _buildReservationCard(BuildContext context, Map<String, String> r) {
    final isPending = r['status'] == 'Pending';
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
                Text(r['plate']!,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${r['service']} • ${r['time']}',
                    style:
                        TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isPending ? AppTheme.warningLight : AppTheme.successLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              r['status']!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isPending ? AppTheme.warning : AppTheme.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Temporary helper to avoid extra import for one text style
class GoogleFontsFallback {
  static TextStyle style(
      {required double fontSize,
      required FontWeight fontWeight,
      required Color color}) {
    return TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color);
  }
}
