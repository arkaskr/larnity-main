// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? image;
  final String? email;
  final String role;
  final String? phoneNumber;
  UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.image,
    this.email,
    this.role = "user",
    this.phoneNumber,
  });

  String? get name {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName;
    } else if (lastName != null) {
      return lastName;
    }
    return email; // Fallback to email if no name
  }

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? image,
    String? email,
    String? role,
    String? phoneNumber,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      image: image ?? this.image,
      email: email ?? this.email,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'firstname': firstName,
      'lastname': lastName,
      'image': image,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
    }..removeWhere((key, value) => value == null);
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] != null ? map['id'] as String : null,
      firstName: map['firstname'] != null ? map['firstname'] as String : null,
      lastName: map['lastname'] != null ? map['lastname'] as String : null,
      image: map['image'] != null ? map['image'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      role: map['role'] as String,
      phoneNumber: map['phoneNumber'] != null
          ? map['phoneNumber'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, firstName: $firstName, lastName: $lastName, image: $image, email: $email, role: $role, phoneNumber: $phoneNumber)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.image == image &&
        other.email == email &&
        other.role == role &&
        other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        image.hashCode ^
        email.hashCode ^
        role.hashCode ^
        phoneNumber.hashCode;
  }
}
