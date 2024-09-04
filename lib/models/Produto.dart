class Produto {
  final String nome;
  final double preco;
  late  int quantidade;
  final int index;
  bool adicionado = false;

  Produto(
      {required this.nome,
      required this.preco,
      required this.quantidade,
      this.adicionado = false,
      this.index = 0});

  // Método para converter um Produto em um mapa
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'preco': preco,
      'quantidade': quantidade,
      'adicionado': adicionado,
      'index' : index,
    };
  }
}
