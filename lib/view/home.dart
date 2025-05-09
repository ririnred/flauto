
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('First Route')),
      body: Center(
          child: ElevatedButton(
            child: const Text('Open route'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
      ),
    );
  }
}