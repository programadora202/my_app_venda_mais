import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool mostrarSenha = false; //variável para controlar a exibição da senha
  @override
  Widget build(BuildContext context) {
    return Scaffold( //scaffold é o widget que fornece a estrutura básica para a tela, incluindo barra de aplicativos, corpo e outros elementos visuais.
      backgroundColor: Color.fromARGB(255, 255, 245, 242), //cor de fundo da tela
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30), //adiciona um padding de 30 pixels em todos os lados da tela
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, //alinha os elementos no centro da tela
            children: [

              // LOGO
              Image.asset(
                'assets/logo.png',
                width: 180,
              ),
              
              const SizedBox(height: 15),

              //NOME DA EMPRESA
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nome da Empresa', 
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 115, 32, 54),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),
              
              // NOME
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 115, 32, 54),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

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

              const SizedBox(height: 15),

              TextField(
                obscureText: !mostrarSenha,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 115, 32, 54),
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      mostrarSenha
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color.fromARGB(255, 115, 32, 54),
                    ),
                    onPressed: () {
                      setState(() {
                        mostrarSenha = !mostrarSenha;
                      });
                    },
                  ),
                ),
              ),
              

              const SizedBox(height: 15),

              // CONFIRMAR SENHA
              TextField(
                obscureText: !mostrarSenha,
                decoration: InputDecoration(
                  labelText: 'Confirmar Senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),

                    borderSide: BorderSide(
                      color: const Color.fromARGB(255, 115, 32, 54),
                    ),
                  ),
                  suffixIcon: IconButton( //adiciona um ícone de olho para mostrar ou ocultar a senha
                  icon: Icon(
                    mostrarSenha //if ternário para mostrar ou ocultar a senha
                        ? Icons.visibility // Mostrar senha
                        : Icons.visibility_off, // Ocultar senha
                    color: const Color.fromARGB(255, 115, 32, 54),
                  ),
                  onPressed: () {
                    setState(() {
                      mostrarSenha = !mostrarSenha;
                    });
                  },
                  ),
                ),
              ),

              const SizedBox(height: 30),

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
                child: const Text('Criar Conta',
                  style:
                    TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    
                ),
              ),

              const SizedBox(height: 15),
              
              //Link para voltar para a tela de login
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text(
                  'Já tem uma conta? Entrar',
                  style: TextStyle(
                    color: Color.fromARGB(255, 115, 32, 54),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 115, 32, 54),
        centerTitle: true,
        title: const Text('Cadastro',
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

    );
  }
}