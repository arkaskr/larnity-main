import 'dart:convert';

class PaymintroCredsModel {
  final String? id;
  final DateTime? createdAt;
  final String paymintroClientId;
  final String paymintroSecretId;
  final String userId;

  PaymintroCredsModel({
    this.id,
    this.createdAt,
    required this.paymintroClientId,
    required this.paymintroSecretId,
    required this.userId,
  });

  PaymintroCredsModel copyWith({
    String? id,
    DateTime? createdAt,
    String? paymintroClientId,
    String? paymintroSecretId,
    String? userId,
  }) {
    return PaymintroCredsModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      paymintroClientId: paymintroClientId ?? this.paymintroClientId,
      paymintroSecretId: paymintroSecretId ?? this.paymintroSecretId,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      'paymintroClientId': paymintroClientId,
      'paymintroSecretId': paymintroSecretId,
      'userId': userId,
    };
  }

  factory PaymintroCredsModel.fromMap(Map<String, dynamic> map) {
    return PaymintroCredsModel(
      id: map['id'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      paymintroClientId: map['paymintroClientId'] ?? '',
      paymintroSecretId: map['paymintroSecretId'] ?? '',
      userId: map['userId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory PaymintroCredsModel.fromJson(String source) =>
      PaymintroCredsModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PaymintroCredsModel(id: $id, userId: $userId, clientId: $paymintroClientId)';
  }
}
