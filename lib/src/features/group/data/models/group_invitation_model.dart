import 'package:equatable/equatable.dart';

enum InvitationStatus { PENDING, ACCEPTED, REVOKED }

enum PlanType { MONTHLY, YEARLY, LIFETIME }

class GroupInvitationModel extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String email;
  final String? name;
  final String? token;
  final PlanType planType;
  final InvitationStatus status;
  final String groupId;
  final String inviterId;
  final DateTime? expiresAt;
  final DateTime? acceptedAt;
  final DateTime? revokedAt;

  const GroupInvitationModel({
    this.id,
    this.createdAt,
    required this.email,
    this.name,
    this.token,
    required this.planType,
    this.status = InvitationStatus.PENDING,
    required this.groupId,
    required this.inviterId,
    this.expiresAt,
    this.acceptedAt,
    this.revokedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'name': name,
      'token': token,
      'planType': planType.name,
      'status': status.name,
      'groupId': groupId,
      'inviterId': inviterId,
      'expiresAt': expiresAt?.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'revokedAt': revokedAt?.toIso8601String(),
    }..removeWhere((key, value) => value == null);
  }

  factory GroupInvitationModel.fromMap(Map<String, dynamic> map) {
    return GroupInvitationModel(
      id: map['id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      email: map['email'] as String,
      name: map['name'] as String?,
      token: map['token'] as String?,
      planType: PlanType.values.firstWhere(
        (e) => e.name == map['planType'],
        orElse: () => PlanType.MONTHLY,
      ),
      status: InvitationStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => InvitationStatus.PENDING,
      ),
      groupId: map['groupId'] as String,
      inviterId: map['inviterId'] as String,
      expiresAt: map['expiresAt'] != null
          ? DateTime.parse(map['expiresAt'] as String)
          : null,
      acceptedAt: map['acceptedAt'] != null
          ? DateTime.parse(map['acceptedAt'] as String)
          : null,
      revokedAt: map['revokedAt'] != null
          ? DateTime.parse(map['revokedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        email,
        name,
        token,
        planType,
        status,
        groupId,
        inviterId,
        expiresAt,
        acceptedAt,
        revokedAt,
      ];

  @override
  bool get stringify => true;
}
