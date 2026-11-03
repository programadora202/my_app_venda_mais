import 'package:flutter/material.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  bool mostrarSenha = false; //variável para controlar a exibição da senha
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 245, 242), //cor de fundo da tela
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 115, 32, 54),
          centerTitle: true,
          title: const Text('Recuperação de conta',
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
              Navigator.pop(context); // Volta para a tela anterior
            },
          ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30), //adiciona um padding de 30 pixels em todos os lados da tela
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, //alinha os elementos no centro da tela
            children: [

              const SizedBox(height: 30),
              // LOGO           
              Image.asset(
                'assets/logo.png',
                width: 210,
              ),

              const SizedBox(height: 25),

              // E-MAIL
              TextField(
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),

                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 115, 32, 54),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              // BOTÃO Enviar código
               // BOTÃO DE REGISTRO
              ElevatedButton( 
                onPressed: () {
                  Navigator.pushNamed(context, '/registro');
                  // Ação ao pressionar o botão de registro
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(255, 115, 32, 54), // Cor de fundo
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8), // Borda arredondada
                  ),
                ),
                child: const Text('ENVIAR CÓDIGO',
                  style: TextStyle(
                    fontSize: 16,   
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),    
              ),
            ]
          ),
        ),
      ),
    );
  }
  }