import 'package:flutter/material.dart';
import '/view/home.dart';
import '/view/gestione_cliente.dart';
import '/view/gestione_popolarita_sedi.dart';
import '/view/gestione_tessere.dart';
import 'controller/api_controller.dart';

void main() {
  runApp(const MainApp(apiController: ApiController(baseUrl: "/")));
}

class MainApp extends StatelessWidget {
  final ApiController apiController;
  const MainApp({super.key, required this.apiController});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Removed const
      initialRoute: '/',
      routes: {
        '/': (context) => Home(),
        '/gestione_clienti': (context) =>
            GestioneCliente(apiController: apiController),
        // Add other routes here
        '/gestione_popolarita_sedi': (context) =>
            GestionePopolaritaSedi(apiController: apiController),
        '/gestione_tessere': (context) =>
            GestioneTessere(apiController: apiController),
      },
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
      },
      title: 'My App',
      debugShowCheckedModeBanner: false,
      // Remove the 'home' property since you're using initialRoute
    );
  }
}
