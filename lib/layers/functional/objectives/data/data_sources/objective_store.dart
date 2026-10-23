/// Where the objectives are kept as JSON: a file on the phone, or the browser storage for the web demo.
abstract interface class ObjectiveStore {
  Future<List<Map<String, dynamic>>> read();

  Future<void> write(List<Map<String, dynamic>> objectives);
}
