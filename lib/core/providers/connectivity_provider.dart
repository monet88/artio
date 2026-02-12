import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<bool> connectivity(Ref ref) async* {
  final connectivity = Connectivity();
  final initial = await connectivity.checkConnectivity();
  yield initial.any((r) => r != ConnectivityResult.none);
  yield* connectivity.onConnectivityChanged.map(
    (results) => results.any((r) => r != ConnectivityResult.none),
  );
}
