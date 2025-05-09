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
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _tessereFuture = widget.apiController.getTessere();
      _errorMessage = null;
    });
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
        body: _buildMainContent());
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
                      'Data creazione: ${tessera.dataCreazione.toString().substring(0, 10)}'),
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
}
