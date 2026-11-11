
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
  static const Color rosaClaro = Color.fromARGB(255, 247, 232, 225);

  int periodoSelecionado = 0;
  bool saindo = false;

  String moeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  DateTime inicioDia(DateTime data) {
    return DateTime(data.year, data.month, data.day);
  }

  DateTime get inicioGrafico {
    final hoje = inicioDia(DateTime.now());

    if (periodoSelecionado == 1) {
      return hoje.subtract(const Duration(days: 6));
    }

    if (periodoSelecionado == 2) {
      return hoje.subtract(const Duration(days: 29));
    }

    return hoje;
  }

  DateTime get fimDia {
    final hoje = inicioDia(DateTime.now());
    return hoje.add(const Duration(days: 1));
  }

  Future<void> sairDaConta() async {
    if (saindo) return;

    setState(() {
      saindo = true;
    });

    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saindo = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível sair da conta. Tente novamente.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  // Calcula os dados das vendas dentro do período selecionado.
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

      if (itens is! List) continue;

      for (final item in itens) {
        if (item is! Map) continue;

        final id = (item['produtoId'] ?? '').toString();
        final nome = (item['nome'] ?? 'Produto').toString();
        final tamanho = (item['tamanho'] ?? '').toString();

        final quantidade = item['quantidade'] is num
            ? (item['quantidade'] as num).toInt()
            : 0;

        // Usa o subtotal salvo ou calcula pelo preço e quantidade.
        double subtotal = 0;

        if (item['subtotal'] is num) {
          subtotal = (item['subtotal'] as num).toDouble();
        } else if (item['preco'] is num) {
          subtotal =
              (item['preco'] as num).toDouble() * quantidade;
        }

        quantidadePecas += quantidade;

        // Agrupa produto e tamanho separadamente.
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

  String textoPagamento(String? forma) {
    switch (forma) {
      case 'credito':
        return 'Cartão de crédito';
      case 'debito':
        return 'Cartão de débito';
      case 'dinheiro_pix':
        return 'Dinheiro / Pix';
      default:
        return 'Pagamento não informado';
    }
  }

  IconData iconePagamento(String? forma) {
    switch (forma) {
      case 'credito':
      case 'debito':
        return Icons.credit_card;
      case 'dinheiro_pix':
        return Icons.payments_outlined;
      default:
        return Icons.help_outline;
    }
  }

  // Compras realizadas hoje.
  Widget listaComprasHoje(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documentos,
    DateTime inicio,
    DateTime fim,
  ) {
    final compras = documentos.where((documento) {
      final venda = documento.data();

      if (venda['status'] != 'concluida') {
        return false;
      }

      final data = venda['dataVenda'];

      if (data is! Timestamp) return false;

      final dataVenda = data.toDate();

      return !dataVenda.isBefore(inicio) &&
          dataVenda.isBefore(fim);
    }).toList();

    compras.sort((a, b) {
      final dataA =
          (a.data()['dataVenda'] as Timestamp).toDate();

      final dataB =
          (b.data()['dataVenda'] as Timestamp).toDate();

      return dataB.compareTo(dataA);
    });

    if (compras.isEmpty) {
      return containerBranco(
        const Text(
          'Nenhuma compra realizada hoje.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Column(
      children: compras.map((documento) {
        final venda = documento.data();

        final forma = venda['formaPagamento']?.toString();

        final total = venda['total'] is num
            ? (venda['total'] as num).toDouble()
            : 0.0;

        final dataVenda =
            (venda['dataVenda'] as Timestamp).toDate();

        final hora =
            '${dataVenda.hour.toString().padLeft(2, '0')}:'
            '${dataVenda.minute.toString().padLeft(2, '0')}';

        final itens = venda['itens'] is List
            ? venda['itens'] as List
            : [];

        final produtosCompra = itens
            .where((item) => item is Map)
            .map((item) {
          final nome = (item['nome'] ?? 'Produto').toString();
          final tamanho = (item['tamanho'] ?? '').toString();

          final quantidade = item['quantidade'] is num
              ? (item['quantidade'] as num).toInt()
              : 0;

          final descricaoTamanho =
              tamanho.isNotEmpty ? ' (Tam. $tamanho)' : '';

          return '$nome$descricaoTamanho × $quantidade';
        }).toList();

        return Card(
          color: Colors.white,
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.receipt_long,
                            color: vinho,
                            size: 20,
                          ),
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              'Compra às $hora',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      moeda(total),
                      style: const TextStyle(
                        color: vinho,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                const Text(
                  'Produtos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 7),

                if (produtosCompra.isEmpty)
                  const Text(
                    'Produtos não identificados',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  )
                else
                  ...produtosCompra.map(
                    (produto) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.checkroom,
                            size: 17,
                            color: vinho,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              produto,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: rosaClaro,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        iconePagamento(forma),
                        color: vinho,
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          textoPagamento(forma),
                          style: const TextStyle(
                            color: vinho,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Produtos vendidos no dia.
  Widget listaProdutos(List<Map<String, dynamic>> produtos) {
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

  // Gráfico dos cinco produtos mais vendidos.
  Widget graficoProdutos(List<Map<String, dynamic>> produtos) {
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

    final top5 = produtos.take(5).toList();

    const coresBarras = [
      Color(0xFF732036),
      Color(0xFFD97757),
      Color(0xFFE6B84A),
      Color(0xFF548B83),
      Color(0xFF5579B8),
    ];

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
                        color: coresBarras[
                            indice % coresBarras.length],
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
                      color: coresBarras[
                          indice % coresBarras.length],
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

  // Botões de seleção do período.
  Widget filtrosPeriodo() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: const Text('Hoje'),
          selected: periodoSelecionado == 0,
          selectedColor: rosaClaro,
          onSelected: (_) {
            setState(() {
              periodoSelecionado = 0;
            });
          },
        ),
        ChoiceChip(
          label: const Text('7 dias'),
          selected: periodoSelecionado == 1,
          selectedColor: rosaClaro,
          onSelected: (_) {
            setState(() {
              periodoSelecionado = 1;
            });
          },
        ),
        ChoiceChip(
          label: const Text('30 dias'),
          selected: periodoSelecionado == 2,
          selectedColor: rosaClaro,
          onSelected: (_) {
            setState(() {
              periodoSelecionado = 2;
            });
          },
        ),
      ],
    );
  }

  Widget tituloSecao(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        color: vinho,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;

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
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Sair da conta',
            onPressed: saindo ? null : sairDaConta,
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
      ),

      body: usuario == null
          ? const Center(
              child: Text(
                'Faça login para visualizar suas vendas.',
              ),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              // Consulta somente as vendas do usuário conectado.
              // O filtro de datas é realizado no relatório.
              stream: FirebaseFirestore.instance
                  .collection('vendas')
                  .where(
                    'usuarioId',
                    isEqualTo: usuario.uid,
                  )
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Erro ao carregar vendas:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState ==
                        ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: vinho,
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: Text(
                      'Não foi possível carregar os dados.',
                    ),
                  );
                }

                final documentos = snapshot.data!.docs;

                final hoje = inicioDia(DateTime.now());
                final amanha = hoje.add(
                  const Duration(days: 1),
                );

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
                    // RESUMO DO DIA
                    const Text(
                      'Relatório de vendas do dia',
                      style: TextStyle(
                        color: vinho,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

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
                            moeda(
                              relatorioHoje['total'] as double,
                            ),
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

                    const SizedBox(height: 28),

                    // COMPRAS DE HOJE
                    tituloSecao('Compras de hoje'),

                    const SizedBox(height: 12),

                    listaComprasHoje(
                      documentos,
                      hoje,
                      amanha,
                    ),

                    const SizedBox(height: 28),

                    // PRODUTOS VENDIDOS HOJE
                    tituloSecao('Produtos vendidos hoje'),

                    const SizedBox(height: 12),

                    listaProdutos(produtosHoje),

                    const SizedBox(height: 28),

                    // GRÁFICO
                    tituloSecao('Produtos mais vendidos'),

                    const SizedBox(height: 12),

                    filtrosPeriodo(),

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
