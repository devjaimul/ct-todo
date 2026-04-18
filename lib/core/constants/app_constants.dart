/// Application-wide constants, validators, and shared preference keys.
class AppConstants {
  AppConstants._();

  // ── App Info ───────────────────────────────────────────────────────────
  static const String appName = 'CT Todo';

  // ── SharedPreferences Keys ─────────────────────────────────────────────
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyCachedTodos = 'cached_todos';
  static const String keyPendingOps = 'pending_operations';

  // ── Pagination ─────────────────────────────────────────────────────────
  static const int pageSize = 10;

  // ── Validators ─────────────────────────────────────────────────────────
  static final RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+\-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  static bool isValidEmail(String value) => emailRegex.hasMatch(value);

  static bool isValidPassword(String value) => passwordRegex.hasMatch(value);

  // ── Todo Statuses ──────────────────────────────────────────────────────
  static const String statusPending = 'pending';
  static const String statusInProgress = 'in_progress';
  static const String statusCancelled = 'cancelled';

  static const List<String> todoStatuses = [
    statusPending,
    statusInProgress,
    statusCancelled,
  ];

  static String statusLabel(String status) {
    switch (status) {
      case statusPending:
        return 'Pending';
      case statusInProgress:
        return 'In Progress';
      case statusCancelled:
        return 'Cancelled';
      default:
        return status;
    }
  }
}
