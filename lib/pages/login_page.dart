import 'package:flutter/material.dart';
import 'package:prontin/pages/main_page.dart';
import 'package:prontin/pages/signup_page.dart';
import 'package:prontin/services/users_services.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //CONTROLLERS
  bool _obscurePassword = true;

  final TextEditingController _email = TextEditingController();

  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth =
        MediaQuery.of(context).size.width; //descobre a largura da tela
    return Scaffold(
      backgroundColor: const Color.fromRGBO(11, 116, 116, 1.000),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50.0), //espaçamento nas bordas
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.start, //alinhamento do eixe principal
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logotipo_prontin.png',
                    height: 300,
                    width: screenWidth * 0.8,
                    fit: BoxFit.contain, //proporção da imagem
                  ),
                ],
              ),
              const Text(
                  "Não é sobre ser perfeito, é sobre dar o primeiro passo. Organize suas ideias, planeje suas metas e avance no seu ritmo. Vamos juntos transformar sonhos em conquistas!",
                  style: TextStyle(fontSize: 20)),
              //espaçamento com SizedBox
              const SizedBox(
                height: 50,
              ),
              const Text("Vem fazer seu login!",
                  style: TextStyle(
                      fontSize: 50,
                      fontFamily: 'LazyDog',
                      color: Color.fromRGBO(241, 221, 136, 1.000))),
              //inicio campo email
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.alternate_email_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      "E-mail",
                      style: TextStyle(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 1.7, color: Colors.white))),
              ), //fim campo email
              const SizedBox(
                height: 10,
              ),
              // inicio campo senha
              TextFormField(
                obscureText: _obscurePassword,
                controller: _password,
                decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.key,
                      color: Colors.white,
                    ),
                    suffixIcon: InkWell(
                      onTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white,
                      ),
                    ),
                    label: const Text(
                      "Senha",
                      style: TextStyle(color: Colors.white),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.white),
                    ),
                    focusedBorder: const OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 1.7, color: Colors.white))),
              ), //fim campo senha

              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(top: 5, bottom: 22),
                child: TextButton(
                  onPressed: () =>
                      _showForgotPasswordDialog(context), // Corrigido!
                  child: const Text(
                    "Vish, esqueci minha senha...",
                    style: TextStyle(
                      color: Color.fromRGBO(255, 225, 0, 1),
                    ),
                  ),
                ),
              ),

              //botao de login
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final usersServices =
                          Provider.of<UsersServices>(context, listen: false);

                      usersServices.signIn(
                        email: _email.text,
                        password: _password.text,
                        onSuccess: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => MainPage()),
                          );
                        },
                        onFail: (e) {
                          var snack = SnackBar(
                            content: Text(e),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(20),
                            elevation: 15,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snack);
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 1.5,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text(
                      "Login",
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 5,
              ),

              //redirecionamento para cadastro
              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignUpPage()));
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Quero criar minha conta",
                        style:
                            TextStyle(color: Color.fromRGBO(255, 225, 0, 1))),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Recuperação de Senha",style: TextStyle(color: Colors.black),),
          content: TextField(
            controller: emailController,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              labelText: "Digite seu e-mail",
              labelStyle: const TextStyle(color: Colors.black),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (emailController.text.isNotEmpty) {
                  bool success =
                      await Provider.of<UsersServices>(context, listen: false)
                          .resetPassword(emailController.text);

                  Navigator.pop(context); 

                  // exibe a confirmação
                  _showConfirmationDialog(
                      context,
                      success
                          ? "E-mail enviado! Verifique sua caixa de entrada."
                          : "Erro ao enviar e-mail. Verifique o endereço informado.");
                }
              },
              child: const Text("Enviar"),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Recuperação de Senha"),
          content: Text(message),
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
}
