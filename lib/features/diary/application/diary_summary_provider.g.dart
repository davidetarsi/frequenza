// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_summary_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$diarySummaryHash() => r'cff2f90e3426047601b83ba55942318e5617fc5c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// The diary of [period], computed again every time the log writes.
///
/// Copied from [diarySummary].
@ProviderFor(diarySummary)
const diarySummaryProvider = DiarySummaryFamily();

/// The diary of [period], computed again every time the log writes.
///
/// Copied from [diarySummary].
class DiarySummaryFamily extends Family<AsyncValue<DiarySummary>> {
  /// The diary of [period], computed again every time the log writes.
  ///
  /// Copied from [diarySummary].
  const DiarySummaryFamily();

  /// The diary of [period], computed again every time the log writes.
  ///
  /// Copied from [diarySummary].
  DiarySummaryProvider call(DiaryPeriod period) {
    return DiarySummaryProvider(period);
  }

  @override
  DiarySummaryProvider getProviderOverride(
    covariant DiarySummaryProvider provider,
  ) {
    return call(provider.period);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'diarySummaryProvider';
}

/// The diary of [period], computed again every time the log writes.
///
/// Copied from [diarySummary].
class DiarySummaryProvider extends AutoDisposeStreamProvider<DiarySummary> {
  /// The diary of [period], computed again every time the log writes.
  ///
  /// Copied from [diarySummary].
  DiarySummaryProvider(DiaryPeriod period)
    : this._internal(
        (ref) => diarySummary(ref as DiarySummaryRef, period),
        from: diarySummaryProvider,
        name: r'diarySummaryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$diarySummaryHash,
        dependencies: DiarySummaryFamily._dependencies,
        allTransitiveDependencies:
            DiarySummaryFamily._allTransitiveDependencies,
        period: period,
      );

  DiarySummaryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.period,
  }) : super.internal();

  final DiaryPeriod period;

  @override
  Override overrideWith(
    Stream<DiarySummary> Function(DiarySummaryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DiarySummaryProvider._internal(
        (ref) => create(ref as DiarySummaryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        period: period,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<DiarySummary> createElement() {
    return _DiarySummaryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DiarySummaryProvider && other.period == period;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, period.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DiarySummaryRef on AutoDisposeStreamProviderRef<DiarySummary> {
  /// The parameter `period` of this provider.
  DiaryPeriod get period;
}

class _DiarySummaryProviderElement
    extends AutoDisposeStreamProviderElement<DiarySummary>
    with DiarySummaryRef {
  _DiarySummaryProviderElement(super.provider);

  @override
  DiaryPeriod get period => (origin as DiarySummaryProvider).period;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
