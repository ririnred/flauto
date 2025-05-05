import 'package:json_annotation/json_annotation.dart';

part 'sede.g.dart';

@JsonSerializable()
class Sede{
  int? id;
  String nome;
  String idirizzo;


  Sede(
    {
      this.id,
      required this.nome,
      required this.idirizzo,
    }
  );

  factory Sede.fromJson(Map<String, dynamic> json) => _$SedeFromJson(json); 

  Map<String, dynamic> toJson() => _$SedeToJson(this);
}