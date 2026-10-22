abstract interface class ReminderGateway {
  Future<bool> requestPermission();

  Future<void> cancelAll();

  Future<void> scheduleWeekly({required int weekday, required int hour});

  Future<void> scheduleMonthly({required int day, required int hour});

  Future<void> scheduleOnce({required int id, required DateTime at});
}
