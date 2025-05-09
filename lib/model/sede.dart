import 'package:json_annotation/json_annotation.dart';
import 'package:xml/xml.dart' as xml;

@JsonSerializable()
class Sede {
  int? id;
  String nome;
  String indirizzo;

  Sede({
    this.id,
    required this.nome,
    required this.indirizzo,
  });

  Sede.fromJson(Map<String, dynamic> json)
      : id = (json['id'] as num?)?.toInt(),
        nome = json['nome'] as String,
        indirizzo = json['indirizzo'] as String;

  factory Sede.fromXml(xml.XmlElement xmlElement) {
    return Sede(
      id: int.parse(xmlElement.findElements('id').single.text),
      nome: xmlElement.findElements('nome').single.text,
      indirizzo: xmlElement.findElements('idirizzo').single.text,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'indirizzo': indirizzo,
      };
}
