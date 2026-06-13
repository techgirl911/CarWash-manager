import 'package:frontend/screens/admin/admin_dashboard.dart';
import 'package:frontend/screens/admin/drinks_screen.dart';
import 'package:frontend/screens/admin/finance_screen.dart';
import 'package:frontend/screens/admin/spaces_screen.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/auth/register_screen.dart';
import 'package:frontend/screens/customer/customer_dashboard.dart';
import 'package:frontend/screens/customer/reservation_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import '../screens/admin/reservations_screen.dart';

class AppRoutes {
  // ── Route names ───────────────────────────────────────────
  static const String login = '/';
  static const String register = '/register';
  static const String adminDashboard = '/admin/dashboard';
  static const String spaces = '/admin/spaces';
  static const String finance = '/admin/finance';
  static const String drinks = '/admin/drinks';
  static const String customerDashboard = '/customer/dashboard';
  static const String reservation = '/customer/reservation';
  static const String reservationsAdmin = '/admin/reservations';
  // ── Router (screens will be added as we build them) ───────
  static final GoRouter router = GoRouter(
    initialLocation: login,
    redirect: _authGuard,
    routes: [
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) =>
            const RegisterScreen(), // Placeholder for the registration screen
      ),
      GoRoute(
        path: adminDashboard,
        name: 'adminDashboard',
        builder: (context, state) =>
            const AdminDashboard(), // Placeholder for the admin dashboard screen
      ),
      GoRoute(
        path: spaces,
        name: 'spaces',
        builder: (context, state) =>
            const SpacesScreen(), // Placeholder for the spaces management screen
      ),
      GoRoute(
        path: finance,
        name: 'finance',
        builder: (context, state) => const FinanceScreen(),
      ),
      GoRoute(
        path: drinks,
        name: 'drinks',
        builder: (context, state) => const DrinksScreen(),
      ),
      GoRoute(
          path: customerDashboard,
          name: 'customerDashboard',
          builder: (context, state) => const CustomerDashboard()),
      GoRoute(
        path: reservation,
        name: 'reservation',
        builder: (context, state) => const ReservationScreen(),
      ),
      GoRoute(
        path: reservationsAdmin,
        name: 'reservationsAdmin',
        builder: (context, state) => const ReservationsScreen(),
      ),
    ],
  );

  // ── Auth Guard ────────────────────────────────────────────
  static Future<String?> _authGuard(
      BuildContext context, GoRouterState state) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(Constants.tokenKey);
    final role = prefs.getString(Constants.roleKey);

    final isOnAuthPage =
        state.matchedLocation == login || state.matchedLocation == register;

    if (token == null && !isOnAuthPage) return login;

    if (token != null && isOnAuthPage) {
      return role == 'admin' ? adminDashboard : customerDashboard;
    }

    if (token != null &&
        role == 'customer' &&
        state.matchedLocation.startsWith('/admin')) {
      return customerDashboard;
    }

    return null;
  }
}
