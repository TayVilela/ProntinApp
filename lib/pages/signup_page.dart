import 'package:flutter/material.dart';
import 'package:prontin/pages/login_page.dart';
import 'package:prontin/services/users_services.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _name = TextEditingController();
  String _gender = "Feminino"; // Agora começa com Feminino
  final TextEditingController _birthday = TextEditingController();

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
              //espaçamento com SizedBox
              const SizedBox(
                height: 20,
              ),
              const Text("Crie seu cadastro *",
                  style: TextStyle(
                      fontSize: 50,
                      fontFamily: 'LazyDog',
                      color: Color.fromRGBO(241, 221, 136, 1.000))),

              //campo nome
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                    label: Text(
                      "Nome",
                      style: TextStyle(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 1.7, color: Colors.white))),
              ),

              const SizedBox(
                height: 10,
              ),

              const Text("Gênero",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              Column(
                children: [
                  _buildGenderRadio("Feminino"),
                  _buildGenderRadio("Masculino"),
                  _buildGenderRadio("Não-Binário"),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              TextFormField(
                controller: _birthday,
                decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.cake_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      "Data de Nascimento",
                      style: TextStyle(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 1.7, color: Colors.white))),
              ),

              const SizedBox(
                height: 10,
              ),

              TextFormField(
                controller: _username,
                decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.abc_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      "Usuário",
                      style: TextStyle(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 1.7, color: Colors.white))),
              ),

              const SizedBox(
                height: 10,
              ),

              //campo email
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
              ),

              const SizedBox(
                height: 10,
              ),

              // campo senha
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
              ),

              const SizedBox(
                height: 20,
              ),

              //botao login
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      UsersServices _usersServices = UsersServices();
                      if (await _usersServices.signUp(
                          _email.text,
                          _password.text,
                          _name.text,
                          _username.text,
                          _birthday.text,
                          _gender)) {
                        Navigator.of(context)
                            .pop(); //desce a pagina para o fim da pilha
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 1.5,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text("Cadastrar",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        )),
                  ),
                ],
              ),

              const SizedBox(
                height: 5,
              ),

              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Já tenho uma conta",
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

  // Função para gerar os RadioListTile
  Widget _buildGenderRadio(String value) {
    return RadioListTile(
      title: Text(value, style: TextStyle(color: Colors.white)),
      value: value,
      groupValue: _gender,
      activeColor: const Color.fromARGB(255, 255, 255, 255), // Cor da seleção
      selectedTileColor:
          Colors.teal.withOpacity(0.2), // Fundo levemente destacado
      onChanged: (newValue) {
        setState(() {
          _gender = newValue!;
        });
      },
    );
  }
}
