import 'package:equatable/equatable.dart';

class SupporterModel extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String groupId;
  final String userId;
  final String phoneNumber;
  final String? whatsappNumber;
  final String? link;

  const SupporterModel({
    this.id,
    this.createdAt,
    required this.groupId,
    required this.userId,
    required this.phoneNumber,
    this.whatsappNumber,
    this.link,
  });

  SupporterModel copyWith({
    String? id,
    DateTime? createdAt,
    String? groupId,
    String? userId,
    String? phoneNumber,
    String? whatsappNumber,
    String? link,
  }) {
    return SupporterModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      link: link ?? this.link,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'groupId': groupId,
      'userId': userId,
      'phoneNumber': phoneNumber,
      'whatsappNumber': whatsappNumber,
      'link': link,
    }..removeWhere((key, value) => value == null);
  }

  factory SupporterModel.fromMap(Map<String, dynamic> map) {
    return SupporterModel(
      id: map['id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      groupId: map['groupId'] as String,
      userId: map['userId'] as String,
      phoneNumber: map['phoneNumber'] as String,
      whatsappNumber: map['whatsappNumber'] as String?,
      link: map['link'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    groupId,
    userId,
    phoneNumber,
    whatsappNumber,
    link,
  ];

  @override
  bool get stringify => true;
}
