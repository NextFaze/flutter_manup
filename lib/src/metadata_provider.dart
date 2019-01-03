part of mandatory_update;

abstract class MetadataProvider {
  Future<Metadata> getMetadata();
}

class HttpMetadataProvider extends MetadataProvider {
  Future<Metadata> getMetadata() {}
}
