
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  static const Color vinho = Color.fromARGB(255, 115, 32, 54);
  static const Color fundo = Color.fromARGB(255, 255, 245, 242);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool enviando = false;
  bool emailEnviado = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String mensagemErro(FirebaseAuthException erro) {
    switch (erro.code) {
      case 'invalid-email':
        return 'O e-mail informado é inválido.';

      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';

      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet.';

      case 'operation-not-allowed':
        return 'A recuperação de senha não está disponível.';

      default:
        return 'Não foi possível enviar o e-mail. '
            'Tente novamente mais tarde.';
    }
  }

  Future<void> recuperarSenha() async {
    // Verifica se o e-mail foi preenchido corretamente
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      enviando = true;
      emailEnviado = false;
    });

    try {
      final email = _emailController.text.trim();

      // Envia o link de recuperação pelo Firebase
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      setState(() {
        emailEnviado = true;
      });

      // Exibe a mensagem de confirmação
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Solicitação realizada! Verifique sua caixa de entrada e spam.',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );
    } on FirebaseAuthException catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagemErro(erro)),
          backgroundColor: Colors.red,
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ocorreu um erro inesperado. Tente novamente.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          enviando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,

      appBar: AppBar(
        backgroundColor: vinho,
        centerTitle: true,
        title: const Text(
          'Recuperação de conta',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                // LOGO
                Image.asset(
                  'assets/logo.png',
                  width: 210,
                ),

                const SizedBox(height: 25),

                // INSTRUÇÕES
                const Text(
                  'Esqueceu sua senha?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: vinho,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Informe o e-mail cadastrado no Venda+. '
                  'Enviaremos um link para você redefinir sua senha.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 30),

                // CAMPO DE E-MAIL
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  enabled: !enviando,
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
                    final email = valor?.trim() ?? '';

                    if (email.isEmpty) {
                      return 'Informe seu e-mail';
                    }

                    final emailValido = RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(email);

                    if (!emailValido) {
                      return 'Informe um e-mail válido';
                    }

                    return null;
                  },
                  onFieldSubmitted: (_) {
                    if (!enviando) {
                      recuperarSenha();
                    }
                  },
                ),

                const SizedBox(height: 30),

                // BOTÃO DE RECUPERAÇÃO
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: enviando ? null : recuperarSenha,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vinho,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: enviando
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'ENVIAR LINK DE RECUPERAÇÃO',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                // MENSAGEM APÓS A SOLICITAÇÃO
                if (emailEnviado) ...[
                  const SizedBox(height: 25),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255, 232, 245, 233,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.mark_email_read_outlined,
                          color: Colors.green,
                          size: 35,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Solicitação enviada!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Se houver uma conta associada a esse '
                          'e-mail, você receberá um link para '
                          'redefinir sua senha. Verifique também '
                          'a pasta de spam.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 25),

                // VOLTAR PARA O LOGIN
                TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Voltar para o Login',
                    style: TextStyle(
                      color: vinho,
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
