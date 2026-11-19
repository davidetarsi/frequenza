/// A bounded absolute HTTPS URL, with a host and no embedded credentials.
/// Shared by remote station data, saved records and external web links.
Uri? httpsUri(String? value) {
  if (value == null || value.length > 8192) return null;
  try {
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        uri.scheme != 'https' ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        RegExp(r'[\s\x00-\x1F\x7F]').hasMatch(Uri.decodeComponent(uri.host)) ||
        uri.userInfo.isNotEmpty ||
        (uri.hasPort && (uri.port <= 0 || uri.port > 65535))) {
      return null;
    }
    return uri;
  } on FormatException {
    return null;
  }
}
