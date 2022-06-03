part of manup;

Future<ManUpStatus> validatePlatformData(
    {required String version, required PlatformData platformData}) async {
  if (!platformData.enabled) {
    return ManUpStatus.disabled;
  }

  try {
    Version currentVersion = Version.parse(version);
    VersionConstraint latestVersion =
        VersionConstraint.parse('>=${platformData.latestVersion}');
    VersionConstraint minVersion =
        VersionConstraint.parse('>=${platformData.minVersion}');
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
