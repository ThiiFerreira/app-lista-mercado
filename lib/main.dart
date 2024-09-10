import 'package:flutter/material.dart';
import 'package:lista_mercado/screen/screenListCmFiltro.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista Mercado',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        
        primaryColor: Colors.black, // Defina a cor primária como preto
        appBarTheme: const AppBarTheme(
          
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      home: const screenListaCmFiltro(),
    );
  }
}
