import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../technical/localization/app_locale.dart';
import '../../../../technical/theme/app_text.dart';
import '../../../../technical/theme/widgets/app_button.dart';
import '../../../../technical/theme/widgets/confirm_dialog.dart';
import '../../../../technical/theme/widgets/toast.dart';
import '../cubit/backup_cubit.dart';

/// Export and restore of all data, shown in the profile screen.
class BackupSection extends StatelessWidget {
  const BackupSection({super.key, required this.onImported});

  final VoidCallback onImported;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => BackupCubit(GetIt.I(), GetIt.I()),
    child: BlocConsumer<BackupCubit, BackupStatus>(
      listener: (context, status) {
        final message = switch (status) {
          BackupStatus.imported => AppLocale.backupImported,
          BackupStatus.invalidFile => AppLocale.backupInvalid,
          BackupStatus.failed => AppLocale.errorSaving,
          _ => null,
        };
        if (status == BackupStatus.imported) onImported();
        if (message != null) showToast(context, message.getString(context), isError: status != BackupStatus.imported);
      },
      builder: (context, status) {
        final cubit = context.read<BackupCubit>();
        final isWorking = status == BackupStatus.working;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Text(AppLocale.backupLabel.getString(context).toUpperCase(), style: context.text.overline),
            Text(AppLocale.backupHelp.getString(context), style: context.text.caption),
            AppButton(
              label: AppLocale.backupExport.getString(context),
              icon: Symbols.ios_share_rounded,
              variant: AppButtonVariant.dark,
              height: 52,
              onPressed: isWorking ? null : cubit.export,
            ),
            AppButton(
              label: AppLocale.backupImport.getString(context),
              icon: Symbols.download_rounded,
              variant: AppButtonVariant.outline,
              height: 52,
              onPressed: isWorking ? null : () => _confirmImport(context, cubit),
            ),
          ],
        );
      },
    ),
  );

  Future<void> _confirmImport(BuildContext context, BackupCubit cubit) async {
    final isConfirmed = await confirmDestructive(
      context,
      title: AppLocale.backupImportTitle.getString(context),
      body: AppLocale.backupImportBody.getString(context),
      confirmLabel: AppLocale.backupImportConfirm.getString(context),
      cancelLabel: AppLocale.cancel.getString(context),
    );
    if (isConfirmed) await cubit.import();
  }
}
