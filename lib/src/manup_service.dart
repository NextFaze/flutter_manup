part of mandatory_update;

/// A Function that should return the current operating system
typedef OSGetter = String Function();

class ManUpService {
  final String url;
  final PackageInfoProvider packageInfoProvider;
  Client http = Client();
  // allow overriding of how we get the operating system
  // for testing purposes
  OSGetter os = () => Platform.operatingSystem;

  ManUpService(this.url,
      {this.packageInfoProvider = const DefaultPackageInfoProvider(), this.http, this.os});

  Future<ManUpStatus> validate() async {
    PackageInfo info = await this.packageInfoProvider.getInfo();
    Metadata manupData = await this.getMetadata();

    PlatformData platformData = this.getPlatformData(os(), manupData);

    if (!platformData.enabled) {
      return ManUpStatus.disabled;
    }

    try {
      Version currentVersion = Version.parse(info.version);
      VersionConstraint latestVersion = VersionConstraint.parse('>=${platformData.latestVersion}');
      VersionConstraint minVersion = VersionConstraint.parse('>=${platformData.minVersion}');
      if (latestVersion.allows(currentVersion)) {
        return ManUpStatus.latest;
      } else if (minVersion.allows(currentVersion)) {
        return ManUpStatus.supported;
      }
      return ManUpStatus.unsupported;
    } catch (exception) {
      throw ManUpException(exception.toString());
    }
  }

  @visibleForTesting
  PlatformData getPlatformData(String os, Metadata data) {
    if (os == 'ios') {
      return data.ios;
    } else if (os == 'android') {
      return data.android;
    }
    throw ManUpException('Platform not supported');
  }

  @visibleForTesting
  Future<Metadata> getMetadata() async {
    try {
      var data = await this.http.get(this.url);
      this.http.close();
      PlatformData ios;
      PlatformData android;
      Map<String, dynamic> json = jsonDecode(data.body);

      if (json['ios'] != null) {
        ios = this.parseJson(json['ios']);
      }
      if (json['android'] != null) {
        android = this.parseJson(json['android']);
      }
      return Metadata(android: android, ios: ios);
    } catch (exception) {
      throw ManUpException(exception.toString());
    }
  }

  @visibleForTesting
  PlatformData parseJson(Map<String, dynamic> data) {
    return PlatformData(
        enabled: data['enabled'],
        latestVersion: data['latest'],
        minVersion: data['minimum'],
        updateUrl: data['url']);
  }
}
