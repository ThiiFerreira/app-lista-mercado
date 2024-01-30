import 'package:flutter/material.dart';

class AlertaSnackbar {
  static void mostrarSnackbar(BuildContext context, String mensagem) {
    final snackBar = SnackBar(
      content: Text(mensagem),
      duration: const Duration(milliseconds: 1000),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
