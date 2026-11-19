import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/method_channel_app_platform.dart';
import '../domain/app_platform.dart';

part 'app_platform_provider.g.dart';

@Riverpod(keepAlive: true)
AppPlatform appPlatform(Ref ref) => MethodChannelAppPlatform();
