class Constants {
  // ── API ───────────────────────────────────────────────────
  // During development your Node.js backend will run locally
  // We'll update this to a real URL when we deploy
  static const String baseUrl = 'http://localhost:3000/api';

  // ── Auth endpoints ────────────────────────────────────────
  static const String loginUrl = '$baseUrl/auth/login';
  static const String registerUrl = '$baseUrl/auth/register';

  // ── Reservations ──────────────────────────────────────────
  static const String reservationsUrl = '$baseUrl/reservations';

  // ── Spaces / Bays ─────────────────────────────────────────
  static const String spacesUrl = '$baseUrl/spaces';

  // ── Finance ───────────────────────────────────────────────
  static const String financeUrl = '$baseUrl/finance';

  // ── Drinks ───────────────────────────────────────────────
  static const String drinksUrl = '$baseUrl/drinks';
  static const String lowStockUrl = '$baseUrl/drinks/low-stock';

  // ── Shared Preferences Keys ───────────────────────────────
  // These are the keys we use to store data locally on the device
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String roleKey = 'user_role';

  // ── App-wide values ───────────────────────────────────────
  static const String appName = "Lulu's Car Wash";
  static const int lowStockAlert = 5; // notify when drinks stock ≤ 5
  static const int totalBays =
      6; // total car wash bays (change to match real number)
}
