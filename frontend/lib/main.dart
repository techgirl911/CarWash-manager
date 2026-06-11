import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'utils/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/reservation_provider.dart';
import 'providers/drinks_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LulusCarWashApp());
}

class LulusCarWashApp extends StatelessWidget {
  const LulusCarWashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => DrinksProvider()),
      ],
      child: MaterialApp.router(
        title: "Lulu's Car Wash",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRoutes.router,
      ),
    );
  }
}
