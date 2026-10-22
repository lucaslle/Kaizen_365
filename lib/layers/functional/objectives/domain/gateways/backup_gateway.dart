abstract interface class BackupGateway {
  /// Writes every objective, review and setting to a file and opens the phone's share sheet.
  Future<void> export();

  /// Replaces all data with a backup the user picks. Returns false when they cancel.
  /// Throws a [FormatException] when the file is not a Kaizen 365 backup.
  Future<bool> import();
}
