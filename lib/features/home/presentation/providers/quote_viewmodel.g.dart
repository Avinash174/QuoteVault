// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$quoteOfTheDayHash() => r'e9ac5a5582a5d94ea85119995fc03aa9f1203112';

/// See also [quoteOfTheDay].
@ProviderFor(quoteOfTheDay)
final quoteOfTheDayProvider = AutoDisposeFutureProvider<Quote>.internal(
  quoteOfTheDay,
  name: r'quoteOfTheDayProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$quoteOfTheDayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef QuoteOfTheDayRef = AutoDisposeFutureProviderRef<Quote>;
String _$selectedCategoryHash() => r'c72c879ce0df56f5c8a0aa3299ac3f667d226ddd';

/// See also [SelectedCategory].
@ProviderFor(SelectedCategory)
final selectedCategoryProvider =
    AutoDisposeNotifierProvider<SelectedCategory, String>.internal(
      SelectedCategory.new,
      name: r'selectedCategoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedCategoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedCategory = AutoDisposeNotifier<String>;
String _$quoteViewModelHash() => r'9e6b84d310109e67cd6bfaad27b5797a430eb4f1';

/// See also [QuoteViewModel].
@ProviderFor(QuoteViewModel)
final quoteViewModelProvider =
    AutoDisposeAsyncNotifierProvider<QuoteViewModel, List<Quote>>.internal(
      QuoteViewModel.new,
      name: r'quoteViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$quoteViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$QuoteViewModel = AutoDisposeAsyncNotifier<List<Quote>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
