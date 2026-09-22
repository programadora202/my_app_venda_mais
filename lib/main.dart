import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/produtos_screen.dart';
import 'screens/produtos_details_screen.dart';
import 'screens/new_sale_screen.dart';
import 'screens/sale_completed_screen.dart';

void main() {
  runApp(const VendaApp());
}

class VendaApp extends StatelessWidget {
  const VendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //retira o banner vermelho
      title: 'Venda+',

      routes: {
        '/login': (context) => const LoginScreen(),
        '/registro': (context) => const RegisterScreen(),

        '/home': (context) => const HomeScreen(),
        '/produtos': (context) => const ProdutosScreen(),
        '/produto_details': (context) => const ProdutoDetailsScreen(),
        '/new_sale': (context) => const NewSaleScreen(),
        '/sales_completed': (context) => const SaleCompletedScreen(),
      },
      initialRoute: '/login', //tela inicial

    );
  }
}