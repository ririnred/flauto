import 'package:json_annotation/json_annotation.dart';
import 'package:xml/xml.dart' as xml;

@JsonSerializable()
class Tessera {
  int? id;
  int? sedeId;
  int punti;
  int? clienteId;
  DateTime dataCreazione;

  Tessera({
    this.id,
    this.sedeId,
    required this.punti,
    this.clienteId,
    required this.dataCreazione,
  });

  Tessera.fromJson(Map<String, dynamic> json) :
    id = json['id'] as int?,
    sedeId = json['sedeId'] as int?,
    punti = json['punti'] as int,
    clienteId = json['clienteId'] as int?,
    dataCreazione = DateTime.parse(json['dataCreazione'] as String);

  factory Tessera.fromXml(xml.XmlElement xmlElement) {
    return Tessera(
      id: int.parse(xmlElement.findElements('id').single.text),
      sedeId: int.parse(xmlElement.findElements('sedeId').single.text),
      punti: int.parse(xmlElement.findElements('punti').single.text),
      clienteId: int.parse(xmlElement.findElements('clienteId').single.text),
      dataCreazione: DateTime.parse(xmlElement.findElements('dataCreazione').single.text),
    );
  }
    

  Map<String, dynamic> toJson() => {
        'id': id,
        'sedeId': sedeId,
        'punti': punti,
        'clienteId': clienteId,
        'dataCreazione': dataCreazione.toIso8601String(),
      };
}