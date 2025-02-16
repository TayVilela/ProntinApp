import 'package:flutter/material.dart';
import 'package:prontin/pages/edituserprofile_page.dart';
import 'package:prontin/services/users_services.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(11, 116, 116, 1.0),
      appBar: AppBar(
        title: const Text(
          "Meu perfil",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Consumer<UsersServices>(
          builder: (context, usersServices, child) {
            // 🔄 Verifica se os dados do usuário ainda estão carregando
            if (usersServices.currentUser == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = usersServices.currentUser!;

            return Center(
              child: Container(
                padding: const EdgeInsets.all(25),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/images/simbolo_prontin.png',
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user.name!.isNotEmpty
                          ? user.name!
                          : "Nome não disponível",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user.userName!.isNotEmpty
                          ? "@${user.userName}"
                          : "@Não disponível",
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 5),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const EditUserProfilePage()),
                        );
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text("Editar Perfil"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromRGBO(11, 116, 116, 1.0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
