part of mandatory_update;

class ManUpService {
  final MetadataProvider metadata;
  final PackageInfoProvider packageInfoProvider;

  ManUpService(this.metadata, {this.packageInfoProvider = const DefaultPackageInfoProvider()});

  Future<ManUpStatus> checkVersion() async {
    PackageInfo info = await this.packageInfoProvider.getInfo();
    Metadata manupData = await this.metadata.getMetadata();

    PlatformData platformData = (Platform.isIOS) ? manupData.ios : manupData.android;

    if (!platformData.enabled) {
      return ManUpStatus.disabled;
    }

    Version currentVersion = Version.parse(info.version);
    Version latestVersion = Version.parse(platformData.maxVersion);
    Version minVersion = Version.parse('>=${platformData.minVersion}');

    if (latestVersion.allows(currentVersion)) {
      return ManUpStatus.latest;
    } else if (minVersion.allows(currentVersion)) {
      return ManUpStatus.supported;
    }
    return ManUpStatus.unsupported;
  }
}
