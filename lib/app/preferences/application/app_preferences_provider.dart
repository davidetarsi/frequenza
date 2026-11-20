import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/shared_preferences_repository.dart';
import '../domain/app_preferences_repository.dart';

part 'app_preferences_provider.g.dart';

@Riverpod(keepAlive: true)
AppPreferencesRepository appPreferencesRepository(Ref ref) =>
    SharedPreferencesRepository();
