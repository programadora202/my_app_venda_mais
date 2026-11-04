
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  final String userName;

  const HomeScreen({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 245, 242),

      appBar: AppBar(
        toolbarHeight: 70,
        title: Text(
          "Olá, $userName",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 115, 32, 54),
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
                color: Color.fromARGB(255, 115, 32, 54),
              ),
              onPressed: () {
                // Ação futura do botão de perfil
              },
            ),
          ),
        ),

        // Botão de sair
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                '/login',
              );
            },
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        children: [
          // CONTAINER NOVA VENDA
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/new_sale');
            },
            child: Container(
              height: 200,
              width: 180,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 247, 232, 225),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag,
                      color: Color.fromARGB(255, 115, 32, 54),
                      size: 100,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'NOVA VENDA',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // CONTAINER ESTOQUE E PRODUTOS
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/storage');
            },
            child: Container(
              height: 200,
              width: 180,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 247, 232, 225),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      color: Color.fromARGB(255, 115, 32, 54),
                      size: 100,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'ESTOQUE E PRODUTOS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // CONTAINER RESUMO DE HOJE
          Container(
            width: 180,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 254, 254),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Navigator.pushNamed(
                          context,
                          '/dashboard',
                        );
                      },
                      child: const Text(
                        'Ver mais',
                        style: TextStyle(
                          color: Color.fromARGB(255, 115, 32, 54),
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // CONSULTA DAS VENDAS NO FIREBASE
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('vendas')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text(
                        'Erro ao carregar vendas.',
                        style: TextStyle(color: Colors.red),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 115, 32, 54),
                        ),
                      );
                    }

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

                    double totalVendido = 0;

                    for (final documento in snapshot.data!.docs) {
                      final venda = documento.data();

                      // Considera somente vendas concluídas
                      if (venda['status'] != 'concluida') {
                        continue;
                      }

                      final data = venda['dataVenda'];

                      if (data is! Timestamp) {
                        continue;
                      }

                      final dataVenda = data.toDate();

                      // Verifica se a venda foi feita hoje
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
                          color: Color.fromARGB(255, 115, 32, 54),
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
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
