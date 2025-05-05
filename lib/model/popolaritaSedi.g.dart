part of 'popolaritaSedi.dart';



PopolaritaSedi _$PopolaritaSediFromJson(Map<String, dynamic> json) => PopolaritaSedi(
  nome: json['nome'] as String,
  indirizzo: json['indirizzo'] as String,
);

Map<String, dynamic> _$PopolaritaSediToJson(PopolaritaSedi instance) => <String, dynamic>{
  'nome': instance.nome,
  'indirizzo': instance.indirizzo,
};