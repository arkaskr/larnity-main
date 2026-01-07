import 'package:equatable/equatable.dart';

enum CoursePrivacy { public, paid }

class CourseModel extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String name;
  final String? thumbnail;
  final CoursePrivacy privacy;
  final String? description;
  final String groupId;
  final int? price;

  const CourseModel({
    this.id,
    this.createdAt,
    required this.name,
    this.thumbnail,
    required this.privacy,
    this.description,
    required this.groupId,
    this.price,
  });

  CourseModel copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    String? thumbnail,
    CoursePrivacy? privacy,
    String? description,
    String? groupId,
    int? price,
  }) {
    return CourseModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      thumbnail: thumbnail ?? this.thumbnail,
      privacy: privacy ?? this.privacy,
      description: description ?? this.description,
      groupId: groupId ?? this.groupId,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'thumbnail': thumbnail,
      'privacy': privacy.name,
      'description': description,
      'groupId': groupId,
      'price': price,
    }..removeWhere((key, value) => value == null);
  }

  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      id: map['id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      name: map['name'] as String,
      thumbnail: map['thumbnail'] as String?,
      privacy: CoursePrivacy.values.firstWhere(
        (e) => e.name == map['privacy'],
        orElse: () => CoursePrivacy.public,
      ),
      description: map['description'] as String?,
      groupId: map['groupId'] as String,
      price: map['price'] as int?,
    );
  }

  bool get isPublic => privacy == CoursePrivacy.public;
  bool get isPaid => privacy == CoursePrivacy.paid;

  @override
  List<Object?> get props => [
    id,
    createdAt,
    name,
    thumbnail,
    privacy,
    description,
    groupId,
    price,
  ];

  @override
  bool get stringify => true;
}
