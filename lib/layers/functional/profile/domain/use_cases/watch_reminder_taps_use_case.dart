import '../gateways/reminder_gateway.dart';

class WatchReminderTapsUseCase {
  WatchReminderTapsUseCase(this._gateway);

  final ReminderGateway _gateway;

  Stream<void> call() => _gateway.watchReminderTaps();
}
