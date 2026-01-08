import 'package:equatable/equatable.dart';

enum CalendarEventType { liveclass, groupevent }

class EventModel extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String title;
  final DateTime date;
  final String time;
  final String location;
  final String link;
  final String description;
  final CalendarEventType type;
  final String? covering;
  final String groupId;

  const EventModel({
    this.id,
    this.createdAt,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.link,
    required this.description,
    required this.type,
    this.covering,
    required this.groupId,
  });

  EventModel copyWith({
    String? id,
    DateTime? createdAt,
    String? title,
    DateTime? date,
    String? time,
    String? location,
    String? link,
    String? description,
    CalendarEventType? type,
    String? covering,
    String? groupId,
  }) {
    return EventModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      link: link ?? this.link,
      description: description ?? this.description,
      type: type ?? this.type,
      covering: covering ?? this.covering,
      groupId: groupId ?? this.groupId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'date': date.toIso8601String().split('T')[0],
      'time': time,
      'location': location,
      'link': link,
      'description': description,
      'type': type.name.toUpperCase(),
      'covering': covering,
      'groupId': groupId,
    }..removeWhere((key, value) => value == null);
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      time: map['time'] as String,
      location: map['location'] as String,
      link: map['link'] as String,
      description: map['description'] as String,
      type: CalendarEventType.values.firstWhere(
        (e) => e.name.toUpperCase() == map['type'],
        orElse: () => CalendarEventType.groupevent,
      ),
      covering: map['covering'] as String?,
      groupId: map['groupId'] as String,
    );
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    title,
    date,
    time,
    location,
    link,
    description,
    type,
    covering,
    groupId,
  ];

  @override
  bool get stringify => true;
}
