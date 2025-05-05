part of 'persona.dart';

Persona _$PersonaFromJson(Map<String, dynamic> json) => Persona(
  id: (json['id'] as num?)?.toInt(),
  nome: json['nome'] as String,
  cognome: json['cognome'] as String,
  mail: json['mail'] as String,
);

Map<String, dynamic> _$PersonaToJson(Persona instance) => <String, dynamic>{
  'id': instance.id,
  'year': instance.nome,
  'section': instance.cognome,
  'major': instance.mail,
};