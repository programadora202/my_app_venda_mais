
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StorageAndProducts extends StatefulWidget {
  const StorageAndProducts({super.key});

  @override
  State<StorageAndProducts> createState() =>
      _StorageAndProductsState();
}

class _StorageAndProductsState extends State<StorageAndProducts> {
  static const vinho = Color.fromARGB(255, 115, 32, 54);
  static const rosaClaro = Color.fromARGB(255, 247, 232, 225);
  static const fundo = Color.fromARGB(255, 255, 245, 242);

  static const tamanhos = ['PP', 'P', 'M', 'G', 'GG'];

  final pesquisaController = TextEditingController();

  final produtosRef =
      FirebaseFirestore.instance.collection('produtos');

  String pesquisa = '';
  bool saindo = false;

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  String formatarPreco(dynamic valor) {
    final numero = valor is num ? valor.toDouble() : 0.0;
    return numero.toStringAsFixed(2).replaceAll('.', ',');
  }

  Map<String, int> obterEstoque(Map<String, dynamic> produto) {
    final estoqueOriginal = produto['estoque'];

    final Map<String, dynamic> dados;

    if (estoqueOriginal is Map) {
      dados = Map<String, dynamic>.from(estoqueOriginal);
    } else {
      dados = {};
    }

    return {
      for (final tamanho in tamanhos)
        tamanho: dados[tamanho] is num
            ? (dados[tamanho] as num).toInt()
            : 0,
    };
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

  Future<void> confirmarExclusao(
    String produtoId,
    String nome,
    String? caminhoFoto,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: Text(
            'Tem certeza de que deseja excluir '
            'o produto "$nome"?\n\n'
            'Esta ação não poderá ser desfeita.',
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Excluir',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: vinho,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    try {
      await produtosRef.doc(produtoId).delete();

      // Remove também a foto armazenada no celular.
      if (caminhoFoto != null && caminhoFoto.isNotEmpty) {
        try {
          final arquivo = File(caminhoFoto);

          if (await arquivo.exists()) {
            await arquivo.delete();
          }
        } catch (_) {
          // O produto já foi excluído do Firebase.
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produto excluído com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro no Firebase: ${e.code}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir produto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void editarProduto(
    String produtoId,
    Map<String, dynamic> produto,
  ) {
    Navigator.pushNamed(
      context,
      '/produtos',
      arguments: {
        'id': produtoId,
        'produto': produto,
      },
    );
  }

  Widget construirImagem(String? caminhoFoto) {
    if (caminhoFoto == null || caminhoFoto.isEmpty) {
      return const Icon(
        Icons.checkroom,
        size: 38,
        color: vinho,
      );
    }

    return Image.file(
      File(caminhoFoto),
      width: 78,
      height: 90,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.broken_image_outlined,
          size: 35,
          color: vinho,
        );
      },
    );
  }

  Widget construirTamanho(String tamanho, int quantidade) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 2,
        ),
        decoration: BoxDecoration(
          color: rosaClaro,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              tamanho,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '$quantidade',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: vinho,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget construirCard(
    QueryDocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    final produto = documento.data();

    final nome =
        (produto['nome'] ?? 'Produto sem nome').toString();

    final codigo = (produto['codigo'] ?? '').toString();

    final estoque = obterEstoque(produto);

    final total = estoque.values.fold<int>(
      0,
      (a, b) => a + b,
    );

    final caminhoFoto = produto['fotoLocalPath'] is String
        ? produto['fotoLocalPath'] as String
        : null;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 78,
                  height: 90,
                  decoration: BoxDecoration(
                    color: rosaClaro,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Center(
                      child: construirImagem(caminhoFoto),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nome,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: vinho,
                        ),
                      ),

                      if (codigo.isNotEmpty)
                        Text(
                          'Código: $codigo',
                          style: const TextStyle(fontSize: 12),
                        ),

                      const SizedBox(height: 5),

                      Text(
                        'R\$ ${formatarPreco(produto['precoVenda'])}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        '$total unidades no estoque',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            const Text(
              'Quantidade por tamanho',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: tamanhos.map((tamanho) {
                return construirTamanho(
                  tamanho,
                  estoque[tamanho] ?? 0,
                );
              }).toList(),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    confirmarExclusao(
                      documento.id,
                      nome,
                      caminhoFoto,
                    );
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Excluir'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: () {
                    editarProduto(
                      documento.id,
                      produto,
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vinho,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
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
          'Estoque',
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
      body: Column(
        children: [
          // PESQUISA
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: pesquisaController,
              onChanged: (valor) {
                setState(() {
                  pesquisa = valor.toLowerCase().trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou código',
                prefixIcon: const Icon(
                  Icons.search,
                  color: vinho,
                ),
                filled: true,
                fillColor: rosaClaro,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // PRODUTOS DO FIREBASE
          Expanded(
            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: produtosRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Erro ao carregar produtos:\n'
                        '${snapshot.error}',
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
                    child: Text('Não foi possível carregar os produtos.'),
                  );
                }

                final produtos = snapshot.data!.docs.where((doc) {
                  final dados = doc.data();

                  final nome = (dados['nome'] ?? '')
                      .toString()
                      .toLowerCase();

                  final codigo = (dados['codigo'] ?? '')
                      .toString()
                      .toLowerCase();

                  return nome.contains(pesquisa) ||
                      codigo.contains(pesquisa);
                }).toList();

                if (produtos.isEmpty) {
                  return Center(
                    child: Text(
                      pesquisa.isEmpty
                          ? 'Nenhum produto cadastrado.'
                          : 'Nenhum produto encontrado.',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    90,
                  ),
                  itemCount: produtos.length,
                  itemBuilder: (context, index) {
                    return construirCard(produtos[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/produtos',
          );
        },
        backgroundColor: vinho,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        tooltip: 'Cadastrar novo produto',
        child: const Icon(
          Icons.add,
          size: 32,
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
    );
  }
}
