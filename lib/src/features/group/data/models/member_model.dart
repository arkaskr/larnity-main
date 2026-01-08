class MemberModel {
  final String id;
  final String userId;
  final String groupId;
  final String role; // ADMIN, MEMBER, MANAGER
  final bool isActive;
  final String planType;
  final DateTime subscriptionStartDate;
  final DateTime? subscriptionEndDate;

  // User details (joined from Users table)
  final String? userName;
  final String? userEmail;
  final String? userAvatar;

  MemberModel({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.role,
    required this.isActive,
    required this.planType,
    required this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.userName,
    this.userEmail,
    this.userAvatar,
  });

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      id: map['id'],
      userId: map['userId'],
      groupId: map['groupId'],
      role: map['role'],
      isActive: map['isActive'] ?? true,
      planType: map['planType'],
      subscriptionStartDate: DateTime.parse(map['subscriptionStartDate']),
      subscriptionEndDate: map['subscriptionEndDate'] != null
          ? DateTime.parse(map['subscriptionEndDate'])
          : null,
      userName: map['Users']?['name'],
      userEmail: map['Users']?['email'],
      userAvatar: map['Users']?['avatar'],
    );
  }
}
