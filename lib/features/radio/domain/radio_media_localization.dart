import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../app/localization/domain/app_language.dart';

part 'radio_media_localization.freezed.dart';

@freezed
class RadioMediaLocalization with _$RadioMediaLocalization {
  const factory RadioMediaLocalization({
    required AppLanguage language,
    required String flying,
    required String save,
    required String remove,
    required String play,
    required String pause,
    required String next,
    required String previous,
    required String unknownCountry,
    required String channelName,
  }) = _RadioMediaLocalization;
}
