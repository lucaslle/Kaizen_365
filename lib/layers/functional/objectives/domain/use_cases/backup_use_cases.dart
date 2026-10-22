import '../gateways/backup_gateway.dart';

class ExportBackupUseCase {
  ExportBackupUseCase(this._gateway);

  final BackupGateway _gateway;

  Future<void> call() => _gateway.export();
}

class ImportBackupUseCase {
  ImportBackupUseCase(this._gateway);

  final BackupGateway _gateway;

  Future<bool> call() => _gateway.import();
}
