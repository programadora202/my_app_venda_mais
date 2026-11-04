
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color vinho = Color.fromARGB(255, 115, 32, 54);
  static const Color fundo = Color.fromARGB(255, 255, 245, 242);

  final _formKey = GlobalKey<FormState>();

  final _empresaController = TextEditingController();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool mostrarSenha = false;
  bool cadastrando = false;

  @override
  void dispose() {
    _empresaController.dispose();
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  InputDecoration decoracao(String titulo, {Widget? sufixo}) {
    return InputDecoration(
      labelText: titulo,
      suffixIcon: sufixo,
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
    );
  }

  String mensagemErro(FirebaseAuthException erro) {
    switch (erro.code) {
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'invalid-email':
        return 'O e-mail informado é inválido.';
      case 'weak-password':
        return 'A senha é muito fraca.';
      case 'operation-not-allowed':
        return 'O cadastro por e-mail e senha não está ativado no Firebase.';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet.';
      default:
        return 'Não foi possível criar a conta: ${erro.message ?? erro.code}';
    }
  }

  void mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> criarConta() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      cadastrando = true;
    });

    final empresa = _empresaController.text.trim();
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    User? usuarioCriado;

    try {
      // 1. Criar a conta no Firebase Authentication
      final credencial =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      usuarioCriado = credencial.user;

      if (usuarioCriado == null) {
        throw Exception('O Firebase não retornou o usuário criado.');
      }

      // 2. Atualizar o nome no Firebase Authentication
      await usuarioCriado.updateDisplayName(nome);

      // 3. Salvar os dados do perfil no Cloud Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuarioCriado.uid)
          .set({
        'uid': usuarioCriado.uid,
        'nomeEmpresa': empresa,
        'nome': nome,
        'email': email,
        'dataCadastro': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // 4. Informar que o cadastro foi realizado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta criada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // 5. Entrar na Home com o nome do usuário
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
        arguments: nome,
      );
    } on FirebaseAuthException catch (erro) {
      mostrarMensagem(mensagemErro(erro));
    } on FirebaseException catch (erro) {
      mostrarMensagem(
        'A conta foi criada, mas não foi possível salvar '
        'o perfil no banco de dados: ${erro.message ?? erro.code}. '
        'Entre em contato com o suporte antes de tentar outro cadastro.',
      );
    } catch (erro) {
      mostrarMensagem('Ocorreu um erro: $erro');
    } finally {
      if (mounted) {
        setState(() {
          cadastrando = false;
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
          'Cadastro',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: cadastrando
              ? null
              : () => Navigator.pop(context),
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
                // LOGO
                Image.asset(
                  'assets/logo.png',
                  width: 180,
                ),

                const SizedBox(height: 25),

                // NOME DA EMPRESA
                TextFormField(
                  controller: _empresaController,
                  textCapitalization: TextCapitalization.words,
                  decoration: decoracao('Nome da Empresa'),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Informe o nome da empresa';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // NOME DO USUÁRIO
                TextFormField(
                  controller: _nomeController,
                  textCapitalization: TextCapitalization.words,
                  decoration: decoracao('Nome'),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Informe seu nome';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // E-MAIL
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: decoracao('E-mail'),
                  validator: (valor) {
                    final email = valor?.trim() ?? '';

                    if (email.isEmpty) {
                      return 'Informe seu e-mail';
                    }

                    if (!RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(email)) {
                      return 'Informe um e-mail válido';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // SENHA
                TextFormField(
                  controller: _senhaController,
                  obscureText: !mostrarSenha,
                  decoration: decoracao(
                    'Senha',
                    sufixo: IconButton(
                      icon: Icon(
                        mostrarSenha
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: vinho,
                      ),
                      onPressed: () {
                        setState(() {
                          mostrarSenha = !mostrarSenha;
                        });
                      },
                    ),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Informe uma senha';
                    }

                    if (valor.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // CONFIRMAR SENHA
                TextFormField(
                  controller: _confirmarSenhaController,
                  obscureText: !mostrarSenha,
                  decoration: decoracao(
                    'Confirmar Senha',
                    sufixo: IconButton(
                      icon: Icon(
                        mostrarSenha
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: vinho,
                      ),
                      onPressed: () {
                        setState(() {
                          mostrarSenha = !mostrarSenha;
                        });
                      },
                    ),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Confirme sua senha';
                    }

                    if (valor != _senhaController.text) {
                      return 'As senhas não coincidem';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // BOTÃO CRIAR CONTA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: cadastrando ? null : criarConta,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vinho,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: cadastrando
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Criar Conta',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 15),

                // VOLTAR PARA O LOGIN
                TextButton(
                  onPressed: cadastrando
                      ? null
                      : () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        },
                  child: const Text(
                    'Já tem uma conta? Entrar',
                    style: TextStyle(
                      color: vinho,
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
