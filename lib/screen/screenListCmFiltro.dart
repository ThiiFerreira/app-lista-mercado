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
  bool boolBotaoOkOuQtd = false;
  bool boolDetalhesCarrinho = false;
  bool produtoAdicionado = false;
  Ordenacao opcaoOrdenacao = Ordenacao.crescente;
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

  void tiraFocoTeclado() {
    FocusScope.of(context).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _controllerPesquisa.clear();
  }

  void vizualizarDetalhesCarrinho() {
    setState(() {
      boolDetalhesCarrinho = !boolDetalhesCarrinho;
    });
  }

  void encontraProdutoAdicionado() {
    for (var produto in produtos) {
      if (produto.adicionado) {
        setState(() {
          produtoAdicionado = true;
        });
        break;
      }
    }
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
    setState(() {
      if (index >= 0 && index < produtos.length) {
        var nomeProduto = produtosFiltrados[index].nome.toString();
        print('Deletando filtrado ${produtosFiltrados[index].toMap()}');
        produtosFiltrados.removeAt(index);
        if (nomeProduto == produtos[index].nome.toString()) {
          print('Deletando original${produtos[index].toMap()}');
          produtos.removeAt(index);
        }
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
    tiraFocoTeclado();
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
    tiraFocoTeclado();
    encontraProdutoAdicionado();
  }

  int calcularQuantidadeItens() {
    int count = 0;
    for (var produto in produtos) {
      if (produto.quantidade > 0) {
        count++;
      }
    }
    return count;
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
    setState(() {
      produtoAdicionado = false;
    });
    // ignore: use_build_context_synchronously
    AlertaSnackbar.mostrarSnackbar(context, "Produtos removidos do carrinho!");
  }

  void removeProdutosZerados() {
    setState(() {
      boolProdutosZerados = !boolProdutosZerados;
    });

    // ignore: use_build_context_synchronously
    AlertaSnackbar.mostrarSnackbar(context, "Configuração alterada!");
  }

  void removeBarraPesquisa() {
    setState(() {
      boolBarraPesquisa = !boolBarraPesquisa;
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
              } else if (result == 'restartLista') {
                carregarListaProdutos();
              } else if (result == 'vizualizarDetalhesCarrinho') {
                vizualizarDetalhesCarrinho();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'vizualizarDetalhesCarrinho',
                child: Text(boolDetalhesCarrinho
                    ? 'Detalhes carrinho'
                    : 'Remover detalhes carrinho'),
              ),
              const PopupMenuItem<String>(
                value: 'restartLista',
                child: Text('Recarregar lista'),
              ),
              const PopupMenuItem<String>(
                value: 'apagartodos',
                child: Text('Apagar todos'),
              ),
              if (produtoAdicionado)
                PopupMenuItem<String>(
                  value: 'removecarrinho',
                  child: Text('Remover todos do carrinho'),
                ),
              PopupMenuItem<String>(
                value: 'produtosZerados',
                child: Text(boolProdutosZerados
                    ? 'Ocultar produtos zerados'
                    : 'Mostrar produtos zerados'),
              ),
              PopupMenuItem<String>(
                value: 'botaoParaQuantidade',
                child: Text('${boolBotaoOkOuQtd ? "Botao OK" : "Botoes +/-"}'),
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
                                title: Text('${produtosFiltrados[index].quantidade} - ${produtosFiltrados[index].nome}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                            'R\$ ${produtosFiltrados[index].preco.toStringAsFixed(2)}'),
                                      ],
                                    ),
                                    Text(
                                        'Total: R\$ ${(produtosFiltrados[index].preco * produtosFiltrados[index].quantidade).toStringAsFixed(2)}'),
                                  ],
                                ),
                                onTap: () {
                                  var nomeProduto =
                                      produtosFiltrados[index].nome.toString();
                                  tiraFocoTeclado();
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
                                            encontraProdutoAdicionado();
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
      bottomNavigationBar: boolDetalhesCarrinho
          ? null
          : Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[300],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'Total: R\$ ${calcularTotal().toStringAsFixed(2)} - itens: ${calcularQuantidadeItens()}',
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
          tiraFocoTeclado();
        },
        tooltip: 'adiciona item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
