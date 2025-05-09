import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsante per la gestione clienti
            buildNavigationButton(
              context: context,
              label: 'Gestione Clienti',
              icon: Icons.person,
              routeName: '/gestione_clienti.dart', // Sostituisci con il nome della tua route
            ),
            const SizedBox(height: 15),
            // Pulsante per la gestione sedi
            buildNavigationButton(
              context: context,
              label: 'Gestione Sedi',
              icon: Icons.business,
              routeName: '/gestione_sedi.dart',
            ),
            const SizedBox(height: 15),
            // Pulsante per la gestione tessere
            buildNavigationButton(
              context: context,
              label: 'Gestione Tessere',
              icon: Icons.credit_card,
              routeName: '/gestione_tessere.dart',
            ),
            const SizedBox(height: 15),
            // Pulsante per le statistiche di popolarità
            buildNavigationButton(
              context: context,
              label: 'Popolarità Sedi',
              icon: Icons.analytics,
              routeName: '/gestione_popolarita_sedi.dart',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNavigationButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String routeName,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
        ),
        onPressed: () => Navigator.pushNamed(context, routeName),
      ),
    );
  }
}