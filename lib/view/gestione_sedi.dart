import 'package:flutter/material.dart';
import '../controller/api_controller.dart';
import '../model/sede.dart';

class GestioneSedi extends StatefulWidget {
  final ApiController apiController;

  const GestioneSedi({super.key, required this.apiController});

  @override
  State<GestioneSedi> createState() => _GestioneSediState();
}

class _GestioneSediState extends State<GestioneSedi> {
  late Future<List<Sede>> _sediFuture;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _sediFuture = widget.apiController.getSedi();
      _errorMessage = null;
    });
  }

  Future<void> loadSedi() async {
    try {
      setState(() => _isLoading = true);
      _sediFuture = widget.apiController.getSedi();
      await _sediFuture;
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load sedi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Sedi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _buildMainContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSedeForm(),
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

    return FutureBuilder<List<Sede>>(
        future: _sediFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }
          final sedi = snapshot.data!;
          return ListView.builder(
            itemCount: sedi.length,
            itemBuilder: (context, index) {
              final sede = sedi[index];
              return ListTile(
                title: Text(sede.nome),
                subtitle: Text(sede.indirizzo),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showSedeForm(sede),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteSede(sede.id!),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  void _deleteSede(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: const Text('Sei sicuro di voler eliminare questa sede?'),
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
        await widget.apiController.deleteSede(id);
        _refreshData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void showAddSedeDialog() => _showSedeForm();
  void showEditSedeDialog(Sede sede) => _showSedeForm(sede);

  void _showSedeForm([Sede? sede]) {
    final nomeController = TextEditingController(text: sede?.nome);
    final indirizzoController = TextEditingController(text: sede?.indirizzo);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(sede == null ? 'Nuova Sede' : 'Modifica Sede'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => v!.isEmpty ? 'Inserisci nome' : null,
              ),
              TextFormField(
                controller: indirizzoController,
                decoration: const InputDecoration(labelText: 'Indirizzo'),
                validator: (v) => v!.isEmpty ? 'Inserisci indirizzo' : null,
              ),
            ],
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
                  final newSede = Sede(
                    id: sede?.id,
                    nome: nomeController.text,
                    indirizzo: indirizzoController.text,
                  );

                  if (sede == null) {
                    await widget.apiController.createSede(
                        nome: nomeController.text,
                        indirizzo: indirizzoController.text);
                  } else {
                    await widget.apiController.updateSede(newSede);
                  }

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
