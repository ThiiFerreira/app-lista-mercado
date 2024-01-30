import 'package:flutter/material.dart';
import 'package:lista_mercado/componentes/AlertaMensagem.dart';
import 'package:lista_mercado/componentes/AlertaSnackbar.dart';
import 'package:lista_mercado/models/Produto.dart';
import 'package:lista_mercado/screen/screenAdicionaProduto.dart';
import 'package:lista_mercado/screen/screenDetalheProduto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class screenLista extends StatefulWidget {
  const screenLista({super.key});

  @override
  State<screenLista> createState() => _screenListaState();
}

enum Ordenacao { crescente, decrescente }

class _screenListaState extends State<screenLista> {
  List<Produto> produtos = [];
  bool loading = false;
  Ordenacao opcaoOrdenacao = Ordenacao.crescente;

  Future<void> _abrirTelaAdicionarProduto() async {
    // Navegue para a tela de adicionar um novo produto e aguarde o resultado
    final novoProduto = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const screenAdicionaProduto(),
      ),
    );

    if (novoProduto != null) {
      setState(() {
        produtos.add(novoProduto);
      });
    }
  }

  void _atualizarListaProdutos(int index, Produto produtoAtualizado) {
    setState(() {
      if (index >= 0 && index < produtos.length) {
        produtos[index] = produtoAtualizado;
      }
    });
  }

  void _removerProduto(int index) {
    setState(() {
      if (index >= 0 && index < produtos.length) {
        produtos.removeAt(index);
      }
    });
  }

  Future<void> _abrirTelaDetalhe(Produto produto, int index) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screenDetalheProduto(
          produto: produto,
          index: index,
          onProdutoAtualizado: _atualizarListaProdutos,
          onProdutoRemovido: _removerProduto,
        ),
      ),
    );
  }

  Future<void> salvarListaProdutos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Transforma a lista de produtos em uma lista de mapas
    List<Map<String, dynamic>> produtosMapList = produtos.map((produto) {
      return produto
          .toMap(); // Supondo que a classe Produto tem um método toMap()
    }).toList();

    // Salva a lista de mapas no SharedPreferences
    await prefs.setStringList(
        'produtos', produtosMapList.map((map) => json.encode(map)).toList());

    // ignore: use_build_context_synchronously
    AlertaSnackbar.mostrarSnackbar(
        context, "Lista de produtos salva com sucesso!");
  }

  Future<void> carregarListaProdutos() async {
    setState(() {
      loading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Recupera a lista de strings JSON do SharedPreferences
    List<String>? produtosJsonList = prefs.getStringList('produtos');
    if (produtosJsonList != null) {
      // Converte a lista de strings JSON de volta para uma lista de mapas
      List<Map<String, dynamic>> produtosMapList =
          produtosJsonList.map((jsonString) {
        return json.decode(jsonString) as Map<String, dynamic>;
      }).toList();

      // Converte a lista de mapas em uma lista de objetos Produto
      List<Produto> produtosCarregados = produtosMapList.map((map) {
        return Produto(
          nome: map['nome'],
          preco: map['preco'],
          quantidade: map['quantidade'],
          adicionado: map['adicionado'],
        );
      }).toList();

      setState(() {
        produtos = produtosCarregados;
        setState(() {
          loading = false;
        });
      });

      // ignore: use_build_context_synchronously
      AlertaSnackbar.mostrarSnackbar(
          context, "Lista de produtos carregada com sucesso!");
    } else if (produtosJsonList == null) {
      setState(() {
        setState(() {
          loading = false;
        });
      });

      // ignore: use_build_context_synchronously
      AlertaSnackbar.mostrarSnackbar(context, "Lista de produtos vazia!");
    } else {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertaMensagem(mensagem: "Falha ao carregar lista.");
        },
      );
      setState(() {
        loading = false;
      });
    }
  }

  int calcularQuantidadeItens() {
    return produtos.length;
  }

  double calcularTotal() {
    double total = 0.0;

    for (Produto produto in produtos) {
      total += produto.preco * produto.quantidade;
    }

    return total;
  }

  double calcularTotalItensNoCarrinho() {
    double total = 0.0;

    for (Produto produto in produtos) {
      if (produto.adicionado) {
        total += produto.preco * produto.quantidade;
      }
    }

    return total;
  }

  double calcularTotalRestante() {
    double total = 0.0;

    for (Produto produto in produtos) {
      if (!produto.adicionado) {
        total += produto.preco * produto.quantidade;
      }
    }

    return total;
  }

  void _ordenarLista() {
    setState(() {
      if (opcaoOrdenacao == Ordenacao.crescente) {
        produtos.sort(
            (a, b) => a.nome.toUpperCase().compareTo(b.nome.toUpperCase()));
      } else {
        produtos.sort(
            (a, b) => b.nome.toUpperCase().compareTo(a.nome.toUpperCase()));
      }
    });
  }

  void apagarTodos() {
    setState(() {
      produtos.clear();
    });
    // ignore: use_build_context_synchronously
    AlertaSnackbar.mostrarSnackbar(context, "produtos apagados!");
  }

  void removeTodosDoCarrinho() {
    var listaAux = produtos;

    for (Produto produto in listaAux) {
      if (produto.adicionado) {
        produto.adicionado = false;
      }
    }

    setState(() {
      produtos = listaAux;
    });

    // ignore: use_build_context_synchronously
    AlertaSnackbar.mostrarSnackbar(context, "Prodtuos removidos do carrinho!");
  }

  void initState() {
    super.initState();
    carregarListaProdutos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de compras'),
        actions: [
          IconButton(
            tooltip: "Salvar",
            icon: const Icon(Icons.save),
            onPressed: () {
              salvarListaProdutos();
            },
          ),
          IconButton(
            tooltip: "Ordenar",
            icon: opcaoOrdenacao == Ordenacao.crescente
                ? Text("A-Z")
                : Text("Z-A"),
            onPressed: () {
              if (opcaoOrdenacao == Ordenacao.crescente) {
                setState(() {
                  opcaoOrdenacao = Ordenacao.decrescente;
                });
              } else {
                setState(() {
                  opcaoOrdenacao = Ordenacao.crescente;
                });
              }
              _ordenarLista();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String result) {
              // Este bloco será executado quando o usuário selecionar uma opção no menu
              if (result == 'apagartodos') {
                apagarTodos();
              } else if (result == 'removecarrinho') {
                removeTodosDoCarrinho();
              }
              // Adicione mais condições conforme necessário
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'apagartodos',
                child: ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('apagar todos'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'removecarrinho',
                child: ListTile(
                  leading: Icon(Icons.remove_shopping_cart_rounded),
                  title: Text('remover do carrinho'),
                ),
              ),
              // Adicione mais opções conforme necessário
            ],
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : produtos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Nenhum item na lista.'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors
                              .white, // Define a cor de fundo do botão como branco
                          onPrimary:
                              Colors.black, // Define a cor do texto como preto
                        ),
                        onPressed: () {
                          carregarListaProdutos();
                        },
                        child: Text('Recarregar'),
                      )
                    ],
                  ),
                )
              : Center(
                  child: ListView.builder(
                    itemCount: produtos.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: produtos[index].adicionado ? Colors.green : null,
                        child: ListTile(
                          title: Text(produtos[index].nome),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Quantidade: ${produtos[index].quantidade}'),
                              Text(
                                  'Unidade: R\$ ${produtos[index].preco.toStringAsFixed(2)}'),
                              Text(
                                  'Total: R\$ ${(produtos[index].preco * produtos[index].quantidade).toStringAsFixed(2)}'),
                            ],
                          ),
                          onTap: () {
                            _abrirTelaDetalhe(produtos[index], index);
                          },
                          trailing: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  produtos[index].adicionado =
                                      !produtos[index].adicionado;
                                });
                              },
                              child: produtos[index].adicionado
                                  ? Text("X")
                                  : Text("OK")),
                        ),
                      );
                    },
                  ),
                ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.grey[300],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Total: R\$ ${calcularTotal().toStringAsFixed(2)} - Qtd itens: ${calcularQuantidadeItens()}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'No carrinho: R\$ ${calcularTotalItensNoCarrinho().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                
                Text(
                  'Restante: R\$ ${calcularTotalRestante().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirTelaAdicionarProduto,
        tooltip: 'adiciona item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
