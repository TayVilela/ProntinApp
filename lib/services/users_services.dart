import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:prontin/models/users.dart';
import 'package:provider/provider.dart';

class UsersServices extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance; //instancia do firebaseauth
  final FirebaseFirestore _firestore = FirebaseFirestore
      .instance; //instancia do firebasestore p/ se comunicar com firebase

  Users? users;
  Users? currentUser;
  Users? get CurrentUser => currentUser;

  DocumentReference get _firestoreRef => _firestore.doc(
      'users/${users!.id}'); //metodo para pegar referencai e criar firestore

  UsersServices() {
    print("Inicializando UsersServices...");
    print("Usuário autenticado? ${_auth.currentUser?.uid}");
    _loadingCurrentUser();
    loadUserProfile();
    listenForEmailChange(); // Agora escutamos mudanças no e-mail
  }

  Future<bool> signUp(String email, String password, String name,
      String username, String birthday, String gender) async {
    try {
      User? user = (await _auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;

      if (user == null) {
        return Future.value(false);
      }

      users = Users(
        // 🚀 Agora inicializamos a variável `users`
        id: user.uid,
        email: email,
        userName: username,
        name: name,
        gender: gender,
        birthday: birthday,
      );

      await saveUsersDetails(); // Salvar os detalhes no Firestore

      notifyListeners(); // Notificar a UI que o usuário foi criado
      return Future.value(true);
    } on FirebaseAuthException catch (error) {
      print("Erro ao criar usuário: ${error.code}");
      return Future.value(false);
    }
  }

  Future<void> loadUserProfile() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      print("⚠️ Nenhum usuário autenticado.");
      return;
    }

    try {
      print("🔄 Carregando perfil do usuário: ${firebaseUser.uid}");

      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        print("✅ Perfil encontrado!");
        currentUser = Users.fromJson(userDoc.data()!);
      } else {
        print("⚠️ Nenhum dado encontrado para este usuário.");
        currentUser = Users(
          id: firebaseUser.uid,
          email: firebaseUser.email!,
          userName: "Novo Usuário",
          name: "Nome não disponível",
        );
      }

      notifyListeners(); // 🚀 Atualiza a UI
    } catch (e) {
      print("❌ Erro ao carregar usuário: $e");
    }
  }

  Future<void> signIn(
      {String? email,
      String? password,
      Function? onSucess,
      Function? onFail}) async {
    try {
      print("🔐 Tentando autenticar usuário com email: $email");

      User? user = (await _auth.signInWithEmailAndPassword(
        email: email!,
        password: password!,
      ))
          .user;

      print("✅ Usuário autenticado: ${user!.uid}");

      await loadUserProfile(); // 🔄 Agora carregamos o perfil imediatamente após login
      notifyListeners(); // 🚀 Garante que a UI seja atualizada após login

      onSucess!(); // Chama o callback de sucesso
    } on FirebaseAuthException catch (e) {
      String code;
      if (e.code == 'invalid-email') {
        code = 'Email informado é inválido';
      } else if (e.code == 'wrong-password') {
        code = 'A senha informada está errada';
      } else if (e.code == 'user-disabled') {
        code = 'Já existe cadastro com este email!!';
      } else {
        code = "Algum erro aconteceu na Plataforma do Firebase";
      }
      print("❌ Erro ao autenticar: $code");
      onFail!(code);
    }
  }

  //salvar dados do usuario no Firestore p gravar dados
  saveUsersDetails() async {
    await _firestoreRef.set(users!.toJson());
  }

  Future<void> _loadingCurrentUser({User? user}) async {
    print("🔄 Chamando _loadingCurrentUser()...");

    try {
      User? currentUser = user ?? _auth.currentUser;
      if (currentUser == null) {
        print(
            "⚠️ Nenhum usuário autenticado, abortando _loadingCurrentUser().");
        return;
      }

      DocumentSnapshot<Map<String, dynamic>> docUser =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (docUser.exists && docUser.data() != null) {
        print("✅ Usuário encontrado no Firebase!");
        users = Users.fromJson(docUser.data()!); // ✅ Conversão correta
      } else {
        print(
            "⚠️ Nenhum dado encontrado para este usuário, criando usuário temporário.");
        users = Users(
          id: currentUser.uid,
          email: currentUser.email!,
          userName: "Novo Usuário",
          name: "Sem Nome",
        );
      }

      notifyListeners(); // 🚀 Garante que a UI seja atualizada
    } catch (e) {
      print("❌ Erro ao carregar usuário: $e");
    }
  }

  // Método para atualizar os dados do perfil do usuário
  Future<void> updateUserProfile(
    String name,
    String username,
    String email,
    String birthday,
    String gender,
  ) async {
    if (currentUser == null || currentUser!.id == null) return;

    try {
      await _firestore.collection('users').doc(currentUser!.id).update({
        'name': name,
        'userName': username,
        'email': email,
        'birthday': birthday,
        'gender': gender,
      });

      // Atualiza os dados localmente sem precisar recarregar do Firestore
      currentUser = Users(
        id: currentUser!.id,
        name: name,
        userName: username,
        email: email,
        birthday: birthday,
        gender: gender,
      );

      notifyListeners(); // 🚀 Atualiza a UI automaticamente

      print("🎉 Perfil atualizado com sucesso!");
    } catch (e) {
      print("❌ Erro ao atualizar perfil: $e");
    }
  }

  Future<void> listenForEmailChange() async {
    _auth.userChanges().listen((User? user) async {
      print("📢 Detectando mudanças no usuário...");

      if (user != null) {
        print("✅ Novo e-mail detectado: ${user.email}");

        // Garantir que users não seja null antes de atualizar
        if (users == null || users!.id == null) {
          print(
              "⚠️ Nenhum usuário carregado, abortando atualização de e-mail.");
          return;
        }

        // Verifica se o e-mail no Firestore já está atualizado
        print("🔍 E-mail atual no Firestore: ${users!.email}");

        if (user.email != users!.email) {
          print("🚀 Atualizando e-mail no Firestore para: ${user.email}");

          try {
            await _firestore.collection('users').doc(users!.id).update({
              'email': user.email!,
            });

            users!.email = user.email!;
            notifyListeners();
            print("🎉 E-mail atualizado no Firestore com sucesso!");
          } catch (e) {
            print("❌ Erro ao atualizar e-mail no Firestore: $e");
          }
        } else {
          print("⚠️ O e-mail no Firestore já está atualizado.");
        }
      } else {
        print("❌ Nenhum usuário autenticado.");
      }
    });
  }

  // Método para excluir a conta do usuário
  Future<void> deleteUserAccount() async {
    if (users == null || users!.id == null) return;

    try {
      // Exclui os dados do Firestore
      await _firestore.collection('users').doc(users!.id).delete();

      // Exclui a conta do Firebase Authentication
      await _auth.currentUser!.delete();

      // Reseta os dados locais
      users = null;

      notifyListeners(); // Atualiza a interface
    } catch (e) {
      debugPrint("Erro ao excluir conta: $e");
    }
  }

  // Método para alterar a senha do usuário autenticado
  Future<String?> changePassword(
      String currentPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        return "Usuário não autenticado.";
      }

      // Reautenticar usuário antes de alterar a senha
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      return null; // Indica que a alteração foi bem-sucedida
    } catch (e) {
      return e
          .toString(); // Retorna o erro como string para ser tratado na View
    }
  }

// Método para logout do usuário
  Future<void> logout() async {
    await _auth.signOut();
    currentUser = null; // Limpa os dados do usuário autenticado
    notifyListeners(); // Atualiza a UI
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
