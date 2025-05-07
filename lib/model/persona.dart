import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Persona {
  int? id;
  String nome;
  String cognome;
  String mail;

  Persona({
    this.id,
    required this.nome,
    required this.cognome,
    required this.mail,
  });

  Persona.fromJson(Map<String, dynamic> json) :
    id = (json['id'] as num?)?.toInt(),
    nome = json['nome'] as String,
    cognome = json['cognome'] as String,
    mail = json['mail'] as String;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'cognome': cognome,
        'mail': mail,
      };
}