import 'package:app_lista_mercado/componentes/AlertaMensagem.dart';
import 'package:app_lista_mercado/models/Produto.dart';
import 'package:flutter/material.dart';

class screenAtualizaProduto extends StatefulWidget {
  final Produto produto;
  const screenAtualizaProduto({super.key, required this.produto});

  @override
  State<screenAtualizaProduto> createState() => _screenAtualizaProdutoState();
}

class _screenAtualizaProdutoState extends State<screenAtualizaProduto> {
  late TextEditingController _nomeController;
  late TextEditingController _precoController;
  late TextEditingController _quantidadeController;
  bool loading = false;

  void _atualizarProduto() async {
    setState(() {
      loading = true;
    });
    // Obtenha os novos valores dos campos de edição
    final novoNome = _nomeController.text;
    final novoPreco = double.tryParse(_precoController.text) ?? 0.0;
    final novaQuantidade = int.tryParse(_quantidadeController.text) ?? 0;

    if (novoNome.isEmpty || novoPreco <= 0.0 || novaQuantidade < 0) {
      setState(() {
        loading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertaMensagem(
              mensagem: "Preencha todos os campos corretamente.");
        },
      );
    } else {
      // Atualize o objeto Produto com os novos valores
      final produtoAtualizado = Produto(
        nome: novoNome,
        preco: novoPreco,
        quantidade: novaQuantidade,
        adicionado: widget.produto.adicionado
      );

      setState(() {
        loading = false;
      });
      Navigator.pop(context, produtoAtualizado);
    }
  }

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.produto.nome);
    _precoController =
        TextEditingController(text: widget.produto.preco.toStringAsFixed(2));
    _quantidadeController =
        TextEditingController(text: widget.produto.quantidade.toString());
    _precoController.addListener(_formatarPreco);
  }
  void _formatarPreco() {
    String text = _precoController.text.replaceAll(RegExp(r'[^\d]'), '');

    if (text.isNotEmpty) {
      double value = double.parse(text) / 100;
      _precoController.value = TextEditingValue(
        text: value.toStringAsFixed(2),
        selection: TextSelection.collapsed(offset: value.toStringAsFixed(2).length),
      );
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome do Produto'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precoController,
                decoration: const InputDecoration(labelText: 'Preço'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantidadeController,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        _atualizarProduto();
                      },
                      child: const Text('Salvar Alterações'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
