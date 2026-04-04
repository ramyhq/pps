Map<String, String> parseSetCookieToPairs(String setCookie) {
  final firstPart = setCookie.split(';').first.trim();
  final eqIndex = firstPart.indexOf('=');
  if (eqIndex <= 0) {
    return const <String, String>{};
  }
  final name = firstPart.substring(0, eqIndex).trim();
  final value = firstPart.substring(eqIndex + 1).trim();
  if (name.isEmpty) {
    return const <String, String>{};
  }
  return <String, String>{name: value};
}

Map<String, String> parseCookieHeaderToPairs(String cookieHeader) {
  final parts = cookieHeader.split(';');
  final map = <String, String>{};
  for (final part in parts) {
    final trimmed = part.trim();
    if (trimmed.isEmpty) {
      continue;
    }
    final eqIndex = trimmed.indexOf('=');
    if (eqIndex <= 0) {
      continue;
    }
    final name = trimmed.substring(0, eqIndex).trim();
    final value = trimmed.substring(eqIndex + 1).trim();
    if (name.isEmpty) {
      continue;
    }
    map[name] = value;
  }
  return map;
}

String cookiePairsToHeader(Map<String, String> pairs) {
  return pairs.entries.map((e) => '${e.key}=${e.value}').join('; ');
}

String mergeCookieHeader({
  required String? currentCookieHeader,
  required List<String> setCookieHeaders,
}) {
  final currentPairs = currentCookieHeader == null
      ? <String, String>{}
      : parseCookieHeaderToPairs(currentCookieHeader);
  for (final setCookie in setCookieHeaders) {
    currentPairs.addAll(parseSetCookieToPairs(setCookie));
  }
  return cookiePairsToHeader(currentPairs);
}
