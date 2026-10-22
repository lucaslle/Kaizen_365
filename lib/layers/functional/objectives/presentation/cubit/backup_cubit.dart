import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/use_cases/backup_use_cases.dart';

enum BackupStatus { idle, working, imported, invalidFile, failed }

class BackupCubit extends Cubit<BackupStatus> {
  BackupCubit(this._export, this._import) : super(BackupStatus.idle);

  final ExportBackupUseCase _export;
  final ImportBackupUseCase _import;

  Future<void> export() => _run(() async {
    await _export();
    return BackupStatus.idle;
  });

  Future<void> import() => _run(() async => await _import() ? BackupStatus.imported : BackupStatus.idle);

  Future<void> _run(Future<BackupStatus> Function() action) async {
    emit(BackupStatus.working);
    try {
      emit(await action());
    } on FormatException {
      emit(BackupStatus.invalidFile);
    } catch (error, stackTrace) {
      debugPrint('Backup failed: $error\n$stackTrace');
      emit(BackupStatus.failed);
    }
  }
}
