import 'package:equatable/equatable.dart';

class PromotionModel extends Equatable {
  final String id;
  final DateTime createdAt;
  final String code;
  final int discountRate;
  final String planType;
  final int maxUses;
  final int currentUses;
  final bool isActive;
  final String groupId;

  const PromotionModel({
    required this.id,
    required this.createdAt,
    required this.code,
    required this.discountRate,
    required this.planType,
    required this.maxUses,
    required this.currentUses,
    required this.isActive,
    required this.groupId,
  });

  PromotionModel copyWith({
    String? id,
    DateTime? createdAt,
    String? code,
    int? discountRate,
    String? planType,
    int? maxUses,
    int? currentUses,
    bool? isActive,
    String? groupId,
  }) {
    return PromotionModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      code: code ?? this.code,
      discountRate: discountRate ?? this.discountRate,
      planType: planType ?? this.planType,
      maxUses: maxUses ?? this.maxUses,
      currentUses: currentUses ?? this.currentUses,
      isActive: isActive ?? this.isActive,
      groupId: groupId ?? this.groupId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'code': code,
      'discountRate': discountRate,
      'planType': planType,
      'maxUses': maxUses,
      'currentUses': currentUses,
      'isActive': isActive,
      'groupId': groupId,
    };
  }

  factory PromotionModel.fromMap(Map<String, dynamic> map) {
    return PromotionModel(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      code: map['code'] as String,
      discountRate: map['discountRate'] as int,
      planType: map['planType'] as String,
      maxUses: map['maxUses'] as int,
      currentUses: map['currentUses'] as int,
      isActive: map['isActive'] as bool,
      groupId: map['groupId'] as String,
    );
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    code,
    discountRate,
    planType,
    maxUses,
    currentUses,
    isActive,
    groupId,
  ];

  @override
  bool get stringify => true;
}
