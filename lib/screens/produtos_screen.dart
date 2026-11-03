import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ProdutosScreen extends StatefulWidget {
  const ProdutosScreen({super.key});

  @override
  State<ProdutosScreen> createState() => _ProdutosScreenState();
}

class _ProdutosScreenState extends State<ProdutosScreen> {
  static const vinho = Color.fromARGB(255, 115, 32, 54);
  static const rosaClaro = Color.fromARGB(255, 247, 232, 225);
  static const fundo = Color.fromARGB(255, 255, 245, 242);

  static const tamanhos = ['PP', 'P', 'M', 'G', 'GG'];

  final formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final codigoController = TextEditingController();
  final compraController = TextEditingController();
  final vendaController = TextEditingController();

  final quantidadeControllers = <String, TextEditingController>{
    for (final tamanho in tamanhos)
      tamanho: TextEditingController(text: '0'),
  };

  final imagePicker = ImagePicker();

  File? fotoProduto;
  String? fotoAnteriorPath;
  String? produtoId;

  bool inicializado = false;
  bool fotoAlterada = false;
  bool salvando = false;
  bool selecionandoFoto = false;

  bool get editando => produtoId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (inicializado) return;
    inicializado = true;

    final argumentos = ModalRoute.of(context)?.settings.arguments;

    if (argumentos is! Map) return;

    final id = argumentos['id'];
    final dados = argumentos['produto'];

    if (id is! String || dados is! Map) return;

    produtoId = id;

    final produto = Map<String, dynamic>.from(dados);

    nomeController.text = (produto['nome'] ?? '').toString();
    codigoController.text = (produto['codigo'] ?? '').toString();

    compraController.text = formatarMoeda(
      (produto['precoCompra'] as num?)?.toDouble() ?? 0,
    );

    vendaController.text = formatarMoeda(
      (produto['precoVenda'] as num?)?.toDouble() ?? 0,
    );

    final estoque = produto['estoque'];
    final quantidades = estoque is Map
        ? estoque
        : <String, dynamic>{};

    for (final tamanho in tamanhos) {
      quantidadeControllers[tamanho]!.text =
          ((quantidades[tamanho] as num?)?.toInt() ?? 0)
              .toString();
    }

    final caminho = produto['fotoLocalPath'];

    if (caminho is String && caminho.isNotEmpty) {
      fotoAnteriorPath = caminho;
      fotoProduto = File(caminho);
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    codigoController.dispose();
    compraController.dispose();
    vendaController.dispose();

    for (final controller in quantidadeControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  Map<String, int> get quantidades {
    return {
      for (final tamanho in tamanhos)
        tamanho:
            int.tryParse(quantidadeControllers[tamanho]!.text) ?? 0,
    };
  }

  int get totalEstoque {
    return quantidades.values.fold<int>(
      0,
      (total, quantidade) => total + quantidade,
    );
  }

  double converterPreco(String valor) {
    return double.tryParse(
          valor.trim().replaceAll(',', '.'),
        ) ??
        0;
  }

  String formatarMoeda(double valor) {
    return valor.toStringAsFixed(2).replaceAll('.', ',');
  }

  double get lucro {
    return converterPreco(vendaController.text) -
        converterPreco(compraController.text);
  }

  String? validarPreco(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe o preço';
    }

    final preco = double.tryParse(
      valor.trim().replaceAll(',', '.'),
    );

    if (preco == null || !preco.isFinite || preco < 0) {
      return 'Informe um preço válido';
    }

    return null;
  }

  Future<void> selecionarFoto(ImageSource origem) async {
    if (salvando || selecionandoFoto) return;

    setState(() {
      selecionandoFoto = true;
    });

    try {
      final imagem = await imagePicker.pickImage(
        source: origem,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (imagem == null || !mounted) return;

      setState(() {
        fotoProduto = File(imagem.path);
        fotoAlterada = true;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          selecionandoFoto = false;
        });
      }
    }
  }

  Future<void> tirarFoto() async {
    await selecionarFoto(ImageSource.camera);
  }

  Future<void> escolherDaGaleria() async {
    await selecionarFoto(ImageSource.gallery);
  }

  Future<String?> salvarFotoLocal(String id) async {
    if (fotoProduto == null) return null;

    final diretorio = await getApplicationDocumentsDirectory();

    final pasta = Directory(
      '${diretorio.path}${Platform.pathSeparator}fotos_produtos',
    );

    if (!await pasta.exists()) {
      await pasta.create(recursive: true);
    }

    final origem = fotoProduto!.path.toLowerCase();

    final extensao = origem.endsWith('.png') ? '.png' : '.jpg';

    final destino = File(
      '${pasta.path}${Platform.pathSeparator}'
      '${id}_${DateTime.now().microsecondsSinceEpoch}$extensao',
    );

    await fotoProduto!.copy(destino.path);

    return destino.path;
  }

  Future<void> salvarProduto() async {
    if (salvando || selecionandoFoto) return;

    if (!formKey.currentState!.validate()) return;

    setState(() {
      salvando = true;
    });

    String? novaFotoPath;
    bool salvo = false;

    final colecao =
        FirebaseFirestore.instance.collection('produtos');

    final referencia = editando
        ? colecao.doc(produtoId!)
        : colecao.doc();

    try {
      if (!editando || fotoAlterada) {
        novaFotoPath = await salvarFotoLocal(referencia.id);
      }

      final dados = <String, dynamic>{
        'nome': nomeController.text.trim(),
        'codigo': codigoController.text.trim(),
        'precoCompra': converterPreco(compraController.text),
        'precoVenda': converterPreco(vendaController.text),
        'estoque': quantidades,
        'totalEstoque': totalEstoque,
      };

      if (editando) {
        if (fotoAlterada) {
          dados['fotoLocalPath'] = novaFotoPath;
        }

        await referencia.update(dados);
      } else {
        dados['fotoLocalPath'] = novaFotoPath;
        dados['dataCadastro'] = FieldValue.serverTimestamp();

        await referencia.set(dados);
      }

      salvo = true;

      // Apaga a foto antiga somente depois de salvar a nova.
      if (editando &&
          fotoAlterada &&
          fotoAnteriorPath != null &&
          fotoAnteriorPath != novaFotoPath) {
        try {
          final antiga = File(fotoAnteriorPath!);

          if (await antiga.exists()) {
            await antiga.delete();
          }
        } catch (_) {}
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            editando
                ? 'Produto atualizado com sucesso!'
                : 'Produto cadastrado com sucesso!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
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
          content: Text('Erro ao salvar produto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!salvo && novaFotoPath != null) {
        try {
          final arquivo = File(novaFotoPath);

          if (await arquivo.exists()) {
            await arquivo.delete();
          }
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  InputDecoration decoracaoCampo(String titulo) {
    return InputDecoration(
      labelText: titulo,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: vinho,
          width: 2,
        ),
      ),
    );
  }

  Widget botaoFoto({
    required IconData icone,
    required String titulo,
    required VoidCallback acao,
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed:
            (salvando || selecionandoFoto) ? null : acao,
        icon: Icon(icone, size: 22),
        label: Text(titulo),
        style: OutlinedButton.styleFrom(
          foregroundColor: vinho,
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 8,
          ),
          side: const BorderSide(color: vinho),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget campoQuantidade(String tamanho) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: TextFormField(
          controller: quantidadeControllers[tamanho],
          enabled: !salvando,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            labelText: tamanho,
            floatingLabelBehavior:
                FloatingLabelBehavior.always,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 13,
              horizontal: 3,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          validator: (valor) {
            if (valor == null || valor.isEmpty) {
              return 'Obrigatório';
            }

            if (int.tryParse(valor) == null) {
              return 'Inválido';
            }

            return null;
          },
          onChanged: (_) {
            setState(() {});
          },
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
        toolbarHeight: 75,
        title: Text(
          editando ? 'Editar Produto' : 'Cadastro de Produtos',
          style: const TextStyle(
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
          onPressed: salvando
              ? null
              : () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: salvando
                ? null
                : () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Foto do Produto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: vinho,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Center(
                child: Container(
                  height: 160,
                  width: 160,
                  decoration: BoxDecoration(
                    color: rosaClaro,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: fotoProduto == null
                      ? const Icon(
                          Icons.image_outlined,
                          size: 65,
                          color: vinho,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            fotoProduto!,
                            width: 160,
                            height: 160,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) {
                              return const Icon(
                                Icons.broken_image_outlined,
                                size: 60,
                                color: vinho,
                              );
                            },
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  botaoFoto(
                    icone: Icons.camera_alt_outlined,
                    titulo: 'Câmera',
                    acao: tirarFoto,
                  ),
                  const SizedBox(width: 12),
                  botaoFoto(
                    icone: Icons.photo_library_outlined,
                    titulo: 'Galeria',
                    acao: escolherDaGaleria,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  'Tire uma foto ou escolha uma imagem da galeria.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              TextFormField(
                controller: nomeController,
                enabled: !salvando,
                textCapitalization: TextCapitalization.words,
                decoration: decoracaoCampo('Nome do Produto'),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o nome do produto';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: codigoController,
                enabled: !salvando,
                decoration: decoracaoCampo(
                  'Código do Produto (opcional)',
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: compraController,
                enabled: !salvando,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: decoracaoCampo(
                  'Preço de Compra (R\$)',
                ),
                validator: validarPreco,
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: vendaController,
                enabled: !salvando,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: decoracaoCampo(
                  'Preço de Venda (R\$)',
                ),
                validator: validarPreco,
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: rosaClaro,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        'Lucro por unidade:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'R\$ ${formatarMoeda(lucro)}',
                      style: const TextStyle(
                        color: vinho,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Quantidade por tamanho',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: vinho,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: tamanhos
                    .map((tamanho) => campoQuantidade(tamanho))
                    .toList(),
              ),

              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: rosaClaro,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Total em estoque: $totalEstoque peças',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: vinho,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: (salvando || selecionandoFoto)
                      ? null
                      : salvarProduto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vinho,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: salvando
                      ? const SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          editando
                              ? 'SALVAR ALTERAÇÕES'
                              : 'SALVAR PRODUTO',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}