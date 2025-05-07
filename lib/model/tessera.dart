import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Tessera {
  int? id;
  int sedeId;
  int punti;
  int clienteId;
  DateTime dataCreazione;

  Tessera({
    this.id,
    required this.sedeId,
    required this.punti,
    required this.clienteId,
    required this.dataCreazione,
  });

  Tessera.fromJson(Map<String, dynamic> json) :
    id = (json['id'] as num?)?.toInt(),
    sedeId = json['sedeId'] as int,
    punti = json['punti'] as int,
    clienteId = json['clienteId'] as int,
    dataCreazione = DateTime.parse(json['dataCreazione'] as String);
    

  Map<String, dynamic> toJson() => {
        'id': id,
        'sedeId': sedeId,
        'punti': punti,
        'clienteId': clienteId,
        'dataCreazione': dataCreazione.toIso8601String(),
      };
}