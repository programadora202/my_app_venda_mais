import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool mostrarSenha = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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

              const SizedBox(height: 20),

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
                    onPressed: () {},
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