abstract interface class ReminderGateway {
  Future<bool> requestPermission();

  Future<void> cancelAll();

  Future<void> scheduleWeekly({required int weekday, required int minutes});

  Future<void> scheduleMonthly({required int day, required int minutes});

  Future<void> scheduleOnce({required int id, required DateTime at});

  /// Emits each time the user opens the app from a reminder.
  Stream<void> watchReminderTaps();
}
