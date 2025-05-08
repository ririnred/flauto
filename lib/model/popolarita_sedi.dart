import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:xml/xml.dart' as xml;

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

  factory PopolaritaSedi.fromXml(xml.XmlElement xmlElement) {
    return PopolaritaSedi(
      nome: xmlElement.findElements('nome').single.text,
      indirizzo: xmlElement.findElements('indirizzo').single.text,
      tessereStatistiche: _parseTessereStatistiche(xmlElement),
    );
  }

  Map<String, dynamic> toJson() => {
      'nome': nome, 
      'indirizzo': indirizzo, 
      'tessereStatistiche': tessereStatistiche
    };

  static Map<String, dynamic> _parseTessereStatistiche(xml.XmlElement element) {
    final tessereElement = element.findElements('tessereStatistiche');
    if (tessereElement.isEmpty) return {};

    final content = tessereElement.single.text;
    try {
      return json.decode(content) as Map<String, dynamic>;
    } catch (_) {
      return {}; // Fallback in caso di parsing fallito
    }
  }
}