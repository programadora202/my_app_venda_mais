
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({
    super.key,
    required this.userName,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _saindo = false;
  bool _redirecionando = false;

  static const Color vinho = Color.fromARGB(255, 115, 32, 54);
  static const Color fundo = Color.fromARGB(255, 255, 245, 242);
  static const Color card = Color.fromARGB(255, 247, 232, 225);

  // Redireciona para o login e remove as telas anteriores.
  void _irParaLogin() {
    if (_redirecionando || !mounted) return;

    _redirecionando = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    });
  }

  // Encerra a sessão do Firebase.
  Future<void> _fazerLogout() async {
    if (_saindo) return;

    setState(() {
      _saindo = true;
    });

    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      _irParaLogin();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saindo = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível sair da conta. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Card de navegação.
  Widget _cardMenu({
    required String titulo,
    required IconData icone,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icone,
              color: vinho,
              size: 85,
            ),
            const SizedBox(height: 15),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Resumo financeiro das vendas do dia.
  Widget _resumoDeHoje(String usuarioId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 254, 254),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Resumo de hoje:',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/dashboard');
                },
                child: const Text(
                  'Ver mais',
                  style: TextStyle(
                    color: vinho,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('vendas')
                .where('usuarioId', isEqualTo: usuarioId)
                .snapshots(),

            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text(
                  'Não foi possível carregar o resumo de vendas.',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: CircularProgressIndicator(
                      color: vinho,
                    ),
                  ),
                );
              }

              double totalVendido = 0;

              final agora = DateTime.now();

              final inicioDia = DateTime(
                agora.year,
                agora.month,
                agora.day,
              );

              final fimDia = DateTime(
                agora.year,
                agora.month,
                agora.day + 1,
              );

              for (final documento in snapshot.data!.docs) {
                final venda = documento.data();

                // Considera somente vendas concluídas.
                if (venda['status'] != 'concluida') {
                  continue;
                }

                final data = venda['dataVenda'];

                if (data is! Timestamp) {
                  continue;
                }

                final dataVenda = data.toDate().toLocal();

                // Verifica se a venda pertence ao dia atual.
                if (dataVenda.isBefore(inicioDia) ||
                    !dataVenda.isBefore(fimDia)) {
                  continue;
                }

                final valor = venda['total'];

                if (valor is num) {
                  totalVendido += valor.toDouble();
                }
              }

              final valorFormatado = totalVendido
                  .toStringAsFixed(2)
                  .replaceAll('.', ',');

              return Row(
                children: [
                  const Icon(
                    Icons.shopping_cart,
                    color: vinho,
                    size: 35,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      'Vendas de hoje: R\$ $valorFormatado',
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Aguarda o Firebase restaurar a sessão.
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: fundo,
            body: Center(
              child: CircularProgressIndicator(
                color: vinho,
              ),
            ),
          );
        }

        // Se não existir usuário autenticado, volta ao login.
        final usuario = authSnapshot.data;

        if (usuario == null) {
          _irParaLogin();

          return const Scaffold(
            backgroundColor: fundo,
            body: Center(
              child: CircularProgressIndicator(
                color: vinho,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: fundo,

          appBar: AppBar(
            toolbarHeight: 70,
            title: Text(
              'Olá, ${widget.userName}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: vinho,
            centerTitle: true,

            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 20,
                  icon: const Icon(
                    Icons.people,
                    color: vinho,
                  ),
                  onPressed: () {
                    // Ação futura do botão de perfil.
                  },
                ),
              ),
            ),

            actions: [
              IconButton(
                tooltip: 'Sair da conta',
                icon: _saindo
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                onPressed: _saindo ? null : _fazerLogout,
              ),
            ],
          ),

          body: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            children: [
              // NOVA VENDA
              _cardMenu(
                titulo: 'NOVA VENDA',
                icone: Icons.shopping_bag,
                onTap: () {
                  Navigator.pushNamed(context, '/new_sale');
                },
              ),

              const SizedBox(height: 20),

              // ESTOQUE E PRODUTOS
              _cardMenu(
                titulo: 'ESTOQUE E PRODUTOS',
                icone: Icons.inventory_2_outlined,
                onTap: () {
                  Navigator.pushNamed(context, '/storage');
                },
              ),

              const SizedBox(height: 20),

              // RESUMO DE HOJE
              _resumoDeHoje(usuario.uid),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
