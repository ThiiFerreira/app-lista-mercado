import 'package:flutter/material.dart';
import 'package:lista_mercado/componentes/AlertaMensagem.dart';
import 'package:lista_mercado/componentes/AlertaSnackbar.dart';
import 'package:lista_mercado/models/Produto.dart';

class screenAdicionaProduto extends StatefulWidget {
  const screenAdicionaProduto({super.key});

  @override
  State<screenAdicionaProduto> createState() => _screenAdicionaProdutoState();
}

class _screenAdicionaProdutoState extends State<screenAdicionaProduto> {
  final _nomeController = TextEditingController();
  final _precoController = TextEditingController();
  final _quantidadeController = TextEditingController();
  bool loading = false;
  

  Future<void> _salvarNovoProduto(BuildContext context) async {
    setState(() {
      loading = true;
    });

    final nome = _nomeController.text;
    final preco = double.tryParse(_precoController.text) ?? 0.0;
    final quantidade =
        int.tryParse(_quantidadeController.text) ?? 0; // Obtenha a quantidade

    if (nome.isEmpty || preco < 0.0 || quantidade < 0) {
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
      final novoProduto = Produto(
        nome: nome,
        preco: preco,
        quantidade: quantidade,
      );


      setState(() {
        loading = false;
      });

      // ignore: use_build_context_synchronously
      AlertaSnackbar.mostrarSnackbar(context, "Produto criado com sucesso!");

      // ignore: use_build_context_synchronously
      Navigator.pop(context, novoProduto);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome do Produto'),
              ),
              TextField(
                controller: _precoController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Preço do Produto',  hintText: 'Ex: 1.99'),

              ),
              TextField(
                controller:
                    _quantidadeController, // Adicione o controlador para a quantidade
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Quantidade do Produto'),
              ),
              const SizedBox(height: 16),
              loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        _salvarNovoProduto(context);
                      },
                      child: const Text('Salvar Produto'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
