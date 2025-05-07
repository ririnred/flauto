import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class PopolaritaSedi{
  String nome;
  String indirizzo;
  Map<String, dynamic> tessereStatistiche;

  PopolaritaSedi({
      required this.nome,
      required this.indirizzo,
      required this.tessereStatistiche,
  });

  PopolaritaSedi.fromJson(Map<String, dynamic> json)
    : nome = json['nome'] as String,
      indirizzo = json['indirizzo'] as String,
      tessereStatistiche = json['tessereStatistiche'] as Map<String, dynamic>? ?? {};

  Map<String, dynamic> toJson() => {
      'nome': nome, 
      'indirizzo': indirizzo, 
      'tessereStatistiche': tessereStatistiche
    };
}