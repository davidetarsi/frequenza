import 'dart:math';

/// Draws the country the next flight lands in. A country comes up in
/// proportion to the square root of its stations: the big ones still lead,
/// the small ones get a fair turn.
abstract final class CountryDraw {
  static double weight(int stations) => stations <= 0 ? 0 : sqrt(stations);

  /// One code from [stations] (code to number of stations), or null when
  /// none is left. [among] limits the draw to the chosen countries (a single
  /// country is a group of one); null or empty means the whole world.
  /// [skip] holds countries already found empty.
  static String? pick(
    Map<String, int> stations, {
    Set<String>? among,
    Set<String> skip = const {},
    Random? random,
  }) {
    final chosen = among == null || among.isEmpty ? null : _codes(among);
    final skipped = _codes(skip);
    final pool = <String, double>{};
    for (final MapEntry(:key, :value) in stations.entries) {
      final code = key.trim().toUpperCase();
      if (code.isEmpty || skipped.contains(code)) continue;
      if (chosen != null && !chosen.contains(code)) continue;
      final w = weight(value);
      if (w > 0) pool[code] = (pool[code] ?? 0) + w;
    }
    if (pool.isEmpty) return null;
    final total = pool.values.fold(0.0, (sum, w) => sum + w);
    var point = (random ?? Random()).nextDouble() * total;
    for (final MapEntry(:key, :value) in pool.entries) {
      point -= value;
      if (point < 0) return key;
    }
    return pool.keys.last;
  }

  static Set<String> _codes(Set<String> codes) => {
    for (final code in codes) code.trim().toUpperCase(),
  };
}
