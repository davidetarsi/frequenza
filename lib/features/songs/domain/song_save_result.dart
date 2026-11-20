import 'package:freezed_annotation/freezed_annotation.dart';

part 'song_save_result.freezed.dart';

@freezed
sealed class SongSaveResult with _$SongSaveResult {
  const factory SongSaveResult.saved() = SongSaved;
  const factory SongSaveResult.duplicate() = SongDuplicate;
  const factory SongSaveResult.unavailable() = SongsUnavailable;
  const factory SongSaveResult.failed() = SongSaveFailed;
}
