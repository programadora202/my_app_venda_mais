import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  void login(BuildContext context) {
    // Lógica de login aqui
    // Após o login bem-sucedido, navegue para a tela inicial
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool mostrarSenha = false;

  void login(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/home'); //navega para a tela inicial
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( //scaffold é o widget que fornece a estrutura básica para a tela, incluindo barra de aplicativos, corpo e outros elementos visuais.
      backgroundColor: Color.fromARGB(255, 255, 245, 242), //cor de fundo da tela
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),//adiciona um padding de 30 px em todos os lados da tela
          child: Column( 
            mainAxisAlignment: MainAxisAlignment.center, //alinha os elementos no centro da tela
            children: [ 

              // LOGO
              Image.asset(
                'assets/logo.png',
                width: 180,
              ),

              const SizedBox(height: 30),

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

              // SENHA
              TextField(
                obscureText: !mostrarSenha,
                decoration: InputDecoration(
                  labelText: 'Senha',
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

              const SizedBox(height: 25),

              // BOTÃO ENTRAR
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ButtonStyle(
                    alignment: Alignment.center,
                    backgroundColor: WidgetStateProperty.all(
                      const Color.fromARGB(255, 115, 32, 54),
                    ),
                  ),
                  onPressed: () {
                    print('Entrar clicado');
                  },
                  child: const Text('ENTRAR',
                    style: TextStyle(
                      color: Colors.white,                  
                    ),
                  ),

                ),
              ),

              const SizedBox(height: 15),

              // LINKS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/registro');
                    },
                    child: const Text('Criar Conta',
                      style: TextStyle(
                        color: Color.fromARGB(255, 115, 32, 54),
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {},
                    child: const Text('Esqueci a senha',
                      style: TextStyle(
                        color: Color.fromARGB(255, 115, 32, 54),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}