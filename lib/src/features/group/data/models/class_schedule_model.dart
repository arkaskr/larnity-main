import 'package:equatable/equatable.dart';

class ClassScheduleModel extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String title;
  final String? description;
  final DateTime eventDate;
  final String eventTime;
  final String locationType;
  final String? eventLink;
  final String? coverImageUrl;
  final String groupId;

  const ClassScheduleModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    required this.title,
    this.description,
    required this.eventDate,
    required this.eventTime,
    required this.locationType,
    this.eventLink,
    this.coverImageUrl,
    required this.groupId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'eventDate': eventDate.toIso8601String().split('T')[0],
      'eventTime': eventTime,
      'locationType': locationType,
      'eventLink': eventLink,
      'coverImageUrl': coverImageUrl,
      'groupId': groupId,
    }..removeWhere((key, value) => value == null);
  }

  factory ClassScheduleModel.fromMap(Map<String, dynamic> map) {
    return ClassScheduleModel(
      id: map['id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      title: map['title'] as String,
      description: map['description'] as String?,
      eventDate: DateTime.parse(map['eventDate'] as String),
      eventTime: map['eventTime'] as String,
      locationType: map['locationType'] as String,
      eventLink: map['eventLink'] as String?,
      coverImageUrl: map['coverImageUrl'] as String?,
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
    eventDate,
    eventTime,
    locationType,
    eventLink,
    coverImageUrl,
    groupId,
  ];
}
