import '../product_photo.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewSaleScreen extends StatefulWidget {
  const NewSaleScreen({super.key});

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  static const vinho = Color.fromARGB(255, 115, 32, 54);
  static const rosaClaro = Color.fromARGB(255, 247, 232, 225);
  static const fundo = Color.fromARGB(255, 255, 245, 242);

  static const tamanhos = ['PP', 'P', 'M', 'G', 'GG'];

  final pesquisaController = TextEditingController();

  final produtosRef =
      FirebaseFirestore.instance.collection('produtos');

  final vendasRef =
      FirebaseFirestore.instance.collection('vendas');

  final List<ItemVenda> carrinho = [];

  String pesquisa = '';
  String? formaPagamentoSelecionada;
  bool finalizando = false;

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  String moeda(double valor) {
    return valor.toStringAsFixed(2).replaceAll('.', ',');
  }

  double precoProduto(Map<String, dynamic> produto) {
    final valor = produto['precoVenda'];

    if (valor is num) return valor.toDouble();

    return double.tryParse(
          valor.toString().replaceAll(',', '.'),
        ) ??
        0;
  }

  Map<String, int> estoqueProduto(
    Map<String, dynamic> produto,
  ) {
    final bruto = produto['estoque'];

    final dados = bruto is Map
        ? Map<String, dynamic>.from(bruto)
        : <String, dynamic>{};

    return {
      for (final tamanho in tamanhos)
        tamanho: (dados[tamanho] as num?)?.toInt() ?? 0,
    };
  }

  int quantidadeCarrinho(String id, String tamanho) {
    var quantidade = 0;

    for (final item in carrinho) {
      if (item.produtoId == id && item.tamanho == tamanho) {
        quantidade += item.quantidade;
      }
    }

    return quantidade;
  }

  int get totalItens {
    return carrinho.fold<int>(
      0,
      (total, item) => total + item.quantidade,
    );
  }

  double get totalVenda {
    return carrinho.fold<double>(
      0,
      (total, item) => total + item.subtotal,
    );
  }

  String nomeFormaPagamento(String forma) {
    switch (forma) {
      case 'credito':
        return 'Cartão de crédito';
      case 'debito':
        return 'Cartão de débito';
      case 'dinheiro_pix':
        return 'Dinheiro / Pix';
      default:
        return 'Não informado';
    }
  }

  void mensagem(String texto, {bool erro = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: erro ? Colors.red : vinho,
      ),
    );
  }

  Widget opcaoPagamento({
    required String valor,
    required String titulo,
    required IconData icone,
  }) {
    final selecionado = formaPagamentoSelecionada == valor;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: finalizando
            ? null
            : () {
                setState(() {
                  formaPagamentoSelecionada = valor;
                });
              },
        child: Container(
          height: 88,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: selecionado ? rosaClaro : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selecionado ? vinho : Colors.black12,
              width: selecionado ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icone,
                color: vinho,
                size: 25,
              ),
              const SizedBox(height: 5),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selecionado
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: vinho,
                ),
              ),
              if (selecionado)
                const Icon(
                  Icons.check_circle,
                  color: vinho,
                  size: 14,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> selecionarProduto(
    QueryDocumentSnapshot<Map<String, dynamic>> documento,
  ) async {
    if (finalizando) return;

    final produto = documento.data();
    final estoque = estoqueProduto(produto);

    final opcoes = tamanhos.where((tamanho) {
      final disponivel = estoque[tamanho] ?? 0;
      final reservado = quantidadeCarrinho(
        documento.id,
        tamanho,
      );

      return disponivel > reservado;
    }).toList();

    if (opcoes.isEmpty) {
      mensagem(
        'Produto sem estoque disponível.',
        erro: true,
      );
      return;
    }

    final tamanhoEscolhido = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Escolha o tamanho'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: opcoes.map((tamanho) {
              final disponivel = estoque[tamanho]! -
                  quantidadeCarrinho(
                    documento.id,
                    tamanho,
                  );

              return ListTile(
                title: Text('Tamanho $tamanho'),
                subtitle: Text(
                  '$disponivel disponível(is)',
                ),
                trailing: const Icon(
                  Icons.add_circle_outline,
                  color: vinho,
                ),
                onTap: () {
                  Navigator.pop(dialogContext, tamanho);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );

    if (tamanhoEscolhido == null || !mounted) return;

    setState(() {
      final indice = carrinho.indexWhere(
        (item) =>
            item.produtoId == documento.id &&
            item.tamanho == tamanhoEscolhido,
      );

      if (indice >= 0) {
        carrinho[indice].quantidade++;
      } else {
        carrinho.add(
          ItemVenda(
            produtoId: documento.id,
            nome: (produto['nome'] ?? 'Produto').toString(),
            tamanho: tamanhoEscolhido,
            preco: precoProduto(produto),
            quantidade: 1,
            fotoLocalPath: produto['fotoLocalPath'] is String
                ? produto['fotoLocalPath'] as String
                : null,
          ),
        );
      }
    });
  }

  Future<void> aumentarQuantidade(ItemVenda item) async {
    if (finalizando) return;

    try {
      final documento =
          await produtosRef.doc(item.produtoId).get();

      if (!documento.exists || documento.data() == null) {
        mensagem('Produto não encontrado.', erro: true);
        return;
      }

      final estoque = estoqueProduto(documento.data()!);
      final disponivel = estoque[item.tamanho] ?? 0;

      if (!mounted) return;

      if (quantidadeCarrinho(item.produtoId, item.tamanho) >=
          disponivel) {
        mensagem(
          'Quantidade máxima disponível em estoque.',
          erro: true,
        );
        return;
      }

      setState(() {
        item.quantidade++;
      });
    } catch (e) {
      mensagem('Erro ao consultar estoque: $e', erro: true);
    }
  }

  void diminuirQuantidade(ItemVenda item) {
    if (finalizando) return;

    setState(() {
      if (item.quantidade > 1) {
        item.quantidade--;
      } else {
        carrinho.remove(item);
      }
    });
  }

  Future<void> finalizarVenda() async {
    if (finalizando || carrinho.isEmpty) return;

    // Verifica se a forma de pagamento foi selecionada.
    if (formaPagamentoSelecionada == null) {
      mensagem(
        'Selecione uma forma de pagamento antes de finalizar.',
        erro: true,
      );
      return;
    }

    final formaPagamento = formaPagamentoSelecionada!;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Finalizar venda'),
          content: Text(
            'Confirmar a venda de $totalItens '
            'peça(s) no valor de '
            'R\$ ${moeda(totalVenda)}?\n\n'
            'Forma de pagamento: '
            '${nomeFormaPagamento(formaPagamento)}',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: vinho,
                foregroundColor: Colors.white,
              ),
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      mensagem(
        'Usuário não autenticado. Faça login novamente.',
        erro: true,
      );
      return;
    }

    setState(() {
      finalizando = true;
    });

    final itens = carrinho
        .map(
          (item) => ItemVenda(
            produtoId: item.produtoId,
            nome: item.nome,
            tamanho: item.tamanho,
            preco: item.preco,
            quantidade: item.quantidade,
            fotoLocalPath: item.fotoLocalPath,
          ),
        )
        .toList();

    final referenciaVenda = vendasRef.doc();

    try {
      await FirebaseFirestore.instance.runTransaction(
        (transaction) async {
          final documentos = <
              String,
              DocumentSnapshot<Map<String, dynamic>>>{};

          for (final item in itens) {
            if (!documentos.containsKey(item.produtoId)) {
              final referencia =
                  produtosRef.doc(item.produtoId);

              documentos[item.produtoId] =
                  await transaction.get(referencia);
            }
          }

          final atualizacoes =
              <String, Map<String, int>>{};

          final itensParaSalvar = <Map<String, dynamic>>[];

          double totalConfirmado = 0;

          for (final item in itens) {
            final documento = documentos[item.produtoId]!;

            if (!documento.exists ||
                documento.data() == null) {
              throw Exception(
                'O produto ${item.nome} não existe mais.',
              );
            }

            final produto = documento.data()!;

            final estoque = atualizacoes.putIfAbsent(
              item.produtoId,
              () => estoqueProduto(produto),
            );

            final disponivel = estoque[item.tamanho] ?? 0;

            if (disponivel < item.quantidade) {
              throw Exception(
                'Estoque insuficiente para '
                '${item.nome} - ${item.tamanho}.',
              );
            }

            final precoAtual = precoProduto(produto);

            if (precoAtual < 0) {
              throw Exception(
                'Preço inválido para ${item.nome}.',
              );
            }

            estoque[item.tamanho] =
                disponivel - item.quantidade;

            final subtotal =
                precoAtual * item.quantidade;

            totalConfirmado += subtotal;

            itensParaSalvar.add({
              'produtoId': item.produtoId,
              'nome': item.nome,
              'tamanho': item.tamanho,
              'quantidade': item.quantidade,
              'precoUnitario': precoAtual,
              'subtotal': subtotal,
            });
          }

          for (final entrada in atualizacoes.entries) {
            final estoque = entrada.value;

            final total = estoque.values.fold<int>(
              0,
              (soma, quantidade) => soma + quantidade,
            );

            transaction.update(
              produtosRef.doc(entrada.key),
              {
                'estoque': estoque,
                'totalEstoque': total,
              },
            );
          }

          transaction.set(referenciaVenda, {
            'usuarioId': usuario.uid,
            'itens': itensParaSalvar,
            'total': totalConfirmado,
            'quantidadeItens': itens.fold<int>(
              0,
              (soma, item) => soma + item.quantidade,
            ),
            'formaPagamento': formaPagamento,
            'dataVenda': FieldValue.serverTimestamp(),
            'status': 'concluida',
          });
        },
      );

      if (!mounted) return;

      setState(() {
        carrinho.clear();
        formaPagamentoSelecionada = null;
      });

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Venda concluída!'),
            content: const Text(
              'A venda foi registrada e o estoque '
              'foi atualizado com sucesso.',
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: vinho,
                  foregroundColor: Colors.white,
                ),
                onPressed: () =>
                    Navigator.pop(dialogContext),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      mensagem(
        'Não foi possível finalizar a venda: $e',
        erro: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          finalizando = false;
        });
      }
    }
  }

  Widget imagemProduto(String? caminho, {double tamanho = 45}) {
    if (caminho == null || caminho.isEmpty) {
      return Container(
        width: tamanho,
        height: tamanho,
        decoration: BoxDecoration(
          color: rosaClaro,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.checkroom,
          color: vinho,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: productPhoto(
        caminho,
        width: tamanho,
        height: tamanho,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: tamanho,
            height: tamanho,
            color: rosaClaro,
            child: const Icon(
              Icons.broken_image_outlined,
              color: vinho,
            ),
          );
        },
      ),
    );
  }

  Widget cardProduto(
    QueryDocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    final produto = documento.data();
    final nome = (produto['nome'] ?? '').toString();
    final codigo = (produto['codigo'] ?? '').toString();

    final estoque = estoqueProduto(produto);

    final disponivel = estoque.values.fold<int>(
      0,
      (soma, quantidade) => soma + quantidade,
    );

    final caminho = produto['fotoLocalPath'] is String
        ? produto['fotoLocalPath'] as String
        : null;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: finalizando
            ? null
            : () => selecionarProduto(documento),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Row(
            children: [
              imagemProduto(caminho),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    if (codigo.isNotEmpty)
                      Text(
                        'Código: $codigo',
                        style: const TextStyle(
                          fontSize: 11,
                        ),
                      ),
                    Text(
                      'R\$ ${moeda(precoProduto(produto))}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: vinho,
                      ),
                    ),
                    Text(
                      '$disponivel em estoque',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.add_circle_outline,
                color: vinho,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cardItemVenda(ItemVenda item) {
    return Card(
      color: rosaClaro,
      margin: const EdgeInsets.only(bottom: 7),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            imagemProduto(item.fotoLocalPath),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nome,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Tamanho ${item.tamanho}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  Text(
                    'R\$ ${moeda(item.preco)} cada',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton(
              constraints: const BoxConstraints(
                minWidth: 30,
                minHeight: 36,
              ),
              padding: EdgeInsets.zero,
              onPressed: finalizando
                  ? null
                  : () => diminuirQuantidade(item),
              icon: const Icon(
                Icons.remove,
                size: 18,
              ),
            ),
            Text(
              '${item.quantidade}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              constraints: const BoxConstraints(
                minWidth: 30,
                minHeight: 36,
              ),
              padding: EdgeInsets.zero,
              onPressed: finalizando
                  ? null
                  : () => aumentarQuantidade(item),
              icon: const Icon(
                Icons.add,
                size: 18,
              ),
            ),
            SizedBox(
              width: 73,
              child: Text(
                'R\$ ${moeda(item.subtotal)}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: vinho,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        backgroundColor: vinho,
        centerTitle: true,
        title: const Text(
          'Nova Venda',
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: finalizando
              ? null
              : () => Navigator.pop(context),
        ),
        
        actions: [
          IconButton(
            tooltip: 'Sair da conta',
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: finalizando
                ? null
                : () async {
                    try {
                      // Encerra a sessão do Firebase.
                      await FirebaseAuth.instance.signOut();

                      if (!mounted) return;

                      // Retorna ao login e remove as telas anteriores.
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Não foi possível sair da conta. Tente novamente.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
          ),
        ],

      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: pesquisaController,
                onChanged: (valor) {
                  setState(() {
                    pesquisa = valor.toLowerCase().trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Pesquisar produto...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: vinho,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 4,
              child: StreamBuilder<
                  QuerySnapshot<Map<String, dynamic>>>(
                stream: produtosRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erro ao carregar produtos:\n'
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: vinho,
                      ),
                    );
                  }

                  final encontrados =
                      snapshot.data!.docs.where((doc) {
                    final produto = doc.data();

                    final nome =
                        (produto['nome'] ?? '')
                            .toString()
                            .toLowerCase();

                    final codigo =
                        (produto['codigo'] ?? '')
                            .toString()
                            .toLowerCase();

                    return nome.contains(pesquisa) ||
                        codigo.contains(pesquisa);
                  }).toList();

                  if (encontrados.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum produto encontrado.',
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    itemCount: encontrados.length,
                    itemBuilder: (context, index) {
                      return cardProduto(
                        encontrados[index],
                      );
                    },
                  );
                },
              ),
            ),

            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                12, 12, 12, 5,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Itens na Venda',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: vinho,
                    ),
                  ),
                  Text(
                    '$totalItens peça(s)',
                    style: const TextStyle(
                      color: vinho,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 3,
              child: carrinho.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum item adicionado.',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      itemCount: carrinho.length,
                      itemBuilder: (context, index) {
                        return cardItemVenda(
                          carrinho[index],
                        );
                      },
                    ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(
                12, 8, 12, 12,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExpansionTile(
                    initiallyExpanded: false,
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    childrenPadding: const EdgeInsets.only(
                      bottom: 8,
                    ),
                    leading: const Icon(
                      Icons.payment,
                      color: vinho,
                    ),
                    title: const Text(
                      'Forma de pagamento',
                      style: TextStyle(
                        color: vinho,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      formaPagamentoSelecionada == null
                          ? 'Selecione uma opção'
                          : nomeFormaPagamento(
                              formaPagamentoSelecionada!,
                            ),
                      style: const TextStyle(fontSize: 12),
                    ),
                    children: [
                      Row(
                        children: [
                          opcaoPagamento(
                            valor: 'credito',
                            titulo: 'Crédito',
                            icone: Icons.credit_card,
                          ),
                          opcaoPagamento(
                            valor: 'debito',
                            titulo: 'Débito',
                            icone: Icons.credit_card,
                          ),
                          opcaoPagamento(
                            valor: 'dinheiro_pix',
                            titulo: 'Dinheiro / Pix',
                            icone: Icons.payments_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Divider(height: 12),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 21,
                        ),
                      ),
                      Text(
                        'R\$ ${moeda(totalVenda)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: vinho,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                          finalizando || carrinho.isEmpty
                              ? null
                              : finalizarVenda,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: vinho,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: finalizando
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'FINALIZAR VENDA',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
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
  }
}

class ItemVenda {
  final String produtoId;
  final String nome;
  final String tamanho;
  final double preco;
  final String? fotoLocalPath;

  int quantidade;

  ItemVenda({
    required this.produtoId,
    required this.nome,
    required this.tamanho,
    required this.preco,
    required this.quantidade,
    this.fotoLocalPath,
  });

  double get subtotal => preco * quantidade;
}
