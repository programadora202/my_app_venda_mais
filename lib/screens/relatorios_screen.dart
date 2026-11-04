import 'dart:math' as math;
import 'package:flutter/material.dart';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  // Cores padrão do layout Venda+
  static const Color corVinho = Color.fromARGB(255, 115, 32, 54);
  static const Color corFundo = Color.fromARGB(255, 255, 245, 242);
  static const Color corCardSecundario = Color.fromARGB(255, 244, 228, 223);
  static const Color corLinhaAnterior = Color.fromARGB(255, 224, 122, 118);

  // Filtro do Gráfico Comparativo: 'semana' ou 'mes'
  String modoComparacao = 'semana';

  // Filtro do Top Vendas: 'dia', 'semana', 'mes', 'ano'
  String filtroTopVendas = 'semana';

  // Ponto selecionado no gráfico (opcional para tooltip ao tocar)
  int? indicePontoSelecionado;

  // Dados simulados (serão substituídos/alimentados pelo Cloud Firestore assim que configurado)
  final List<String> labelsSemana = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
  final List<double> vendasSemanaAtual = [420, 680, 590, 890, 1250, 1680, 940];
  final List<double> vendasSemanaPassada = [380, 510, 640, 720, 980, 1420, 810];

  final List<String> labelsMes = [
    '01', '05', '10', '15', '20', '25', '30'
  ];
  final List<double> vendasMesAtual = [2150, 3400, 2980, 4600, 5120, 6340, 5890];
  final List<double> vendasMesPassado = [1900, 2850, 3100, 3950, 4400, 5200, 4980];

  final Map<String, List<Map<String, dynamic>>> topProdutosPorPeriodo = {
    'dia': [
      {
        'nome': 'Camiseta Basic Masculina',
        'tamanhos': 'Tamanho: P, M, G, GG',
        'estoque': 15,
        'precoUnitario': 59.90,
        'unidadesVendidas': 8,
        'totalVendido': 479.20,
      },
      {
        'nome': 'Calça Jeans Skinny',
        'tamanhos': 'Tamanho: 38, 40, 42, 44',
        'estoque': 12,
        'precoUnitario': 129.90,
        'unidadesVendidas': 4,
        'totalVendido': 519.60,
      },
      {
        'nome': 'Blusa Tricot Canelada',
        'tamanhos': 'Tamanho: P, M, G',
        'estoque': 9,
        'precoUnitario': 89.90,
        'unidadesVendidas': 3,
        'totalVendido': 269.70,
      },
      {
        'nome': 'Jaqueta Jeans Oversized',
        'tamanhos': 'Tamanho: M, G',
        'estoque': 6,
        'precoUnitario': 179.90,
        'unidadesVendidas': 2,
        'totalVendido': 359.80,
      },
      {
        'nome': 'Saia Midi Alfaiataria',
        'tamanhos': 'Tamanho: P, M, G',
        'estoque': 8,
        'precoUnitario': 119.90,
        'unidadesVendidas': 1,
        'totalVendido': 119.90,
      },
    ],
    'semana': [
      {
        'nome': 'Camiseta Basic Masculina',
        'tamanhos': 'Tamanho: P, M, G, GG',
        'estoque': 15,
        'precoUnitario': 59.90,
        'unidadesVendidas': 42,
        'totalVendido': 2515.80,
      },
      {
        'nome': 'Calça Jeans Skinny',
        'tamanhos': 'Tamanho: 38, 40, 42, 44',
        'estoque': 12,
        'precoUnitario': 129.90,
        'unidadesVendidas': 18,
        'totalVendido': 2338.20,
      },
      {
        'nome': 'Vestido Midi Floral',
        'tamanhos': 'Tamanho: P, M, G',
        'estoque': 10,
        'precoUnitario': 149.90,
        'unidadesVendidas': 11,
        'totalVendido': 1648.90,
      },
      {
        'nome': 'Blusa Tricot Canelada',
        'tamanhos': 'Tamanho: P, M, G',
        'estoque': 9,
        'precoUnitario': 89.90,
        'unidadesVendidas': 9,
        'totalVendido': 809.10,
      },
      {
        'nome': 'Jaqueta Jeans Oversized',
        'tamanhos': 'Tamanho: M, G',
        'estoque': 6,
        'precoUnitario': 179.90,
        'unidadesVendidas': 6,
        'totalVendido': 1079.40,
      },
    ],
    'mes': [
      {
        'nome': 'Camiseta Basic Masculina',
        'tamanhos': 'Tamanho: P, M, G, GG',
        'estoque': 15,
        'precoUnitario': 59.90,
        'unidadesVendidas': 165,
        'totalVendido': 9883.50,
      },
      {
        'nome': 'Calça Jeans Skinny',
        'tamanhos': 'Tamanho: 38, 40, 42, 44',
        'estoque': 12,
        'precoUnitario': 129.90,
        'unidadesVendidas': 74,
        'totalVendido': 9612.60,
      },
      {
        'nome': 'Vestido Midi Floral',
        'tamanhos': 'Tamanho: P, M, G',
        'estoque': 10,
        'precoUnitario': 149.90,
        'unidadesVendidas': 48,
        'totalVendido': 7195.20,
      },
      {
        'nome': 'Jaqueta Jeans Oversized',
        'tamanhos': 'Tamanho: M, G',
        'estoque': 6,
        'precoUnitario': 179.90,
        'unidadesVendidas': 21,
        'totalVendido': 3777.90,
      },
      {
        'nome': 'Blusa Tricot Canelada',
        'tamanhos': 'Tamanho: P, M, G',
        'estoque': 9,
        'precoUnitario': 89.90,
        'unidadesVendidas': 19,
        'totalVendido': 1708.10,
      },
    ],
    'ano': [
      {
        'nome': 'Camiseta Basic Masculina',
        'tamanhos': 'Tamanho: P, M, G, GG',
        'estoque': 15,
        'precoUnitario': 59.90,
        'unidadesVendidas': 1840,
        'totalVendido': 110216.00,
      },
      {
        'nome': 'Calça Jeans Skinny',
        'tamanhos': 'Tamanho: 38, 40, 42, 44',
        'estoque': 12,
        'precoUnitario': 129.90,
        'unidadesVendidas': 890,
        'totalVendido': 115611.00,
      },
      {
        'nome': 'Vestido Midi Floral',
        'tamanhos': 'Tamanho: P, M, G',
        'estoque': 10,
        'precoUnitario': 149.90,
        'unidadesVendidas': 540,
        'totalVendido': 80946.00,
      },
      {
        'nome': 'Blusa Tricot Canelada',
        'tamanhos': 'Tamanho: P, M, G',
        'estoque': 9,
        'precoUnitario': 89.90,
        'unidadesVendidas': 495,
        'totalVendido': 44500.50,
      },
      {
        'nome': 'Jaqueta Jeans Oversized',
        'tamanhos': 'Tamanho: M, G',
        'estoque': 6,
        'precoUnitario': 179.90,
        'unidadesVendidas': 310,
        'totalVendido': 55769.00,
      },
    ],
  };

  String formatarMoeda(double valor) {
    final partes = valor.toStringAsFixed(2).split('.');
    final inteiro = partes[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'R\$ $inteiro,${partes[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isSemana = modoComparacao == 'semana';
    final List<String> labels = isSemana ? labelsSemana : labelsMes;
    final List<double> serieAtual = isSemana ? vendasSemanaAtual : vendasMesAtual;
    final List<double> serieAnterior = isSemana ? vendasSemanaPassada : vendasMesPassado;

    final double totalAtual = serieAtual.fold(0, (a, b) => a + b);
    final double totalAnterior = serieAnterior.fold(0, (a, b) => a + b);
    final double variacaoPercentual = totalAnterior > 0
        ? ((totalAtual - totalAnterior) / totalAnterior) * 100
        : 0;

    final List<Map<String, dynamic>> listaTopProdutos =
        (topProdutosPorPeriodo[filtroTopVendas] ?? []).take(5).toList();

    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        backgroundColor: corVinho,
        centerTitle: true,
        title: const Text(
          'Resultados',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. CARD DO GRÁFICO COMPARATIVO DE VENDAS
            // ==========================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: corVinho.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título + Alternador Semana / Mês
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Comparativo de Vendas',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: corVinho,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: corCardSecundario,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(3),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildBotaoAlternadorGrafico(
                              titulo: 'Semana',
                              selecionado: isSemana,
                              onTap: () {
                                setState(() {
                                  modoComparacao = 'semana';
                                  indicePontoSelecionado = null;
                                });
                              },
                            ),
                            _buildBotaoAlternadorGrafico(
                              titulo: 'Mês',
                              selecionado: !isSemana,
                              onTap: () {
                                setState(() {
                                  modoComparacao = 'mes';
                                  indicePontoSelecionado = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Resumo dos totais comparados
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: corFundo,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSemana ? 'Semana Atual' : 'Mês Atual',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              formatarMoeda(totalAtual),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: corVinho,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSemana ? 'Semana Passada' : 'Mês Passado',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              formatarMoeda(totalAnterior),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: variacaoPercentual >= 0
                                ? const Color.fromARGB(255, 40, 130, 75)
                                : Colors.red.shade700,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '${variacaoPercentual >= 0 ? '+' : ''}${variacaoPercentual.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Legenda das 2 linhas (estilo da imagem de referência)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildItemLegenda(
                        cor: corVinho,
                        texto: isSemana ? 'Semana Atual' : 'Mês Atual',
                      ),
                      const SizedBox(width: 16),
                      _buildItemLegenda(
                        cor: corLinhaAnterior,
                        texto: isSemana ? 'Semana Passada' : 'Mês Passado',
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Área do Gráfico de Linhas Comparativo
                  SizedBox(
                    height: 210,
                    width: double.infinity,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return GestureDetector(
                          onTapDown: (details) {
                            final double larguraUtil = constraints.maxWidth - 48;
                            final double dx = details.localPosition.dx - 42;
                            if (dx >= 0 && larguraUtil > 0) {
                              final double passo = larguraUtil / (labels.length - 1);
                              final int idx = (dx / passo).round().clamp(0, labels.length - 1);
                              setState(() {
                                indicePontoSelecionado = idx;
                              });
                            }
                          },
                          child: CustomPaint(
                            painter: _GraficoComparativoPainter(
                              labels: labels,
                              serieAtual: serieAtual,
                              serieAnterior: serieAnterior,
                              corAtual: corVinho,
                              corAnterior: corLinhaAnterior,
                              indiceSelecionado: indicePontoSelecionado,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  if (indicePontoSelecionado != null &&
                      indicePontoSelecionado! < labels.length) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: corCardSecundario,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${isSemana ? labels[indicePontoSelecionado!] : 'Dia ${labels[indicePontoSelecionado!]}'} — '
                        'Atual: ${formatarMoeda(serieAtual[indicePontoSelecionado!])}  |  '
                        'Anterior: ${formatarMoeda(serieAnterior[indicePontoSelecionado!])}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: corVinho,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==========================================
            // 2. TOP VENDAS — PRODUTOS MAIS VENDIDOS
            // ==========================================
            const Text(
              'Top 5 — Produtos Mais Vendidos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: corVinho,
              ),
            ),

            const SizedBox(height: 10),

            // Filtros: Dia | Semana | Mês | Ano
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: corCardSecundario,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: corVinho.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  _buildAbaFiltroTopVendas('dia', 'Por Dia'),
                  _buildAbaFiltroTopVendas('semana', 'Por Semana'),
                  _buildAbaFiltroTopVendas('mes', 'Por Mês'),
                  _buildAbaFiltroTopVendas('ano', 'Por Ano'),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Lista de Cards no mesmo layout da tela "Catálogo de Produtos" do escopo
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: listaTopProdutos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final produto = listaTopProdutos[index];
                return _buildCardProdutoTopVenda(
                  posicao: index + 1,
                  nome: produto['nome'] as String,
                  tamanhos: produto['tamanhos'] as String,
                  estoque: produto['estoque'] as int,
                  precoUnitario: produto['precoUnitario'] as double,
                  unidadesVendidas: produto['unidadesVendidas'] as int,
                  totalVendido: produto['totalVendido'] as double,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotaoAlternadorGrafico({
    required String titulo,
    required bool selecionado,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selecionado ? corVinho : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          titulo,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: selecionado ? Colors.white : corVinho,
          ),
        ),
      ),
    );
  }

  Widget _buildItemLegenda({required Color cor, required String texto}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          color: cor,
        ),
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: cor,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 12,
          height: 3,
          color: cor,
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildAbaFiltroTopVendas(String chave, String rotulo) {
    final bool ativo = filtroTopVendas == chave;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            filtroTopVendas = chave;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: ativo ? corVinho : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            rotulo,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: ativo ? Colors.white : corVinho,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardProdutoTopVenda({
    required int posicao,
    required String nome,
    required String tamanhos,
    required int estoque,
    required double precoUnitario,
    required int unidadesVendidas,
    required double totalVendido,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagem do Produto com selo da Posição no Ranking (#1, #2, #3...)
          Stack(
            children: [
              Container(
                width: 76,
                height: 84,
                decoration: BoxDecoration(
                  color: corCardSecundario,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.checkroom,
                  size: 42,
                  color: corVinho,
                ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: corVinho,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$posicaoº',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 14),

          // Detalhes seguindo o mesmo layout de "Catálogo de Produtos" do escopo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tamanhos,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  'Em estoque: $estoque  •  Unit.: ${formatarMoeda(precoUnitario)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    // Badge escuro de valor total vendido (idêntico ao badge R$ 59,90 do escopo)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 58, 46, 46),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        formatarMoeda(totalVendido),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Badge vinho de unidades vendidas (idêntico ao badge "15 unidades" do escopo)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: corVinho,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$unidadesVendidas vendidos',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GraficoComparativoPainter extends CustomPainter {
  final List<String> labels;
  final List<double> serieAtual;
  final List<double> serieAnterior;
  final Color corAtual;
  final Color corAnterior;
  final int? indiceSelecionado;

  _GraficoComparativoPainter({
    required this.labels,
    required this.serieAtual,
    required this.serieAnterior,
    required this.corAtual,
    required this.corAnterior,
    this.indiceSelecionado,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double margemEsquerda = 44;
    const double margemDireita = 12;
    const double margemTopo = 12;
    const double margemBase = 28;

    final double larguraGrafico = size.width - margemEsquerda - margemDireita;
    final double alturaGrafico = size.height - margemTopo - margemBase;

    if (larguraGrafico <= 0 || alturaGrafico <= 0 || labels.isEmpty) return;

    final double maiorValor = [
      ...serieAtual,
      ...serieAnterior,
    ].reduce(math.max);
    final double tetoY = (maiorValor * 1.15).ceilToDouble();

    final Paint paintGrade = Paint()
      ..color = Colors.grey.withValues(alpha: 0.25)
      ..strokeWidth = 1;

    final Paint paintBorda = Paint()
      ..color = Colors.grey.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Retângulo de borda do gráfico (como na imagem de referência)
    canvas.drawRect(
      Rect.fromLTWH(margemEsquerda, margemTopo, larguraGrafico, alturaGrafico),
      paintBorda,
    );

    // Linhas horizontais de grade + Rótulos do eixo Y
    const int divisoesY = 4;
    for (int i = 0; i <= divisoesY; i++) {
      final double proporcao = i / divisoesY;
      final double y = margemTopo + alturaGrafico - (proporcao * alturaGrafico);
      final double valorEixo = tetoY * proporcao;

      canvas.drawLine(
        Offset(margemEsquerda, y),
        Offset(margemEsquerda + larguraGrafico, y),
        paintGrade,
      );

      final String textoY = valorEixo >= 1000
          ? '${(valorEixo / 1000).toStringAsFixed(1)}k'
          : valorEixo.toInt().toString();

      final TextPainter tpY = TextPainter(
        text: TextSpan(
          text: textoY,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black54,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tpY.paint(
        canvas,
        Offset(margemEsquerda - tpY.width - 6, y - tpY.height / 2),
      );
    }

    final double passoX = labels.length > 1
        ? larguraGrafico / (labels.length - 1)
        : larguraGrafico;

    // Rótulos do eixo X
    for (int i = 0; i < labels.length; i++) {
      final double x = margemEsquerda + (i * passoX);

      final TextPainter tpX = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: indiceSelecionado == i ? FontWeight.bold : FontWeight.normal,
            color: indiceSelecionado == i ? corAtual : Colors.black54,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tpX.paint(
        canvas,
        Offset(x - tpX.width / 2, margemTopo + alturaGrafico + 6),
      );

      if (indiceSelecionado == i) {
        final Paint paintGuia = Paint()
          ..color = corAtual.withValues(alpha: 0.25)
          ..strokeWidth = 1.2;
        canvas.drawLine(
          Offset(x, margemTopo),
          Offset(x, margemTopo + alturaGrafico),
          paintGuia,
        );
      }
    }

    // Função auxiliar para desenhar cada série de linha + marcadores
    void desenharSerie(List<double> valores, Color cor) {
      final Path path = Path();
      final List<Offset> pontos = [];

      for (int i = 0; i < valores.length; i++) {
        final double x = margemEsquerda + (i * passoX);
        final double proporcaoY = tetoY > 0 ? (valores[i] / tetoY) : 0;
        final double y = margemTopo + alturaGrafico - (proporcaoY * alturaGrafico);
        final Offset pt = Offset(x, y);
        pontos.add(pt);
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }

      final Paint paintLinha = Paint()
        ..color = cor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(path, paintLinha);

      final Paint paintPonto = Paint()
        ..color = cor
        ..style = PaintingStyle.fill;

      final Paint paintBordaPonto = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      for (int i = 0; i < pontos.length; i++) {
        final double raio = indiceSelecionado == i ? 5.5 : 4.0;
        canvas.drawCircle(pontos[i], raio, paintPonto);
        canvas.drawCircle(pontos[i], raio, paintBordaPonto);
      }
    }

    // Desenha primeiro a série anterior e por cima a série atual
    desenharSerie(serieAnterior, corAnterior);
    desenharSerie(serieAtual, corAtual);
  }

  @override
  bool shouldRepaint(covariant _GraficoComparativoPainter oldDelegate) {
    return oldDelegate.labels != labels ||
        oldDelegate.serieAtual != serieAtual ||
        oldDelegate.serieAnterior != serieAnterior ||
        oldDelegate.indiceSelecionado != indiceSelecionado;
  }
}
