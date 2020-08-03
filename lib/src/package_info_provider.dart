part of manup;

abstract class PackageInfoProvider {
  const PackageInfoProvider();
  Future<PackageInfo> getInfo();
}

class DefaultPackageInfoProvider extends PackageInfoProvider {
  const DefaultPackageInfoProvider() : super();

  Future<PackageInfo> getInfo() {
    return PackageInfo.fromPlatform();
  }
}
