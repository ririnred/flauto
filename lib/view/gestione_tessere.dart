import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controller/api_controller.dart';
import '../model/persona.dart';
import '../model/sede.dart';
import '../model/tessera.dart';

class GestioneTessere extends StatefulWidget {
  final ApiController apiController;

  const GestioneTessere({super.key, required this.apiController});

  @override
  State<GestioneTessere> createState() => _GestioneTessereState();
}

class _GestioneTessereState extends State<GestioneTessere> {
  late Future<List<Tessera>> _tessereFuture;
  late Future<List<Persona>> _clientiFuture;
  late Future<List<Sede>> _sediFuture;
  bool _isLoading = false;
  String? _errorMessage;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _refreshData();
    _sediFuture = widget.apiController.getSedi();
    _clientiFuture = widget.apiController.getClienti();
  }

  void _refreshData() {
    setState(() {
      _tessereFuture = widget.apiController.getTessere();
      _errorMessage = null;
    });
    _sediFuture = widget.apiController.getSedi();
    _clientiFuture = widget.apiController.getClienti();
  }

  Future<void> loadTessere() async {
    try {
      setState(() => _isLoading = true);
      _tessereFuture = widget.apiController.getTessere();
      await _tessereFuture;
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load tessere: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Tessere'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _buildMainContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTesseraForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    return FutureBuilder<List<Tessera>>(
      future: _tessereFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Errore: ${snapshot.error}'));
        }
        final tessere = snapshot.data!;
        return ListView.builder(
          itemCount: tessere.length,
          itemBuilder: (context, index) {
            final tessera = tessere[index];
            return ListTile(
              title: Text('Tessera #${tessera.id}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Punti: ${tessera.punti}'),
                  Text(
                    'Data creazione: ${DateFormat('dd/MM/yyyy').format(tessera.dataCreazione)}',
                  ),
                  if (tessera.cliente != null)
                    Text(
                        'Cliente: ${tessera.cliente!.nome} ${tessera.cliente!.cognome}'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => deleteTessera(tessera.id),
              ),
            );
          },
        );
      },
    );
  }

  void deleteTessera(int? id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: const Text('Sei sicuro di voler eliminare questa tessera?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.apiController.deleteTessera(id!);
        _refreshData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void showAddClienteDialog() => _showTesseraForm();
  void showEditClienteDialog(Tessera tessera) =>
      _showTesseraForm(tessera: tessera);

  void _showTesseraForm({Tessera? tessera}) async {
    final sedi = await _sediFuture;
    final clienti = await _clientiFuture;
    Sede? selectedSede;
    Persona? selectedCliente;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nuova Tessera'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Sede>(
                  value: selectedSede,
                  hint: const Text('Seleziona Sede Creazione Tessera'),
                  items: sedi
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text('${s.nome} - ${s.indirizzo}'),
                          ))
                      .toList(),
                  onChanged: (s) => selectedSede = s,
                  validator: (v) => v == null ? 'Seleziona sede' : null,
                ),
                DropdownButtonFormField<Persona>(
                  value: selectedCliente,
                  hint: const Text('Seleziona Cliente'),
                  items: clienti
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text('${s.nome} ${s.cognome}'),
                          ))
                      .toList(),
                  onChanged: (s) => selectedCliente = s,
                  validator: (v) => v == null ? 'Seleziona sede' : null,
                )
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  await widget.apiController.createTessera(
                    cliente_id: selectedCliente!.id!,
                    sede_creazione_id: selectedSede!.id!,
                  );

                  _refreshData();
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }
}
