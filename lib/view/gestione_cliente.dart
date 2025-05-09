import 'package:flutter/material.dart';
import '../controller/api_controller.dart';
import '../model/persona.dart';
import '../model/sede.dart';

class GestioneCliente extends StatefulWidget {
  final ApiController apiController;

  const GestioneCliente({super.key, required this.apiController});

  @override
  State<GestioneCliente> createState() => _GestioneClienteState();
}

class _GestioneClienteState extends State<GestioneCliente> {
  late Future<List<Persona>> _clientiFuture;
  late Future<List<Sede>> _sediFuture;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _refreshData();
    _sediFuture = widget.apiController.getSedi();
  }

  // void refreshData() {
  //   setState(() => _clientiFuture = widget.apiController.getClienti());
  // }
  void _refreshData() {
    setState(() {
      _clientiFuture = widget.apiController.getClienti();
      _errorMessage = null;
    });
  }

  Future<void> loadClienti() async {
    try {
      setState(() => _isLoading = true);
      _clientiFuture = widget.apiController.getClienti();
      await _clientiFuture;
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load clients: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Clienti'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _buildMainContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showClienteForm(),
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

    return FutureBuilder<List<Persona>>(
      future: _clientiFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Errore: ${snapshot.error}'));
        }
        final clienti = snapshot.data!;
        return _buildClientList(clienti);
      },
    );
  }

  Widget _buildClientList(List<Persona> clienti) {
    return ListView.builder(
      itemCount: clienti.length,
      itemBuilder: (context, index) {
        final cliente = clienti[index];
        return ListTile(
          title: Text('${cliente.nome} ${cliente.cognome}'),
          subtitle: Text(cliente.mail),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showClienteForm(cliente: cliente),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteCliente(cliente.id),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteCliente(int? id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: const Text('Sei sicuro di voler eliminare questo cliente?'),
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

    if (confirm == true && id != null) {
      try {
        await widget.apiController.deletePersona(id);
        _refreshData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante eliminazione: $e')),
        );
      }
    }
  }

  /*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Clienti'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: FutureBuilder<List<Persona>>(
        future: _clientiFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }
          final clienti = snapshot.data!;
          return ListView.builder(
            itemCount: clienti.length,
            itemBuilder: (context, index) {
              final cliente = clienti[index];
              return ListTile(
                title: Text('${cliente.nome} ${cliente.cognome}'),
                subtitle: Text(cliente.mail),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => showEditClienteDialog(cliente),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteCliente(cliente.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddClienteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }


  void deleteCliente(int? id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: const Text('Sei sicuro di voler eliminare questo cliente?'),
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
        await widget.apiController.deletePersona(id!);
        refreshData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
*/
  void showAddClienteDialog() => _showClienteForm();
  void showEditClienteDialog(Persona cliente) =>
      _showClienteForm(cliente: cliente);

  void _showClienteForm({Persona? cliente}) async {
    final sedi = await _sediFuture;
    final nomeController = TextEditingController(text: cliente?.nome);
    final cognomeController = TextEditingController(text: cliente?.cognome);
    final mailController = TextEditingController(text: cliente?.mail);
    Sede? selectedSede;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(cliente == null ? 'Nuovo Cliente' : 'Modifica Cliente'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (v) => v!.isEmpty ? 'Inserisci nome' : null,
                ),
                TextFormField(
                  controller: cognomeController,
                  decoration: const InputDecoration(labelText: 'Cognome'),
                  validator: (v) => v!.isEmpty ? 'Inserisci cognome' : null,
                ),
                TextFormField(
                  controller: mailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => v!.isEmpty ? 'Inserisci email' : null,
                  keyboardType: TextInputType.emailAddress,
                ),
                DropdownButtonFormField<Sede>(
                  value: selectedSede,
                  hint: const Text('Seleziona Sede'),
                  items: sedi
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text('${s.nome} - ${s.indirizzo}'),
                          ))
                      .toList(),
                  onChanged: (s) => selectedSede = s,
                  validator: (v) => v == null ? 'Seleziona sede' : null,
                ),
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
                  if (cliente == null) {
                    await widget.apiController.creaClienteTessera(
                      nome: nomeController.text,
                      cognome: cognomeController.text,
                      mail: mailController.text,
                      sedeId: selectedSede!.id!,
                    );
                  } else {
                    final updated = Persona(
                      id: cliente.id,
                      nome: nomeController.text,
                      cognome: cognomeController.text,
                      mail: mailController.text,
                    );
                    await widget.apiController.updatePersona(updated);
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
