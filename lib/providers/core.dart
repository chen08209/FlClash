import 'package:fl_clash/core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/core.g.dart';

@Riverpod(keepAlive: true)
CoreController coreHandler(Ref ref) => coreController;

/// Kept apart from the state it feeds: the Core's stream moves it, and the
/// pages that show connections read it on their own cadence.
@Riverpod(keepAlive: true)
ConnectionBook connectionBook(Ref ref) => ConnectionBook();

@Riverpod(keepAlive: true)
CoreStateSync coreStateSync(Ref ref) => CoreStateSync();
