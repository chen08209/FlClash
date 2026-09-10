import 'package:riverpod/misc.dart' show ProviderListenable;

typedef ProviderReader = T Function<T>(ProviderListenable<T> provider);
