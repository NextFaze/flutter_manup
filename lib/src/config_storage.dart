part of manup;

class ConfigStorage {
  const ConfigStorage();
  static const String _manUpFile = "man_up_config.json";
  //
  Future<bool> storeFile(
      {String filename = _manUpFile, required String fileData}) {
    return getApplicationDocumentsDirectory().then((directory) {
      final File file = File('${directory.path}/$filename');
      return file.writeAsString(fileData).then((_) => Future.value(true));
    });
  }

  Future<String> readFile({String filename = _manUpFile}) async {
    return getApplicationDocumentsDirectory().then((directory) {
      final File file = File('${directory.path}/$filename');
      return file.exists().then((isExist) =>
          isExist ? file.readAsString() : throw Exception("file not exist"));
    });
  }
}
