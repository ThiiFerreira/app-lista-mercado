import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AlertaMensagem extends StatefulWidget {
  String mensagem;
  AlertaMensagem({Key? key, required this.mensagem}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AlertaMensagemState createState() => _AlertaMensagemState();
}

class _AlertaMensagemState extends State<AlertaMensagem> {
  @override
  Widget build(BuildContext context) {
    Widget okButton = ElevatedButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    return AlertDialog(
      title: const Text("ALERTA"),
      content: Text(widget.mensagem),
      actions: [
        okButton,
      ],
    );
  }
}
