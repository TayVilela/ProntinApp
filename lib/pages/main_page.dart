import 'package:flutter/material.dart';
import 'package:prontin/pages/board_page.dart';
import 'package:prontin/pages/login_page.dart';
import 'package:prontin/pages/notepad_page.dart';
import 'package:prontin/pages/userprofile_page.dart';
import 'package:prontin/services/users_services.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(67, 152, 152, 1),
        elevation: 2,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logotipo_prontin.png',
              height: 35,
              fit: BoxFit.contain, //proporção da imagem
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await Provider.of<UsersServices>(context, listen: false).logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) =>
                    false, // Remove todas as telas anteriores
              );
            },
          ),
        ],
      ),
      body: [
        //item 1 do bottomNavigation (quadros)
        const Center(
          child: BoardPage(),
        ),

        //item 2 do bottomNavigation (bloco de notas)
        const Center(
          child: NotepadPage(),
        ),

        //item 3 do bottomNavigation (perfil do user)
        const Center(
          child: UserProfilePage(),
        )
      ][_index],

      //destinos do bottmNavigt
      bottomNavigationBar: NavigationBar(
          selectedIndex: _index, //define o indice ou a pagina atual

          //atualização de indice
          onDestinationSelected: (int position) {
            setState(() {
              _index = position;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.space_dashboard_rounded),
              label: 'Quadros',
            ),
            NavigationDestination(
              icon: Icon(Icons.sticky_note_2_rounded),
              label: 'Blocos de Notas',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_2_rounded),
              label: 'Perfil',
            ),
          ]),
    );
  }
}
