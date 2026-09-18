import 'package:flutter/material.dart';

class ProdutoDetailsScreen extends StatelessWidget {
  const ProdutoDetailsScreen({super.key});

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

