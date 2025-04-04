import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prontin/models/users.dart';
import 'package:prontin/pages/login_page.dart';

class UsersServices extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Users? currentUser;

  UsersServices() {
    print("🔄 Inicializando UsersServices...");
    loadCurrentUser();
    listenForEmailChange();
  }

  Future<void> loadCurrentUser() async {
    User? firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      print("⚠️ Nenhum usuário autenticado.");
      currentUser = null;
      notifyListeners();
      return;
    }

    print("🔍 Obtendo dados do Firestore para UID: ${firebaseUser.uid}");

    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await _firestore.collection('users').doc(firebaseUser.uid).get();

    if (userDoc.exists && userDoc.data() != null) {
      print("✅ Usuário encontrado! Dados: ${userDoc.data()}");

      if (userDoc.data()?['email'] != firebaseUser.email) {
        print("⚠️ Corrigindo e-mail no Firestore...");
        await _firestore.collection('users').doc(firebaseUser.uid).update({
          'email': firebaseUser.email,
        });
      }

      currentUser = Users.fromJson(userDoc.data()!);
    } else {
      print(
          "⚠️ Nenhum dado encontrado para este usuário, criando novo perfil.");

      currentUser = Users(
        id: firebaseUser.uid,
        email: firebaseUser.email!,
        userName: "Novo Usuário",
        name: "Sem Nome",
      );

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(currentUser!.toJson());
    }

    notifyListeners();
  }

  Future<bool> signUp(String email, String password, String name,
      String username, String birthday, String gender) async {
    try {
      User? user = (await _auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;

      if (user == null) return Future.value(false);

      currentUser = Users(
        id: user.uid,
        email: email,
        userName: username,
        name: name,
        gender: gender,
        birthday: birthday,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(currentUser!.toJson());
      notifyListeners();
      return Future.value(true);
    } on FirebaseAuthException catch (error) {
      print("❌ Erro ao criar usuário: ${error.code}");
      return Future.value(false);
    }
  }

  Future<void> signIn(
      {required String email,
      required String password,
      required Function onSuccess,
      required Function onFail}) async {
    try {
      print("🔐 Tentando autenticar usuário com email: $email");

      // Limpa os dados do usuário anterior antes de autenticar
      currentUser = null;
      notifyListeners(); //

      User? user = (await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ))
          .user;

      print("✅ Usuário autenticado: ${user!.uid}");

      await loadCurrentUser();
      notifyListeners();
      onSuccess();
    } on FirebaseAuthException catch (e) {
      String message = "Erro ao autenticar usuário.";
      if (e.code == 'invalid-email') {
        message = 'Email informado é inválido.';
      } else if (e.code == 'wrong-password') {
        message = 'A senha informada está errada.';
      } else if (e.code == 'user-disabled') {
        message = 'Conta desativada.';
      }
      print("❌ $message");
      onFail(message);
    }
  }

  Future<void> updateUserProfile(
    String name,
    String username,
    String newEmail,
    String birthday,
    String gender,
    String
        currentPassword, // 🚀 Senha necessária para reautenticar antes da alteração
  ) async {
    if (currentUser == null) return;

    try {
      print("🔄 Iniciando atualização do perfil para ID: ${currentUser!.id}");

      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("❌ Nenhum usuário autenticado.");
        return;
      }

      bool emailChanged = newEmail != user.email;
      bool reauthenticated = false;

      if (emailChanged) {
        print("📢 Novo e-mail detectado: $newEmail. Reautenticando usuário...");

        try {
          AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: currentPassword,
          );

          await user.reauthenticateWithCredential(credential);
          print("✅ Reautenticação bem-sucedida!");
          reauthenticated = true;
        } catch (e) {
          print("❌ Erro na reautenticação: $e");
          throw "Senha incorreta!"; // 🚨 Interrompe a execução para evitar erros
        }
      }

      // 🚀 Se o e-mail mudou e a reautenticação foi bem-sucedida, atualiza o Firebase Authentication
      if (emailChanged && reauthenticated) {
        try {
          await user.updateEmail(newEmail);
          print(
              "✅ E-mail atualizado no Firebase Authentication para: $newEmail");
        } catch (e) {
          print("❌ Erro ao atualizar e-mail no Firebase Authentication: $e");
          throw "Falha ao atualizar e-mail no Firebase!"; // 🚨 Interrompe antes de modificar o Firestore
        }
      }

      // 🚀 Atualizar os outros dados no Firestore
      await _firestore.collection('users').doc(currentUser!.id).update({
        'name': name,
        'userName': username,
        'email': newEmail, // 🔹 Garantindo a atualização no Firestore
        'birthday': birthday,
        'gender': gender,
      });

      print("✅ Perfil atualizado no Firestore!");

      // 🔹 Atualizar os dados localmente
      currentUser = Users(
        id: currentUser!.id,
        name: name,
        userName: username,
        email: newEmail,
        birthday: birthday,
        gender: gender,
      );

      notifyListeners();
    } catch (e) {
      print("❌ Erro ao atualizar perfil: $e");
      throw e; // 🚨 Lança erro para ser tratado na interface
    }
  }

  Future<void> listenForEmailChange() async {
    _auth.userChanges().listen((User? user) async {
      print("📢 Detectando mudanças no usuário...");

      if (user != null && currentUser != null) {
        if (user.email != currentUser!.email) {
          print("🚀 Atualizando e-mail no Firestore...");
          await _firestore.collection('users').doc(currentUser!.id).update({
            'email': user.email!,
          });

          currentUser!.email = user.email!;
          notifyListeners();
        }
      }
    });
  }

  Future<void> logout() async {
    await _auth.signOut();
    currentUser = null;
    notifyListeners(); // 🚀 Atualiza a UI imediatamente
    print("✅ Logout realizado com sucesso!");
  }

  // Método para excluir a conta do usuário
  Future<void> deleteUserAccount(BuildContext context) async {
  if (currentUser == null || currentUser!.id == null) return;

  try {
    // 🔥 Exclui os dados do Firestore
    await _firestore.collection('users').doc(currentUser!.id).delete();

    // Exclui a conta do Firebase Authentication
    await _auth.currentUser!.delete();

    // 🔥 Reseta os dados locais
    currentUser = null;

    notifyListeners(); // 🚀 Atualiza a interface

    // 🔄 Fecha todas as telas e vai para a tela de login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // 🔹 Altere para a sua tela de login
      (route) => false, // 🔥 Remove todas as rotas anteriores da pilha
    );

    print("✅ Conta excluída e usuário redirecionado para login!");
  } catch (e) {
    debugPrint("❌ Erro ao excluir conta: $e");
  }
}


  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("✅ E-mail de redefinição enviado para: $email");
      return true;
    } catch (e) {
      print("❌ Erro ao enviar e-mail de redefinição: $e");
      return false;
    }
  }

}
