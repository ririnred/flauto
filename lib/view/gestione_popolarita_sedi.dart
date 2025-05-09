// gestione_popolarita_sedi.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controller/api_controller.dart';

class GestionePopolaritaSedi extends StatefulWidget {
  final ApiController apiController;
  
  const GestionePopolaritaSedi({super.key, required this.apiController});

  @override
  State<GestionePopolaritaSedi> createState() => _GestionePopolaritaSediState();
}

class _GestionePopolaritaSediState extends State<GestionePopolaritaSedi> {
  late Future<List<dynamic>> _popolaritaFuture;
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _nomeSede;
  String? _indirizzoSede;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _popolaritaFuture = widget.apiController.getPopolaritaSedi(
        nome: _nomeSede,
        indirizzo: _indirizzoSede,
        startDate: _startDate,
        endDate: _endDate,
      );
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Popolarità Sedi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _showFiltersDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _popolaritaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }
          
          final dati = snapshot.data!;
          if (dati.isEmpty) {
            return const Center(child: Text('Nessun dato disponibile'));
          }

          return ListView.builder(
            itemCount: dati.length,
            itemBuilder: (context, index) {
              final sede = dati[index];
              return ExpansionTile(
                title: Text('${sede['nome']} - ${sede['indirizzo']}'),
                subtitle: Text('Tessere totali: ${sede['n_tot_di_tessere_create']}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Andamento mensile:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        ...sede['mesi'].map<Widget>((mese) => ListTile(
                          title: Text(mese['mese']),
                          trailing: Text('${mese['n_tessere_create']} tessere'),
                        )).toList(),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showFiltersDialog() {
    final nomeController = TextEditingController(text: _nomeSede);
    final indirizzoController = TextEditingController(text: _indirizzoSede);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtra risultati'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: 'Nome sede'),
                  onChanged: (v) => _nomeSede = v.isNotEmpty ? v : null,
                ),
                TextFormField(
                  controller: indirizzoController,
                  decoration: const InputDecoration(labelText: 'Indirizzo sede'),
                  onChanged: (v) => _indirizzoSede = v.isNotEmpty ? v : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => _selectDate(context, true),
                        child: Text(
                          _startDate == null 
                            ? 'Seleziona data inizio'
                            : DateFormat('dd/MM/yyyy').format(_startDate!),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () => _selectDate(context, false),
                        child: Text(
                          _endDate == null 
                            ? 'Seleziona data fine'
                            : DateFormat('dd/MM/yyyy').format(_endDate!),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _nomeSede = null;
                _indirizzoSede = null;
                _startDate = null;
                _endDate = null;
              });
              _refreshData();
              Navigator.pop(context);
            },
            child: const Text('Reset filtri'),
          ),
          ElevatedButton(
            onPressed: () {
              _refreshData();
              Navigator.pop(context);
            },
            child: const Text('Applica'),
          ),
        ],
      ),
    );
  }
}