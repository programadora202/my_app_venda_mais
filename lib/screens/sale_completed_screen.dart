import 'package:flutter/material.dart';

class SaleCompletedScreen extends StatelessWidget {
  const SaleCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Venda'),
      ),
      body: const Center(
        child: Text('Tela de Nova Venda'),
      ),
    );
  }
}