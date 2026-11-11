
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/new_sale_screen.dart';
import 'screens/storage_and_products.dart';
import 'screens/produtos_screen.dart';
import 'screens/forget_password.dart';
import 'screens/dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const VendaApp());
}

class VendaApp extends StatelessWidget {
  const VendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        // Aguarda o Firebase verificar a sessão.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Venda+',
            home: const Scaffold(
              backgroundColor: Color.fromARGB(255, 255, 245, 242),
              body: Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 115, 32, 54),
                ),
              ),
            ),
          );
        }

        // Verifica se existe um usuário autenticado.
        final usuario = snapshot.data;

        final nomeUsuario = usuario?.displayName?.trim().isNotEmpty == true
            ? usuario!.displayName!.trim()
            : usuario?.email?.split('@').first ?? 'Usuário';

        return MaterialApp(
          // Reinicia a navegação quando o estado de autenticação muda.
          key: ValueKey(usuario?.uid ?? 'sem-login'),

          debugShowCheckedModeBanner: false,
          title: 'Venda+',

          // Define a primeira tela conforme a autenticação.
          home: usuario == null
              ? const LoginScreen()
              : HomeScreen(userName: nomeUsuario),

          onGenerateRoute: (settings) {
            final rota = settings.name;
            final autenticado = usuario != null;

            // Impede usuários autenticados de voltarem
            // para as telas de login e cadastro.
            if (autenticado &&
                (rota == '/login' ||
                    rota == '/registro' ||
                    rota == '/esqueci_senha')) {
              return MaterialPageRoute(
                builder: (context) =>
                    HomeScreen(userName: nomeUsuario),
              );
            }

            // Libera as telas públicas sem autenticação.
            if (!autenticado) {
              switch (rota) {
                case '/login':
                  return MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  );

                case '/registro':
                  return MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  );

                case '/esqueci_senha':
                  return MaterialPageRoute(
                    builder: (context) => const ForgetPassword(),
                  );

                default:
                  // Bloqueia qualquer outra rota.
                  return MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  );
              }
            }

            // A partir daqui, somente usuários autenticados
            // conseguem acessar as telas protegidas.
            switch (rota) {
              case '/home':
                final nome = settings.arguments as String?;

                return MaterialPageRoute(
                  builder: (context) => HomeScreen(
                    userName: nome ?? nomeUsuario,
                  ),
                );

              case '/new_sale':
                return MaterialPageRoute(
                  builder: (context) => const NewSaleScreen(),
                );

              case '/produtos':
                return MaterialPageRoute(
                  builder: (context) => const ProdutosScreen(),
                );

              case '/storage':
                return MaterialPageRoute(
                  builder: (context) => const StorageAndProducts(),
                );

              case '/dashboard':
                return MaterialPageRoute(
                  builder: (context) => const Dashboard(),
                );

              default:
                return MaterialPageRoute(
                  builder: (context) =>
                      HomeScreen(userName: nomeUsuario),
                );
            }
          },
        );
      },
    );
  }
}
