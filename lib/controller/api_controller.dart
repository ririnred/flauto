// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

import '/model/persona.dart';
import '/model/sede.dart';
import '/model/tessera.dart';

class ApiController {
  final String baseUrl;

  const ApiController({required this.baseUrl});

  /// ricevi una lista di persone con alcuni filtri (XML/JSON)
  Future<List<Persona>> getClienti({String responseType = 'json'}) async {
    final uri = Uri.parse(
      '${baseUrl}read?content=clienti&response=$responseType',
    );
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      if (responseType.toLowerCase() == 'xml') {
        final document = xml.XmlDocument.parse(res.body);
        return document
            .findAllElements('cliente')
            .map(
              (node) => Persona(
                id: int.parse(node.getAttribute('id')!),
                nome: node.findElements('nome').single.text,
                cognome: node.findElements('cognome').single.text,
                mail: node.findElements('mail').single.text,
              ),
            )
            .toList();
      } else {
        final data = json.decode(res.body);
        final list = data['clienti_tesserati'] as List<dynamic>;
        return list
            .map((item) => Persona.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } else if (res.statusCode == 204) {
      return [];
    }
    throw Exception('Failed to get clienti: ${res.statusCode}');
  }

  /// ricevi una lista di sedi con alcuni filtri
  Future<List<Sede>> getSedi({
    String responseType = 'json',
    String? nome,
    String? indirizzo,
  }) async {
    final params = <String, String>{
      'content': 'sedi',
      'response': responseType,
    };
    if (nome != null && nome.isNotEmpty) params['nome'] = nome;
    if (indirizzo != null && indirizzo.isNotEmpty) {
      params['indirizzo'] = indirizzo;
    }

    final uri = Uri.parse("${baseUrl}read").replace(queryParameters: params);
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      if (responseType.toLowerCase() == 'xml') {
        final document = xml.XmlDocument.parse(res.body);
        return document
            .findAllElements('sede')
            .map(
              (node) => Sede(
                id:
                    node.getAttribute('id') != null
                        ? int.parse(node.getAttribute('id')!)
                        : null,
                nome: node.findElements('nome').single.text,
                indirizzo: node.findElements('indirizzo').single.text,
              ),
            )
            .toList();
      } else {
        final data = json.decode(res.body);
        final list = data['sedi'] as List<dynamic>;
        return list
            .map((item) => Sede.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } else if (res.statusCode == 204) {
      return [];
    }
    throw Exception('Failed to get sedi: ${res.statusCode}');
  }

  /// ricevi una lista di tessere con alcuni filtri
  Future<List<Tessera>> getTessere({
    String responseType = 'json',
    String? nome,
    String? cognome,
  }) async {
    final params = <String, String>{
      'content': 'tessere', // Specifica il tipo di contenuto richiesto
      'response': responseType, // Formato di risposta (JSON/XML)
    };

    // Aggiungi filtri opzionali se presenti
    if (nome != null && nome.isNotEmpty) params['nome'] = nome;
    if (cognome != null && cognome.isNotEmpty) params['cognome'] = cognome;

    // Costruisce l'URI corretto
    final uri = Uri.parse('${baseUrl}read').replace(queryParameters: params);

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      if (responseType.toLowerCase() == 'xml') {
        // Parsing XML
        final document = xml.XmlDocument.parse(res.body);
        return document.findAllElements('tessera').map((node) {
          final cliente = node.findElements('cliente').single;
          return Tessera(
            id: int.parse(
              node.getAttribute('numero_tessera') ?? '0',
            ), // Usa '0' come fallback
            punti: int.parse(node.findElements('punti').single.text),
            dataCreazione: DateTime.parse(
              node.findElements('data_di_creazione').single.text,
            ),
            sedeCreazione:
                node
                    .findElements('sede_di_creazione')
                    .single
                    .text, // Estrai da XML
            cliente: Persona.fromXml(cliente),
          );
        }).toList();
      } else {
        final data = json.decode(res.body);
        final list = data['tessere'] as List<dynamic>? ?? [];
        return list.map((item) {
          try {
            return Tessera.fromJson(item as Map<String, dynamic>);
          } catch (e) {
            print('Errore parsing tessera: $e');
            return Tessera(
              punti: 0,
              dataCreazione: DateTime.now(),
            ); // Oggetto tessera vuoto
          }
        }).toList();
      }
    } else if (res.statusCode == 204) {
      return []; // Nessun contenuto disponibile
    }
    throw Exception('Failed to get tessere: ${res.statusCode}');
  }

  /// ricevi una lista dynamica della popolarita delle sedi con alcuni filtri
  Future<List<dynamic>> getPopolaritaSedi({
    String responseType = 'json',
    String? nome,
    String? indirizzo,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final params = <String, String>{
      'content': 'popolarita_sedi',
      'response': responseType,
    };
    if (nome != null && nome.isNotEmpty) params['nome'] = nome;
    if (indirizzo != null && indirizzo.isNotEmpty)
      params['indirizzo'] = indirizzo;
    if (startDate != null)
      params['start_date'] = startDate.toIso8601String().substring(0, 10);
    if (endDate != null)
      params['end_date'] = endDate.toIso8601String().substring(0, 10);

    final uri = Uri.parse('${baseUrl}read').replace(queryParameters: params);
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      if (responseType.toLowerCase() == 'xml') {
        final document = xml.XmlDocument.parse(res.body);
        // return il Documento XML
        return document.findAllElements('sede').map((node) {
          final periods =
              node
                  .findElements('periodo')
                  .map(
                    (p) => {
                      'mese': p.getAttribute('mese'),
                      'n_tessere_create': int.parse(
                        p.getAttribute('n_tessere_create')!,
                      ),
                    },
                  )
                  .toList();
          return {
            'nome': node.getAttribute('nome'),
            'indirizzo': node.getAttribute('indirizzo'),
            'n_tot_di_tessere_create': int.parse(
              node.getAttribute('n_tot_di_tessere_create')!,
            ),
            'mesi': periods,
          };
        }).toList();
      } else {
        final data = json.decode(res.body);
        return data['sedi'] as List<dynamic>;
      }
    } else if (res.statusCode == 204) {
      return [];
    }
    throw Exception('Failed to get popolarita_sedi: ${res.statusCode}');
  }

  /// Crea un nuovo cliente con tessera associata
  Future<bool> creaClienteTessera({
    required String nome,
    required String cognome,
    required String mail,
    required int sedeId,
  }) async {
    final uri = Uri.parse('${baseUrl}crea_clientetessera');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'nome': nome,
        'cognome': cognome,
        'mail': mail,
        'sede_id': sedeId.toString(),
      },
    );

    if (response.statusCode == 200) {
      return true; // Successo
    } else if (response.statusCode == 400) {
      throw Exception('Dati mancanti o non validi');
    } else if (response.statusCode == 500) {
      throw Exception('Errore interno del server');
    } else {
      throw Exception('Errore sconosciuto: ${response.statusCode}');
    }
  }

  Future<bool> createSede({
    required String nome,
    required String indirizzo,
  }) async {
    final uri = Uri.parse("${baseUrl}crea_sede");

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'nome': nome, 'indirizzo': indirizzo},
    );
    if (response.statusCode == 200) {
      return true; // Successo
    } else if (response.statusCode == 400) {
      throw Exception('Dati mancanti o non validi');
    } else if (response.statusCode == 500) {
      throw Exception('Errore interno del server');
    } else {
      throw Exception('Errore sconosciuto: ${response.statusCode}');
    }
  }

  Future<bool> createTessera({
    required int cliente_id,
    required int sede_creazione_id,
  }) async {
    final uri = Uri.parse("${baseUrl}crea_tessera");

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'cliente_id': cliente_id.toString(),
        'sede_id': sede_creazione_id.toString(),
      },
    );

    if (response.statusCode == 200) {
      return true; // Successo
    } else if (response.statusCode == 400) {
      throw Exception('Dati mancanti o non validi');
    } else if (response.statusCode == 500) {
      throw Exception('Errore interno del server');
    } else {
      throw Exception('Errore sconosciuto: ${response.statusCode}');
    }
  }

  // === UPDATE ===
  Future<bool> updatePersona(Persona persona) async {
    final uri = Uri.parse(baseUrl);

    // final body = "{\"persona\":${persona.toJson().toString()}}";
    final body = jsonEncode({"persona": persona.toJson()});
    final res = await http.patch(
      uri,
      body: body,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
    );
    if (res.statusCode == 200) {
      return true;
    }
    throw Exception('Failed to update persona: ${res.statusCode}');
  }

  Future<bool> updateSede(Sede sede) async {
    final uri = Uri.parse(baseUrl);
    final body = jsonEncode({"sede": sede.toJson()});
    final res = await http.patch(
      uri,
      body: body,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
    );
    if (res.statusCode == 200) {
      return true;
    }
    throw Exception('Failed to update sede: ${res.statusCode}');
  }

  Future<bool> updateTessera(Tessera tessera) async {
    final uri = Uri.parse(baseUrl);
    final body = jsonEncode({"tessera": tessera.toJson()});
    final res = await http.patch(
      uri,
      body: body,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
    );
    if (res.statusCode == 200) {
      return true;
    }
    throw Exception('Failed to update tessera: ${res.statusCode}');
  }

  // === DELETE ===
  Future<void> deletePersona(int id) async {
    final uri = Uri.parse('${baseUrl}elimina_cliente?&id=$id');
    final res = await http.delete(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to delete persona: ${res.statusCode}');
    }
  }

  Future<void> deleteSede(int id) async {
    final uri = Uri.parse('${baseUrl}elimina_sede?&id=$id');
    final res = await http.delete(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to delete sede: ${res.statusCode}');
    }
  }

  Future<void> deleteTessera(int id) async {
    final uri = Uri.parse('${baseUrl}elimina_tessera?id=$id');
    final res = await http.delete(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to delete tessera: ${res.statusCode}');
    }
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
