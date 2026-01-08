import 'package:equatable/equatable.dart';

class JobModel extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String title;
  final String description;
  final String image;
  final DateTime postingEndDate;
  final String googleSheetId;
  final String groupId;

  const JobModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    required this.title,
    required this.description,
    required this.image,
    required this.postingEndDate,
    required this.googleSheetId,
    required this.groupId,
  });

  JobModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    String? description,
    String? image,
    DateTime? postingEndDate,
    String? googleSheetId,
    String? groupId,
  }) {
    return JobModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      postingEndDate: postingEndDate ?? this.postingEndDate,
      googleSheetId: googleSheetId ?? this.googleSheetId,
      groupId: groupId ?? this.groupId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'image': image,
      'postingEndDate': postingEndDate.toIso8601String(),
      'googleSheetId': googleSheetId,
      'groupId': groupId,
    }..removeWhere((key, value) => value == null);
  }

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      title: map['title'] as String,
      description: map['description'] as String,
      image: map['image'] as String,
      postingEndDate: DateTime.parse(map['postingEndDate'] as String),
      googleSheetId: map['googleSheetId'] as String,
      groupId: map['groupId'] as String,
    );
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    updatedAt,
    title,
    description,
    image,
    postingEndDate,
    googleSheetId,
    groupId,
  ];

  @override
  bool get stringify => true;
}
