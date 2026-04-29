// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_data_slip_gaji.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListDataSlipGaji _$ListDataSlipGajiFromJson(Map<String, dynamic> json) =>
    ListDataSlipGaji(
      dataSlipGajiModels: (json['data'] as List<dynamic>)
          .map((e) => DataSlipGajiModels.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ListDataSlipGajiToJson(ListDataSlipGaji instance) =>
    <String, dynamic>{
      'notifications': instance.dataSlipGajiModels,
    };
