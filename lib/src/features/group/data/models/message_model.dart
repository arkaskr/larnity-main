import 'package:equatable/equatable.dart';

class MessageModel extends Equatable {
  final String id;
  final String? senderId; // ✅ Nullable
  final String? receiverId; // ✅ Nullable
  final String message;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    this.senderId,
    this.receiverId,
    required this.message,
    required this.createdAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String,
      senderId: map['senderid'] as String?, // ✅ Nullable cast
      receiverId: map['recieverId'] as String?, // ✅ Nullable cast
      message: map['message'] as String? ?? '', // ✅ Default empty string
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderid': senderId,
      'recieverId': receiverId,
      'message': message,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get content => message;
  String get senderName => 'User';

  @override
  List<Object?> get props => [id, senderId, receiverId, message, createdAt];
}

class MemberModel extends Equatable {
  final String id;
  final String userId;
  final String groupId;
  final String role;
  final bool isActive;
  final String? planType;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;

  // Display fields
  final String name;
  final String? email;
  final String? avatar;
  final bool isOnline;

  const MemberModel({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.role,
    this.isActive = true,
    this.planType,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    required this.name,
    this.email,
    this.avatar,
    this.isOnline = false,
  });

  // ✅ For chat_provider.dart (User join query)
  factory MemberModel.fromChatMap(Map<String, dynamic> map) {
    final userData = map['User'] as Map<String, dynamic>?;
    final firstName = userData?['firstname'] as String?;
    final lastName = userData?['lastname'] as String?;
    final fullName = [
      firstName,
      lastName,
    ].where((n) => n != null && n.isNotEmpty).join(' ');

    return MemberModel(
      id: map['userId'] as String,
      userId: map['userId'] as String,
      groupId: map['groupId'] as String? ?? '',
      role: map['role'] as String? ?? 'MEMBER',
      isActive: map['isActive'] as bool? ?? true,
      name: fullName.isEmpty ? 'Unknown' : fullName,
      avatar: userData?['image'] as String?,
    );
  }

  // ✅ For group_datasource.dart (Users join query)
  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      groupId: map['groupId'] as String,
      role: map['role'] as String,
      isActive: map['isActive'] ?? true,
      planType: map['planType'] as String?,
      subscriptionStartDate: map['subscriptionStartDate'] != null
          ? DateTime.parse(map['subscriptionStartDate'])
          : null,
      subscriptionEndDate: map['subscriptionEndDate'] != null
          ? DateTime.parse(map['subscriptionEndDate'])
          : null,
      name: map['profiles']?['firstname'] != null 
          ? '${map['profiles']['firstname']} ${map['profiles']['lastname'] ?? ''}'.trim()
          : map['Users']?['name'] ?? 'Unknown',
      email: map['profiles']?['email'] ?? map['Users']?['email'],
      avatar: map['profiles']?['image'] ?? map['Users']?['avatar'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    groupId,
    role,
    isActive,
    planType,
    subscriptionStartDate,
    subscriptionEndDate,
    name,
    email,
    avatar,
    isOnline,
  ];
}
