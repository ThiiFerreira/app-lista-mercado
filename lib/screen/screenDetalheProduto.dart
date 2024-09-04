import 'package:flutter/material.dart';
import 'package:lista_mercado/componentes/AlertaMensagem.dart';
import 'package:lista_mercado/componentes/AlertaSnackbar.dart';
import 'package:lista_mercado/models/Produto.dart';
import 'package:lista_mercado/screen/screenAtualizaProduto.dart';

// ignore: must_be_immutable
class screenDetalheProduto extends StatefulWidget {
  late Produto produto;


  screenDetalheProduto({
    Key? key,
    required this.produto,
  }) : super(key: key);

  @override
  State<screenDetalheProduto> createState() => _screenDetalheProdutoState();
}

class _screenDetalheProdutoState extends State<screenDetalheProduto> {
  bool loadingDelete = false;
  void _editarProduto(BuildContext context) async {
    // Navegue para a tela de edição e aguarde o resultado (produto atualizado)
    final produtoAtualizado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screenAtualizaProduto(produto: widget.produto),
      ),
    );

    if (produtoAtualizado != null) {
      // ignore: use_build_context_synchronously
      AlertaSnackbar.mostrarSnackbar(
          context, "Produto atualizado com sucesso!");

      Navigator.pop(context, produtoAtualizado);
    }
  }

  _removeProduto() {
    try {
      setState(() {
        loadingDelete = true;
      });
      Navigator.of(context).pop();

      Navigator.pop(context,true);
      setState(() {
        loadingDelete = false;
      });
    } catch (e) {
      setState(() {
        loadingDelete = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertaMensagem(
              mensagem: "Falha ao remover produto");
        },
      );
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.produto.nome,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Preço: R\$ ${widget.produto.preco.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quantidade: ${widget.produto.quantidade}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Navegue para a tela de edição e aguarde o resultado (produto atualizado)
                        _editarProduto(context);
                      },
                      child: const Text('Editar Produto'),
                    ),
                    const SizedBox(width: 16),
                    loadingDelete
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              Widget cancelaButton = ElevatedButton(
                                child: const Text("CANCELAR"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              );
                              Widget okButton = ElevatedButton(
                                child: const Text("OK"),
                                onPressed: () {
                                  _removeProduto();
                                },
                              );
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Tem certeza?"),
                                    actionsAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    actions: [
                                      cancelaButton,
                                      okButton,
                                    ],
                                  );
                                },
                              );
                            },
                            style:
                                ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Deletar Produto'),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
