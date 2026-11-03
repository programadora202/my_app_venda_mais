import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 245, 242), //cor de fundo da tela
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 115, 32, 54),
        centerTitle: true,
        title: const Text('Desempenho',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25, 
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton( //ícone de voltar <-
          icon: 
            const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home'); // Volta para a tela home
          },
        ),
      

        // Botão de sair
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login',
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30), //adiciona um padding de 30 pixels em todos os lados da tela
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, //alinha os elementos no centro da tela
            children: [
              const SizedBox(height: 15),
              Text(
                'Bem-vindo a Dashboard!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 115, 32, 54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}