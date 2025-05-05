import 'package:json_annotation/json_annotation.dart';

part 'tessera.g.dart';

@JsonSerializable()
class Tessera{
  int? id;
  int sedeId;
  int punti;
  int clienteId;
  DateTime dataCreazione;


  Tessera(
    {
      this.id,
      required this.sedeId,
      required this.punti,
      required this.clienteId,
      required this.dataCreazione,
    }
  );

  factory Tessera.fromJson(Map<String, dynamic> json) => _$TesseraFromJson(json); 

  Map<String, dynamic> toJson() => _$TesseraToJson(this);
}