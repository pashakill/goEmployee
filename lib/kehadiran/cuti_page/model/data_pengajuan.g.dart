// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_pengajuan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataPengajuan _$DataPengajuanFromJson(Map<String, dynamic> json) =>
    DataPengajuan(
      pengajuan: (json['pengajuan'] as List<dynamic>)
          .map((e) => PengajuanData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DataPengajuanToJson(DataPengajuan instance) =>
    <String, dynamic>{
      'pengajuan': instance.pengajuan,
    };
