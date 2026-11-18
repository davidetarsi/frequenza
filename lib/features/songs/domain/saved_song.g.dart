// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SavedSongImpl _$$SavedSongImplFromJson(Map<String, dynamic> json) =>
    _$SavedSongImpl(
      artist: _text(json['artist']),
      title: json['title'] as String,
      station: const StationRecordConverter().fromJson(
        json['station'] as Map<String, Object?>,
      ),
      savedAt: DateTime.parse(json['at'] as String),
    );

Map<String, dynamic> _$$SavedSongImplToJson(_$SavedSongImpl instance) =>
    <String, dynamic>{
      if (instance.artist case final value?) 'artist': value,
      'title': instance.title,
      'station': const StationRecordConverter().toJson(instance.station),
      'at': _utc(instance.savedAt),
    };
