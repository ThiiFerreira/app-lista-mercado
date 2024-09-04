import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lista_mercado/componentes/AlertaMensagem.dart';
import 'package:lista_mercado/componentes/AlertaSnackbar.dart';
import 'package:lista_mercado/models/Produto.dart';
import 'package:lista_mercado/screen/screenAdicionaProduto.dart';
import 'package:lista_mercado/screen/screenDetalheProduto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class screenListaCmFiltro extends StatefulWidget {
  const screenListaCmFiltro({super.key});

  @override
  State<screenListaCmFiltro> createState() => _screenListaState();
}

enum Ordenacao { crescente, decrescente }

class _screenListaState extends State<screenListaCmFiltro> {
  List<Produto> produtos = [];
  List<Produto> produtosFiltrados = [];
  bool loading = false;
  bool boolProdutosZerados = true;
  bool boolBarraPesquisa = true;
  bool boolBotaoOkOuQtd = true;
  Ordenacao opcaoOrdenacao = Ordenacao.crescente;
  String produtosZerados = "Ocultar produtos zerados";
  String barraPesquisa = "Ocultar barra de pesquisa";
  TextEditingController _controllerPesquisa = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarListaProdutos();
    _controllerPesquisa.addListener(_filtrarProdutos);
  }

  @override
  void dispose() {
    _controllerPesquisa.dispose();
    super.dispose();
  }

  void _filtrarProdutos() {
    String query = _controllerPesquisa.text.toLowerCase();
    setState(() {
      produtosFiltrados = produtos.where((produto) {
        return produto.nome.toLowerCase().contains(query);
      }).toList();
    });
  }

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
      _ordenarLista();
      salvarListaProdutos();
    }

    carregarListaProdutos();
  }

  void _atualizarListaProdutos(int index, Produto produtoAtualizado) {
    setState(() {
      if (index >= 0 && index < produtos.length) {
        produtos[index] = produtoAtualizado;
      }
    });

    salvarListaProdutos();
  }

  void _removerProduto(int index) {
    print(index);
    setState(() {
      if (index >= 0 && index < produtos.length) {
        produtosFiltrados.removeAt(index);
      }
    });
  }

  Future<void> _abrirTelaDetalhe(String nomeProduto) async {
    int index = produtos.indexWhere((produto) => produto.nome == nomeProduto);

    final retorno = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screenDetalheProduto(produto: produtos[index]),
      ),
    );

    if (retorno != null) {
      if (retorno == true) {
        setState(() {
          _removerProduto(index);
        });
      } else {
        _atualizarListaProdutos(index, retorno);
        carregarListaProdutos();
      }
    } else {}
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  Future<void> salvarListaProdutosBotao() async {
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
        produtosFiltrados = produtosCarregados;
        loading = false;
      });

      // ignore: use_build_context_synchronously
      // AlertaSnackbar.mostrarSnackbar(
      //     context, "Lista de produtos carregada com sucesso!");
    } else if (produtosJsonList == null) {
      setState(() {
        loading = false;
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
        produtosFiltrados.sort(
            (a, b) => a.nome.toUpperCase().compareTo(b.nome.toUpperCase()));
      } else {
        produtos.sort(
            (a, b) => b.nome.toUpperCase().compareTo(a.nome.toUpperCase()));
        produtosFiltrados.sort(
            (a, b) => b.nome.toUpperCase().compareTo(a.nome.toUpperCase()));
      }
    });
  }

  void apagarTodos() {
    setState(() {
      produtos.clear();
    });
    // ignore: use_build_context_synchronously
    AlertaSnackbar.mostrarSnackbar(context, "Produtos apagados!");
  }

  void removeTodosDoCarrinho() {
    for (Produto produto in produtos) {
      if (produto.adicionado) {
        setState(() {
          produto.adicionado = false;
        });
      }
    }

    // ignore: use_build_context_synchronously
    AlertaSnackbar.mostrarSnackbar(context, "Produtos removidos do carrinho!");
  }

  void removeProdutosZerados() {
    setState(() {
      boolProdutosZerados = !boolProdutosZerados;
      if (boolProdutosZerados) {
        produtosZerados = "Ocultar produtos zerados";
      } else {
        produtosZerados = "Mostrar produtos zerados";
      }
    });

    // ignore: use_build_context_synchronously
    AlertaSnackbar.mostrarSnackbar(context, "Configuração alterada!");
  }

  void removeBarraPesquisa() {
    setState(() {
      boolBarraPesquisa = !boolBarraPesquisa;
      if (boolBarraPesquisa) {
        barraPesquisa = "Ocultar barra de pesquisa";
      } else {
        barraPesquisa = "Mostrar barra de pesquisa";
      }
    });

    // ignore: use_build_context_synchronously
    AlertaSnackbar.mostrarSnackbar(context, "Configuração alterada!");
  }

  void quantidade() {
    setState(() {
      boolBotaoOkOuQtd = !boolBotaoOkOuQtd;
    });
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
            onPressed: salvarListaProdutosBotao,
          ),
          IconButton(
            tooltip: "Ordenar",
            icon: opcaoOrdenacao == Ordenacao.crescente
                ? const Text("A-Z")
                : const Text("Z-A"),
            onPressed: () {
              setState(() {
                opcaoOrdenacao = opcaoOrdenacao == Ordenacao.crescente
                    ? Ordenacao.decrescente
                    : Ordenacao.crescente;
              });
              _ordenarLista();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'apagartodos') {
                apagarTodos();
              } else if (result == 'removecarrinho') {
                removeTodosDoCarrinho();
              } else if (result == 'produtosZerados') {
                removeProdutosZerados();
              } else if (result == 'barraPesquisa') {
                removeBarraPesquisa();
              } else if (result == 'botaoParaQuantidade') {
                quantidade();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'apagartodos',
                child: Text('Apagar todos'),
              ),
              const PopupMenuItem<String>(
                value: 'removecarrinho',
                child: Text('Remover todos do carrinho'),
              ),
              PopupMenuItem<String>(
                value: 'produtosZerados',
                child: Text(produtosZerados),
              ),
              PopupMenuItem<String>(
                value: 'botaoParaQuantidade',
                child: Text(
                    'Mudar para ${boolBotaoOkOuQtd ? "OK" : "Quantidade"}'),
              ),
            ],
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                if (boolBarraPesquisa)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _controllerPesquisa,
                      decoration: const InputDecoration(
                        labelText: 'Pesquisar',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                Expanded(
                  child: produtos.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Center(
                              child: Text('Nenhum item na lista.'),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .white, // Define a cor de fundo do botão como branco
                                foregroundColor: Colors
                                    .black, // Define a cor do texto como preto
                              ),
                              onPressed: () {
                                carregarListaProdutos();
                              },
                              child: Text('Recarregar'),
                            )
                          ],
                        )
                      : ListView.builder(
                          itemCount: produtosFiltrados.length,
                          itemBuilder: (context, index) {
                            if (!boolProdutosZerados &&
                                produtosFiltrados[index].quantidade == 0) {
                              return SizedBox.shrink();
                            }
                            return Card(
                              color: produtosFiltrados[index].adicionado
                                  ? Colors.green
                                  : null,
                              child: ListTile(
                                title: Text(produtosFiltrados[index].nome),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                            'R\$ ${produtosFiltrados[index].preco.toStringAsFixed(2)} - Qtd: ${produtosFiltrados[index].quantidade}'),
                                      ],
                                    ),
                                    Text(
                                        'Total: R\$ ${(produtosFiltrados[index].preco * produtosFiltrados[index].quantidade).toStringAsFixed(2)}'),
                                  ],
                                ),
                                onTap: () {
                                  var nomeProduto =
                                      produtosFiltrados[index].nome.toString();
                                  _controllerPesquisa.clear();
                                  _abrirTelaDetalhe(nomeProduto);
                                },
                                trailing: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!boolBotaoOkOuQtd)
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            produtosFiltrados[index]
                                                    .adicionado =
                                                !produtosFiltrados[index]
                                                    .adicionado;
                                          });
                                        },
                                        child:
                                            produtosFiltrados[index].adicionado
                                                ? const Text("X")
                                                : const Text("OK"),
                                      )
                                    else
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                              child: ElevatedButton(
                                            onLongPress: () {
                                              setState(() {
                                                produtosFiltrados[index]
                                                    .quantidade = 0;
                                              });
                                            },
                                            onPressed: () {
                                              setState(() {
                                                if (produtosFiltrados[index]
                                                        .quantidade >
                                                    0) {
                                                  produtosFiltrados[index]
                                                      .quantidade--;
                                                }
                                              });
                                            },
                                            child: const Icon(Icons.remove),
                                          )),
                                          Flexible(
                                            child: IconButton(
                                              iconSize:
                                                  20, // Reduz o tamanho do botão
                                              icon: Text(
                                                  produtosFiltrados[index]
                                                      .quantidade
                                                      .toString()),
                                              onPressed: () {
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                          Flexible(
                                              child: ElevatedButton(
                                            onLongPress: () {
                                              setState(() {
                                                produtosFiltrados[index]
                                                    .quantidade = 0;
                                              });
                                            },
                                            onPressed: () {
                                              setState(() {
                                                produtosFiltrados[index]
                                                    .quantidade++;
                                              });
                                            },
                                            child: const Icon(Icons.add),
                                          )),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
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
        onPressed: () {
          _abrirTelaAdicionarProduto();
          _controllerPesquisa.clear();
        },
        tooltip: 'adiciona item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
