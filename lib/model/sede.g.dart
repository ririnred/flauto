part of 'sede.dart';

Sede _$SedeFromJson(Map<String, dynamic> json) => Sede(
  id: (json['id'] as num?)?.toInt(),
  nome: json['nome'] as String,
  idirizzo: json['idirizzo'] as String,
);

Map<String, dynamic> _$SedeToJson(Sede instance) => <String, dynamic>{
  'id': instance.id,
  'nome': instance.nome,
  'idirizzo': instance.idirizzo,
};