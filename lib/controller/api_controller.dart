import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import '/model/persona.dart';
import '/model/sede.dart';
import '/model/tessera.dart';
import '/model/popolarita_sedi.dart';

class api_controller {
  static Future<dynamic> handleResponse({
    required http.Response response,
    required String contentKey,
    required String rootElement,
    required dynamic Function(Map<String, dynamic>) fromJson,
    required dynamic Function(xml.XmlElement) fromXml,
  }) async {
    final contentType = response.headers['content-type'];
    
    if (contentType?.contains('application/json') == true) {
      return _handleJsonResponse(response, contentKey, fromJson);
    } else if (contentType?.contains('application/xml') == true) {
      return _handleXmlResponse(response, rootElement, fromXml);
    } else {
      throw FormatException('Formato risposta non supportato: $contentType');
    }
  }

  static dynamic _handleJsonResponse(
    http.Response response,
    String contentKey,
    Function fromJson,
  ) {
    final jsonData = json.decode(response.body);
    final content = jsonData[contentKey] as List;
    
    return content.map((item) => fromJson(item)).toList();
  }

  static dynamic _handleXmlResponse(
    http.Response response,
    String rootElement,
    Function fromXml,
  ) {
    final document = xml.XmlDocument.parse(response.body);
    final root = document.findElements(rootElement).first;
    
    return root.childElements
        .map((element) => fromXml(element))
        .toList();
  }

  // Metodi specifici per ogni endpoint
  Future<List<Persona>> getClienti(http.Response response) => 
    handleResponse(
      response: response,
      contentKey: 'clienti_tesserati',
      rootElement: 'clienti_tesserati',
      fromJson: (json) => Persona.fromJson(json),
      fromXml: (xml) => Persona.fromXml(xml),
    ) as Future<List<Persona>>;

  Future<List<Tessera>> getTessere(http.Response response) => 
    handleResponse(
      response: response,
      contentKey: 'tessere',
      rootElement: 'tessere',
      fromJson: (json) => Tessera.fromJson(json),
      fromXml: (xml) => Tessera.fromXml(xml),
    ) as Future<List<Tessera>>;

    Future<List<Sede>> getSedi(http.Response response) => 
    handleResponse(
      response: response,
      contentKey: 'sedi',
      rootElement: 'sedi',
      fromJson: (json) => Sede.fromJson(json),
      fromXml: (xml) => Sede.fromXml(xml),
    ) as Future<List<Sede>>;

    Future<List<PopolaritaSedi>> getPopolaritaSedi(http.Response response) => 
    handleResponse(
      response: response,
      contentKey: 'popolarita_sedi',
      rootElement: 'popolarita_sedi',
      fromJson: (json) => PopolaritaSedi.fromJson(json),
      fromXml: (xml) => PopolaritaSedi.fromXml(xml),
    ) as Future<List<PopolaritaSedi>>;
}