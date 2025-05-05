import 'package:json_annotation/json_annotation.dart';

part 'popolaritaSedi.g.dart';

@JsonSerializable()
class PopolaritaSedi{
  String nome;
  String indirizzo;



  PopolaritaSedi(
    {
      required this.nome,
      required this.indirizzo,
    }
  );

  factory PopolaritaSedi.fromJson(Map<String, dynamic> json) => _$PopolaritaSediFromJson(json); 

  Map<String, dynamic> toJson() => _$PopolaritaSediToJson(this);
}