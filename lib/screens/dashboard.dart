
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  static const Color vinho = Color.fromARGB(255, 115, 32, 54);
  static const Color fundo = Color.fromARGB(255, 255, 245, 242);

  int periodoSelecionado = 0;

  String moeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  DateTime inicioDia(DateTime data) {
    return DateTime(data.year, data.month, data.day);
  }

  DateTime get inicioGrafico {
    final hoje = inicioDia(DateTime.now());

    if (periodoSelecionado == 1) {
      return DateTime(hoje.year, hoje.month, hoje.day - 6);
    }

    if (periodoSelecionado == 2) {
      return DateTime(hoje.year, hoje.month, hoje.day - 29);
    }

    return hoje;
  }

  Widget containerBranco(Widget conteudo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: conteudo,
    );
  }

  // Calcula as vendas e os produtos do período.
  Map<String, dynamic> calcularRelatorio(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documentos,
    DateTime inicio,
    DateTime fim,
  ) {
    double totalVendido = 0;
    int quantidadeVendas = 0;
    int quantidadePecas = 0;

    final Map<String, Map<String, dynamic>> produtos = {};

    for (final documento in documentos) {
      final venda = documento.data();

      if (venda['status'] != 'concluida') {
        continue;
      }

      final data = venda['dataVenda'];

      if (data is! Timestamp) {
        continue;
      }

      final dataVenda = data.toDate();

      if (dataVenda.isBefore(inicio) ||
          !dataVenda.isBefore(fim)) {
        continue;
      }

      final total = venda['total'];

      if (total is num) {
        totalVendido += total.toDouble();
      }

      quantidadeVendas++;

      final itens = venda['itens'];

      if (itens is! List) {
        continue;
      }

      for (final item in itens) {
        if (item is! Map) {
          continue;
        }

        final id = (item['produtoId'] ?? '').toString();
        final nome = (item['nome'] ?? 'Produto').toString();
        final tamanho = (item['tamanho'] ?? '').toString();

        final quantidade = item['quantidade'] is num
            ? (item['quantidade'] as num).toInt()
            : 0;

        final subtotal = item['subtotal'] is num
            ? (item['subtotal'] as num).toDouble()
            : 0.0;

        quantidadePecas += quantidade;

        // Identifica cada produto e tamanho separadamente.
        final chave = '$id|$tamanho';

        if (!produtos.containsKey(chave)) {
          produtos[chave] = {
            'nome': nome,
            'tamanho': tamanho,
            'quantidade': 0,
            'subtotal': 0.0,
          };
        }

        produtos[chave]!['quantidade'] =
            (produtos[chave]!['quantidade'] as int) + quantidade;

        produtos[chave]!['subtotal'] =
            (produtos[chave]!['subtotal'] as double) + subtotal;
      }
    }

    final listaProdutos = produtos.values.toList();

    listaProdutos.sort(
      (a, b) => (b['quantidade'] as int)
          .compareTo(a['quantidade'] as int),
    );

    return {
      'total': totalVendido,
      'vendas': quantidadeVendas,
      'pecas': quantidadePecas,
      'produtos': listaProdutos,
    };
  }

  Widget linhaInformacao(
    String titulo,
    String valor,
    IconData icone,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icone, color: vinho, size: 25),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: vinho,
            ),
          ),
        ],
      ),
    );
  }

  Widget listaProdutos(
    List<Map<String, dynamic>> produtos,
  ) {
    if (produtos.isEmpty) {
      return containerBranco(
        const Text(
          'Nenhum produto vendido hoje.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return containerBranco(
      Column(
        children: produtos.map((produto) {
          final nome = produto['nome'].toString();
          final tamanho = produto['tamanho'].toString();
          final quantidade = produto['quantidade'] as int;
          final subtotal = produto['subtotal'] as double;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.checkroom,
                      color: vinho,
                      size: 28,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nome,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            'Tamanho: $tamanho',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),

                          Text(
                            '$quantidade unidade(s)',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      moeda(subtotal),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: vinho,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                const Divider(height: 20),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget graficoProdutos(
    List<Map<String, dynamic>> produtos,
  ) {
    if (produtos.isEmpty) {
      return containerBranco(
        const Padding(
          padding: EdgeInsets.all(15),
          child: Text(
            'Nenhuma venda registrada neste período.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Cinco combinações de produto + tamanho mais vendidas.
    final top5 = produtos.take(5).toList();

    final maiorQuantidade = top5
        .map((produto) => produto['quantidade'] as int)
        .reduce((a, b) => a > b ? a : b);

    return containerBranco(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quantidade de peças vendidas',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: maiorQuantidade.toDouble() + 2,
                alignment: BarChartAlignment.spaceAround,

                borderData: FlBorderData(show: false),

                gridData: const FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),

                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (valor, meta) {
                        if (valor != valor.roundToDouble()) {
                          return const SizedBox.shrink();
                        }

                        return Text(
                          valor.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),

                barGroups: List.generate(top5.length, (indice) {
                  final quantidade =
                      top5[indice]['quantidade'] as int;

                  return BarChartGroupData(
                    x: indice,
                    barRods: [
                      BarChartRodData(
                        toY: quantidade.toDouble(),
                        color: vinho,
                        width: 25,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Identificação completa de cada barra.
          ...List.generate(top5.length, (indice) {
            final produto = top5[indice];

            final nome = produto['nome'].toString();
            final tamanho = produto['tamanho'].toString();
            final quantidade = produto['quantidade'] as int;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: vinho,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${indice + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      '$nome — Tamanho $tamanho',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    '$quantidade un.',
                    style: const TextStyle(
                      color: vinho,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final agora = DateTime.now();

    final hoje = inicioDia(agora);

    final amanha = DateTime(
      hoje.year,
      hoje.month,
      hoje.day + 1,
    );

    return Scaffold(
      backgroundColor: fundo,

      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: vinho,
        centerTitle: true,

        title: const Text(
          'Desempenho',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            // Volta para a Home preservando o nome do usuário.
            Navigator.pop(context);
          },
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (!context.mounted) return;

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('vendas')
            .where(
              'dataVenda',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(inicioGrafico),
            )
            .where(
              'dataVenda',
              isLessThan: Timestamp.fromDate(amanha),
            )
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar vendas:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: vinho),
            );
          }

          final documentos = snapshot.data!.docs;

          final relatorioHoje = calcularRelatorio(
            documentos,
            hoje,
            amanha,
          );

          final relatorioGrafico = calcularRelatorio(
            documentos,
            inicioGrafico,
            amanha,
          );

          final produtosHoje =
              (relatorioHoje['produtos'] as List)
                  .cast<Map<String, dynamic>>();

          final produtosGrafico =
              (relatorioGrafico['produtos'] as List)
                  .cast<Map<String, dynamic>>();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Relatório de vendas do dia',
                style: TextStyle(
                  color: vinho,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // TOTAL VENDIDO HOJE
              containerBranco(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL VENDIDO HOJE',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      moeda(relatorioHoje['total'] as double),
                      style: const TextStyle(
                        color: vinho,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),
                    const Divider(),

                    linhaInformacao(
                      'Vendas realizadas',
                      '${relatorioHoje['vendas']}',
                      Icons.receipt_long_outlined,
                    ),

                    linhaInformacao(
                      'Peças vendidas',
                      '${relatorioHoje['pecas']}',
                      Icons.inventory_2_outlined,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // PRODUTOS VENDIDOS HOJE
              const Text(
                'Produtos vendidos hoje',
                style: TextStyle(
                  color: vinho,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              listaProdutos(produtosHoje),

              const SizedBox(height: 28),

              // GRÁFICO DOS MAIS VENDIDOS
              const Text(
                'Produtos mais vendidos',
                style: TextStyle(
                  color: vinho,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Hoje'),
                    selected: periodoSelecionado == 0,
                    selectedColor:
                        const Color.fromARGB(255, 247, 232, 225),
                    onSelected: (_) {
                      setState(() {
                        periodoSelecionado = 0;
                      });
                    },
                  ),

                  ChoiceChip(
                    label: const Text('7 dias'),
                    selected: periodoSelecionado == 1,
                    selectedColor:
                        const Color.fromARGB(255, 247, 232, 225),
                    onSelected: (_) {
                      setState(() {
                        periodoSelecionado = 1;
                      });
                    },
                  ),

                  ChoiceChip(
                    label: const Text('30 dias'),
                    selected: periodoSelecionado == 2,
                    selectedColor:
                        const Color.fromARGB(255, 247, 232, 225),
                    onSelected: (_) {
                      setState(() {
                        periodoSelecionado = 2;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 15),

              graficoProdutos(produtosGrafico),

              const SizedBox(height: 25),
            ],
          );
        },
      ),
    );
  }
}
