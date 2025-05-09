import 'package:flutter/material.dart';
import '../controller/api_controller.dart';
import '../model/tessera.dart';

class GestioneTessere extends StatefulWidget {
  final ApiController apiController;
  
  const GestioneTessere({super.key, required this.apiController});

  @override
  State<GestioneTessere> createState() => _GestioneTessereState();
}

class _GestioneTessereState extends State<GestioneTessere> {
  late Future<List<Tessera>> _tessereFuture;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  void refreshData() {
    _tessereFuture = widget.apiController.getTessere();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Tessere'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshData,
          ),
        ],
      ),
      body: FutureBuilder<List<Tessera>>(
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
                    Text('Data creazione: ${tessera.dataCreazione.toString().substring(0, 10)}'),
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
      ),
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
        refreshData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}