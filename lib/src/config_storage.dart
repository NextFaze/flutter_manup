part of manup;

class ConfigStorage {
  static const String _manupFile = "manup_config.json";
  //
  Future<bool> storeFile({String filename = _manupFile, String fileData}) {
    return getApplicationDocumentsDirectory().then((directory) {
      final File file = File('${directory.path}/$filename');
      return file.writeAsString(fileData).then((_) => Future.value(true));
    });
  }

  Future<String> readfile({String filename = _manupFile}) {
    return getApplicationDocumentsDirectory().then((directory) {
      final File file = File('${directory.path}/$filename');
      return file.exists().then((isExist) =>
          isExist ? file.readAsString() : throw Exception("file not exist"));
    });
  }
}
