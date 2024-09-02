import 'package:flutter/material.dart';

class CampoPreenchimento extends StatelessWidget {
  final TextEditingController controlador;
  final String rotulo;
  final IconData? icone;
  final String? dica;
  final TextInputType? teclado;
  final bool? enable;

  const CampoPreenchimento({
    super.key,
    required this.controlador,
    required this.rotulo,
    this.dica,
    this.icone,
    this.teclado,
    this.enable,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      keyboardType: teclado ?? TextInputType.name,
      decoration: InputDecoration(
        prefixIcon: icone != null ? Icon(icone) : null,
        labelText: rotulo,
        border: const OutlineInputBorder(),
        hintText: dica,
        labelStyle: const TextStyle(
          //color: Colors.black38,
          fontWeight: FontWeight.w400,
          fontSize: 20,
        ),
        enabled: enable == true ? false : true,
      ),
      style: const TextStyle(fontSize: 20)
    );
  }
}

                    