// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Memories)
const memoriesProvider = MemoriesProvider._();

final class MemoriesProvider
    extends $NotifierProvider<Memories, MemoriesState> {
  const MemoriesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'memoriesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$memoriesHash();

  @$internal
  @override
  Memories create() => Memories();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemoriesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemoriesState>(value),
    );
  }
}

String _$memoriesHash() => r'6022892418e2816ea85ea676c7d7c00d51459332';

abstract class _$Memories extends $Notifier<MemoriesState> {
  MemoriesState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<MemoriesState, MemoriesState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<MemoriesState, MemoriesState>,
        MemoriesState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
