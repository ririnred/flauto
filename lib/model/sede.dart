import 'package:json_annotation/json_annotation.dart';
import 'package:xml/xml.dart' as xml;

@JsonSerializable()
class Sede {
  int? id;
  String nome;
  String idirizzo;

  Sede({
    this.id,
    required this.nome,
    required this.idirizzo,
  });

  Sede.fromJson(Map<String, dynamic> json) :
        id = (json['id'] as num?)?.toInt(),
        nome = json['nome'] as String,
        idirizzo = json['idirizzo'] as String;

  factory Sede.fromXml(xml.XmlElement xmlElement) {
    return Sede(
      id: int.parse(xmlElement.findElements('id').single.text),
      nome: xmlElement.findElements('nome').single.text,
      idirizzo: xmlElement.findElements('idirizzo').single.text,
    );
  }   

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'idirizzo': idirizzo,
      };
}