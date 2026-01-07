import 'package:equatable/equatable.dart';

class ResourceModel extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String resourceImg;
  final String resourceName;
  final String resourceLink;
  final String groupId;

  const ResourceModel({
    this.id,
    this.createdAt,
    required this.resourceImg,
    required this.resourceName,
    required this.resourceLink,
    required this.groupId,
  });

  ResourceModel copyWith({
    String? id,
    DateTime? createdAt,
    String? resourceImg,
    String? resourceName,
    String? resourceLink,
    String? groupId,
  }) {
    return ResourceModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      resourceImg: resourceImg ?? this.resourceImg,
      resourceName: resourceName ?? this.resourceName,
      resourceLink: resourceLink ?? this.resourceLink,
      groupId: groupId ?? this.groupId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'resourceImg': resourceImg,
      'resourceName': resourceName,
      'resourceLink': resourceLink,
      'groupId': groupId,
    }..removeWhere((key, value) => value == null);
  }

  factory ResourceModel.fromMap(Map<String, dynamic> map) {
    return ResourceModel(
      id: map['id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      resourceImg: map['resourceImg'] as String,
      resourceName: map['resourceName'] as String,
      resourceLink: map['resourceLink'] as String,
      groupId: map['groupId'] as String,
    );
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    resourceImg,
    resourceName,
    resourceLink,
    groupId,
  ];

  @override
  bool get stringify => true;
}
