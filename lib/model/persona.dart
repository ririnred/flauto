import 'package:json_annotation/json_annotation.dart';

part 'persona.g.dart';

@JsonSerializable()
class Persona{
  int? id;
  String nome;
  String cognome;
  String mail;


  Persona(
    {
      this.id,
      required this.nome,
      required this.cognome,
      required this.mail,
    }
  );

  factory Persona.fromJson(Map<String, dynamic> json) => _$PersonaFromJson(json); 

  Map<String, dynamic> toJson() => _$PersonaToJson(this);
}