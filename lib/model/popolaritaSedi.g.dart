part of 'popolaritaSedi.dart';



PopolaritaSedi _$PopolaritaSediFromJson(Map<String, dynamic> json) => PopolaritaSedi(
  nome: json['nome'] as String,
  indirizzo: json['indirizzo'] as String,
  tessereStatistiche: json['tessereStatistiche'] as Map<String, dynamic>? ?? {},
);

Map<String, dynamic> _$PopolaritaSediToJson(PopolaritaSedi instance) => <String, dynamic>{
  'nome': instance.nome,
  'indirizzo': instance.indirizzo,
  'tessereStatistiche': instance.tessereStatistiche,
};