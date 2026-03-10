import 'dart:convert';

class ChallengeModel {
  final String? id;
  final DateTime? createdAt;
  final String title;
  final String? thumbnail;
  final DateTime startDate;
  final DateTime endDate;
  final double maxParticipants;
  final int firstPlacePrize;
  final int secondPlacePrize;
  final int thirdPlacePrize;
  final int registrationFee;
  final bool isPaid;
  final String groupId;
  final String status;
  final String description;

  ChallengeModel({
    this.id,
    this.createdAt,
    required this.title,
    this.thumbnail,
    required this.startDate,
    required this.endDate,
    required this.maxParticipants,
    required this.firstPlacePrize,
    required this.secondPlacePrize,
    required this.thirdPlacePrize,
    required this.registrationFee,
    required this.isPaid,
    required this.groupId,
    this.status = 'PUBLISHED',
    required this.description,
  });

  ChallengeModel copyWith({
    String? id,
    DateTime? createdAt,
    String? title,
    String? thumbnail,
    DateTime? startDate,
    DateTime? endDate,
    double? maxParticipants,
    int? firstPlacePrize,
    int? secondPlacePrize,
    int? thirdPlacePrize,
    int? registrationFee,
    bool? isPaid,
    String? groupId,
    String? status,
    String? description,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      thumbnail: thumbnail ?? this.thumbnail,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      firstPlacePrize: firstPlacePrize ?? this.firstPlacePrize,
      secondPlacePrize: secondPlacePrize ?? this.secondPlacePrize,
      thirdPlacePrize: thirdPlacePrize ?? this.thirdPlacePrize,
      registrationFee: registrationFee ?? this.registrationFee,
      isPaid: isPaid ?? this.isPaid,
      groupId: groupId ?? this.groupId,
      status: status ?? this.status,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      'title': title,
      'thumbnail': thumbnail,
      'startDate': startDate.toIso8601String().split('T').first, // Date only
      'endDate': endDate.toIso8601String().split('T').first, // Date only
      'maxParticipants': maxParticipants,
      'firstPlacePrize': firstPlacePrize,
      'secondPlacePrize': secondPlacePrize,
      'thirdPlacePrize': thirdPlacePrize,
      'registrationFee': registrationFee,
      'isPaid': isPaid,
      'groupId': groupId,
      'status': status,
      'description': description,
    };
  }

  factory ChallengeModel.fromMap(Map<String, dynamic> map) {
    return ChallengeModel(
      id: map['id'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      title: map['title'] ?? '',
      thumbnail: map['thumbnail'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      maxParticipants:
          (map['maxParticipants'] as num?)?.toDouble() ?? 0.0,
      firstPlacePrize: (map['firstPlacePrize'] as num?)?.toInt() ?? 0,
      secondPlacePrize: (map['secondPlacePrize'] as num?)?.toInt() ?? 0,
      thirdPlacePrize: (map['thirdPlacePrize'] as num?)?.toInt() ?? 0,
      registrationFee: (map['registrationFee'] as num?)?.toInt() ?? 0,
      isPaid: map['isPaid'] ?? false,
      groupId: map['groupId'] ?? '',
      status: map['status'] ?? 'PUBLISHED',
      description: map['description'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ChallengeModel.fromJson(String source) =>
      ChallengeModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ChallengeModel(id: $id, title: $title, startDate: $startDate, endDate: $endDate, groupId: $groupId)';
  }
}
