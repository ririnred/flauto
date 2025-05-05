part of 'tessera.dart';

Tessera _$TesseraFromJson(Map<String, dynamic> json) => Tessera(
  id: (json['id'] as num?)?.toInt(),
  sedeId: json['sedeId'] as int,
  punti: json['punti'] as int,
  clienteId: json['clienteId'] as int,
  dataCreazione: DateTime.parse(json['dataCreazione'] as String),
);

Map<String, dynamic> _$TesseraToJson(Tessera instance) => <String, dynamic>{
  'id': instance.id,
  'sedeId': instance.sedeId,
  'punti': instance.punti,
  'clienteId': instance.clienteId,
  'dataCreazione': instance.dataCreazione.toIso8601String(),
};