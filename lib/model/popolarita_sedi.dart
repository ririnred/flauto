import 'package:json_annotation/json_annotation.dart';

part 'popolaritaSedi.g.dart';

@JsonSerializable()
class PopolaritaSedi{
  int id;
  String nome;
  String indirizzo;



  PopolaritaSedi(
    {
      required this.id,
      required this.nome,
      required this.indirizzo,
    }
  );

  factory PopolaritaSedi.fromJson(Map<String, dynamic> json) => _$PopolaritaSediFromJson(json); 

  Map<String, dynamic> toJson() => _$PopolaritaSediToJson(this);
}