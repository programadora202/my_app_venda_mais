import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String userName;
  
  const HomeScreen({super.key, required this.userName});
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 255, 245, 242), //cor de fundo da tela
    
    appBar: AppBar(
      toolbarHeight: 70,
      title: Text(
        "Olá, $userName",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      backgroundColor: const Color.fromARGB(255, 115, 32, 54),
      centerTitle: true,

      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            iconSize: 20,
            icon: const Icon(
              Icons.people,
              color: Color.fromARGB(255, 115, 32, 54),
            ),
            onPressed: () {
              // Ação do botão
            },
          ),
        ),
      ),
      

      // Botão de sair
      actions: [
        IconButton(
          icon: const Icon(
            Icons.logout,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              '/login',
            );
          },
        ),
      ],
    ),

    body: ListView( // Use ListView para permitir rolagem
      padding: const EdgeInsets.all(16.0),
      children:[
        const SizedBox(height: 20), // Espaçamento entre o appBar e o primeiro container
        
      InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/new_sale');
        },
        child: Container(
          height: 200,
          width: 180,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 247, 232, 225),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_bag,
                  color: Color.fromARGB(255, 115, 32, 54),
                  size: 100,
                ),
                const SizedBox(width: 20), // Espaçamento entre o ícone e o texto
                const Text(
                  'NOVA VENDA',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

       
        
        const SizedBox(height: 20), // Espaçamento entre os containers
        InkWell(
          onTap:(){
            Navigator.pushNamed(context, '/storage');
          },

          child: Container(
            height: 200,
            width: 180,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 247, 232, 225),
              borderRadius: BorderRadius.circular(25),
            ), // Adicione a cor de fundo desejada
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: Color.fromARGB(255, 115, 32, 54),
                    size: 100,
                  ),
                  SizedBox(width: 20), // Espaçamento entre o ícone e o texto
                  Text(
                    'ESTOQUE E PRODUTOS',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                ]
              ),
              
            ), 
          ),
        ),
        
        
        const SizedBox(height: 30), // Espaçamento entre os containers

        Container(
          width: 180,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 254, 254),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Resumo de hoje:',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/dashboard');
                    },
                    child: const Text(
                      'Ver mais',
                      style: TextStyle(
                        color: Color.fromARGB(255, 115, 32, 54),
                        fontSize: 17,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              const Row(
                children: [
                  Icon(
                    Icons.shopping_cart,
                    color: Color.fromARGB(255, 115, 32, 54),
                    size: 35,
                  ),

                  SizedBox(width: 15),

                  Expanded(
                    child: Text(
                      'Vendas de hoje:',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

      ], //children
    ),
  );
} //build
} //class