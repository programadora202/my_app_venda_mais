
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color vinho = Color.fromARGB(255, 115, 32, 54);
  static const Color fundo = Color.fromARGB(255, 255, 245, 242);

  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool mostrarSenha = false;
  bool carregando = false;

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (carregando) return;

    // Valida os campos.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = emailController.text.trim().toLowerCase();
    final senha = senhaController.text;

    setState(() {
      carregando = true;
    });

    try {
      // Realiza a autenticação pelo Firebase.
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // IMPORTANTE:
      // Não é necessário navegar manualmente para /home.
      // O main.dart identifica automaticamente o login
      // através do authStateChanges() e abre a Home.

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String mensagem;

      switch (e.code) {
        case 'invalid-email':
          mensagem = 'O e-mail informado é inválido.';
          break;

        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          mensagem = 'E-mail ou senha incorretos.';
          break;

        case 'user-disabled':
          mensagem = 'Esta conta foi desativada.';
          break;

        case 'too-many-requests':
          mensagem =
              'Muitas tentativas de acesso. Tente novamente mais tarde.';
          break;

        case 'network-request-failed':
          mensagem =
              'Erro de conexão. Verifique sua internet.';
          break;

        case 'operation-not-allowed':
          mensagem =
              'O acesso por e-mail e senha não está habilitado.';
          break;

        default:
          mensagem =
              'Não foi possível entrar. Tente novamente.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: vinho,
          behavior: SnackBarBehavior.floating,
        ),
      );

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ocorreu um erro inesperado ao realizar o login.',
          ),
          backgroundColor: vinho,
          behavior: SnackBarBehavior.floating,
        ),
      );

    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),

            child: Form(
              key: _formKey,

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // LOGO
                  Image.asset(
                    'assets/logo.png',
                    width: 210,
                  ),

                  const SizedBox(height: 30),

                  // CAMPO DE E-MAIL
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    enabled: !carregando,

                    decoration: InputDecoration(
                      labelText: 'E-mail',

                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: vinho,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: vinho,
                          width: 2,
                        ),
                      ),
                    ),

                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Informe seu e-mail.';
                      }

                      final email = valor.trim();

                      if (!RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(email)) {
                        return 'Informe um e-mail válido.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // CAMPO DE SENHA
                  TextFormField(
                    controller: senhaController,
                    obscureText: !mostrarSenha,
                    textInputAction: TextInputAction.done,
                    enabled: !carregando,

                    onFieldSubmitted: (_) {
                      login();
                    },

                    decoration: InputDecoration(
                      labelText: 'Senha',

                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: vinho,
                      ),

                      suffixIcon: IconButton(
                        icon: Icon(
                          mostrarSenha
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: vinho,
                        ),

                        onPressed: carregando
                            ? null
                            : () {
                                setState(() {
                                  mostrarSenha = !mostrarSenha;
                                });
                              },
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: vinho,
                          width: 2,
                        ),
                      ),
                    ),

                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Informe sua senha.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 25),

                  // BOTÃO ENTRAR
                  SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: vinho,

                        disabledBackgroundColor:
                            vinho.withValues(alpha: 0.6),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),

                      onPressed: carregando ? null : login,

                      child: carregando
                          ? const SizedBox(
                              width: 22,
                              height: 22,

                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'ENTRAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // CRIAR CONTA E RECUPERAR SENHA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      TextButton(
                        onPressed: carregando
                            ? null
                            : () {
                                Navigator.pushNamed(
                                  context,
                                  '/registro',
                                );
                              },

                        child: const Text(
                          'Criar Conta',
                          style: TextStyle(
                            color: vinho,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      TextButton(
                        onPressed: carregando
                            ? null
                            : () {
                                Navigator.pushNamed(
                                  context,
                                  '/esqueci_senha',
                                );
                              },

                        child: const Text(
                          'Esqueci a senha',
                          style: TextStyle(
                            color: vinho,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
