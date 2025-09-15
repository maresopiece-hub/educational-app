abstract class ShareService {
  Future<void> share(String path);
}

class DefaultShareService implements ShareService {
  @override
  Future<void> share(String path) async {
    // Default placeholder. To enable real platform sharing:
    // 1) run `flutter pub add share_plus` or add `share_plus` to pubspec.yaml
    // 2) implement this method to call Share.share or Share.shareXFiles from share_plus
    // For now this will throw to make the absence explicit to callers.
    throw UnimplementedError('DefaultShareService not implemented. Add share_plus and implement DefaultShareService.share.');
  }
}
