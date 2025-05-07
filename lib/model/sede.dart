import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Sede {
  int? id;
  String nome;
  String idirizzo;

  Sede({
    this.id,
    required this.nome,
    required this.idirizzo,
  });

  Sede.fromJson(Map<String, dynamic> json) :
        id = (json['id'] as num?)?.toInt(),
        nome = json['nome'] as String,
        idirizzo = json['idirizzo'] as String;
      

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'idirizzo': idirizzo,
      };
}