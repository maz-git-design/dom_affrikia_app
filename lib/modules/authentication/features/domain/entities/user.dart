// import 'package:dom_affrikia_app/core/enums/user.enum.dart';
// import 'package:equatable/equatable.dart';

// class User extends Equatable {
//   final String? id;
//   final String? role;
//   final String? status;
//   final String? name;
//   final String? email;
//   final String? phone;
//   final String? sexe;
//   final String? password;

//   const User({this.role, this.id, this.name, this.email, this.phone, this.status, this.sexe, this.password});

//   UserEnum get userRole {
//     switch (role) {
//       case "attender":
//         return UserEnum.attender;
//       default:
//         return UserEnum.unknown;
//     }
//   }

//   String get roleFormatted => role == "attender" ? "Gestionner" : "Inconnu";

//   User copyWith({String? id, String? status, String? name, String? email, String? phone}) {
//     return User(
//       id: id ?? this.id,
//       status: status ?? this.status,
//       name: name ?? this.name,
//       email: email ?? this.email,
//       phone: phone ?? this.phone,
//     );
//   }

//   Map<String, dynamic> toJson() => {'name': name, 'phone': phone, 'email': email, 'role': role, 'password': password};

//   Map<String, dynamic> toEditJson() => {'name': name, 'phone': phone, 'email': email};

//   @override
//   List<Object?> get props => [id, role];
// }
