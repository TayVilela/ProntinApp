//classe de dados (DTO) que fará a transferencia de dados (uma classe p outra)
import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  String? id;
  String? userName;
  String? email;
  String? password;
  String? name;
  String? birthday;
  String? gender;

  //metodo construtor
  Users({
    this.id,
    this.userName,
    this.email,
    this.name,
    this.password,
    this.birthday,
    this.gender,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      userName: json['userName'] ?? '',
      name: json['name'] ?? '',
      birthday: json['birthday'],
      gender: json['gender'],
    );
  }

  //metodo que converte os dados para formato mapa (compativel do Json)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'userName': userName,
      'name': name,
      'birthday': birthday,
      'gender': gender,
    };
  }

  //método construtor para converter dados do objeto do tipo documento do firebase
  //em formato compatível com o Objeto Users (esta própria classe)
}
