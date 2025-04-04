import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prontin/services/users_services.dart';

class EditUserProfilePage extends StatefulWidget {
  const EditUserProfilePage({super.key});

  @override
  State<EditUserProfilePage> createState() => _EditUserProfilePageState();
}

class _EditUserProfilePageState extends State<EditUserProfilePage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController birthdayController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String _gender = "Feminino";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final usersServices = Provider.of<UsersServices>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await usersServices.loadCurrentUser();

      if (usersServices.currentUser != null) {
        setState(() {
          nameController.text = usersServices.currentUser!.name!;
          usernameController.text = usersServices.currentUser!.userName!;
          emailController.text = usersServices.currentUser!.email!;
          birthdayController.text = usersServices.currentUser!.birthday!;
          _gender = usersServices.currentUser!.gender!;
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersServices>(
      builder: (context, usersServices, child) {
        final user = usersServices.currentUser;

        if (isLoading || user == null) {
          return Scaffold(
            backgroundColor: const Color.fromRGBO(11, 116, 116, 1.000),
            appBar: _buildAppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color.fromRGBO(11, 116, 116, 1.000),
          appBar: _buildAppBar(),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(nameController, 'Nome'),
                        const SizedBox(height: 10),
                        _buildTextField(usernameController, 'Usuário'),
                        const SizedBox(height: 10),
                        _buildTextField(emailController, 'E-mail'),
                        const SizedBox(height: 10),
                        _buildTextField(
                            birthdayController, 'Data de Nascimento'),
                        const SizedBox(height: 5),
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: Text("Gênero",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              )),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildGenderRadio("Feminino"),
                            _buildGenderRadio("Masculino"),
                            _buildGenderRadio("Não-Binário"),
                          ],
                        ),
                        const SizedBox(height: 25),
                        _buildTextField(passwordController,
                            'Senha Atual (Obrigatório para alterações)',
                            obscureText: true),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    try {
                                      setState(() => isLoading = true);

                                      await usersServices.updateUserProfile(
                                        nameController.text,
                                        usernameController.text,
                                        emailController.text,
                                        birthdayController.text,
                                        _gender,
                                        passwordController
                                            .text, // 🔹 Senha atual para reautenticação
                                      );

                                      setState(() => isLoading = false);
                                      Navigator.pop(context);
                                    } catch (error) {
                                      setState(() => isLoading = false);
                                      _showErrorDialog(error
                                          .toString()); // 🔹 Exibir erro caso a senha esteja errada
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor:
                                const Color.fromARGB(255, 52, 168, 67),
                          ),
                          child: const Text(
                            "Salvar Alterações",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await usersServices
                                      .resetPassword(user.email!);
                                  _showPasswordResetDialog();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: const Text("Mudar Senha",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _showDeleteAccountDialog(usersServices);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: const Text("Excluir Conta",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Editar Perfil", style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.teal[700],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool readOnly = false, bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      obscureText: obscureText, 
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Por favor, insira $label";
        }
        return null;
      },
    );
  }

  Widget _buildGenderRadio(String value) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: _gender,
          activeColor: Colors.teal[700],
          onChanged: (newValue) {
            setState(() {
              _gender = newValue!;
            });
          },
        ),
        Text(value, style: const TextStyle(color: Colors.black)),
      ],
    );
  }

  void _showPasswordResetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("E-mail enviado"),
          content: const Text(
              "Um e-mail foi enviado para que você possa redefinir sua senha."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(UsersServices usersServices) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Excluir Conta"),
          content: const Text(
              "Tem certeza que deseja excluir sua conta? Todos os seus dados serão apagados permanentemente."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                await usersServices.deleteUserAccount(context);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child:
                  const Text("Excluir", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Erro",
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK",
                  style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
            ),
          ],
        );
      },
    );
  }
}
