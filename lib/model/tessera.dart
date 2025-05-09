import 'package:json_annotation/json_annotation.dart';
import 'package:xml/xml.dart' as xml;

import 'persona.dart';

@JsonSerializable()
class Tessera {
  int? id;
  String? sedeCreazione;
  int punti;
  Persona? cliente;
  DateTime dataCreazione;

  Tessera({
    this.id,
    this.sedeCreazione,
    required this.punti,
    this.cliente,
    required this.dataCreazione,
  });

  factory Tessera.fromJson(Map<String, dynamic> json) {
    return Tessera(
      id: _parseInt(json['numero_tessera']),
      sedeCreazione: json['sede_di_creazione'] as String?,
      punti: _parseInt(json['punti']) ?? 0, // Default a 0 se null
      cliente: json['cliente'] != null
          ? Persona.fromJson(json['cliente'] as Map<String, dynamic>)
          : null,
      dataCreazione: _parseDateTime(json['data_di_creazione']),
    );
  }

  factory Tessera.fromXml(xml.XmlElement xmlElement) {
    return Tessera(
      id: int.parse(xmlElement.findElements('numero_tessera').single.text),
      sedeCreazione: xmlElement.findElements('sede_di_creazione').single.text,
      punti: int.parse(xmlElement.findElements('punti').single.text),
      cliente: Persona.fromXml(xmlElement.findElements('cliente').single),
      dataCreazione: DateTime.parse(
          xmlElement.findElements('data_di_creazione').single.text),
    );
  }

  Map<String, dynamic> toJson() => {
        'numero_tessera': id,
        'sede_creazione_id': sedeCreazione,
        'punti': punti,
        'cliente_id': cliente,
        'data_creazione': dataCreazione.toIso8601String(),
      };

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime _parseDateTime(dynamic value) {
    try {
      return DateTime.parse(value as String);
    } catch (e) {
      return DateTime.now(); // Default a data corrente se parsing fallisce
    }
  }
}
