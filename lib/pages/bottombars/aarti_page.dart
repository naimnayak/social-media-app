import 'package:flutter/material.dart';

class AartiPostTab extends StatelessWidget {
  const AartiPostTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 2, 51),
      appBar: AppBar(
        title: Center(
          child: Text(
            'Aarti',
            style: TextStyle(color: Colors.yellow[700]),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 2, 51),
      ),
      body: const Center(
        child: Text(
          'Aarti',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
