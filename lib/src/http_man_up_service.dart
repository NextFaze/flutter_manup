part of manup;

class HttpManUpService extends ManUpService {
  final String url;
  final Client http;

  HttpManUpService(
    this.url, {
    required this.http,
    String? os,
    PackageInfoProvider packageInfoProvider =
        const DefaultPackageInfoProvider(),
    ConfigStorage storage = const ConfigStorage(),
    ManUpDelegate? delegate,
  }) : super(
          delegate: delegate,
          os: os,
          packageInfoProvider: packageInfoProvider,
          storage: storage,
        );

  Future<Metadata> getMetadata() async {
    try {
      final uri = Uri.parse(this.url);
      var data = await http.get(uri);
      Map<String, dynamic>? json = jsonDecode(data.body);
      return Metadata(data: json);
    } catch (exception) {
      if (kIsWeb) throw exception;
      try {
        var metadata = await readManUpFile();
        return metadata;
      } catch (e) {
        throw ManUpException(exception.toString());
      }
    }
  }

  void close() {
    http.close();
    super.close();
  }
}
