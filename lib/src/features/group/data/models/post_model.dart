import 'package:equatable/equatable.dart';

class PostModel extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String title;
  final String? htmlContent;
  final String? jsonContent;
  final String? content;
  final String authorId;
  final String channelId;

  const PostModel({
    this.id,
    this.createdAt,
    required this.title,
    this.htmlContent,
    this.jsonContent,
    this.content,
    required this.authorId,
    required this.channelId,
  });

  PostModel copyWith({
    String? id,
    DateTime? createdAt,
    String? title,
    String? htmlContent,
    String? jsonContent,
    String? content,
    String? authorId,
    String? channelId,
  }) {
    return PostModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      htmlContent: htmlContent ?? this.htmlContent,
      jsonContent: jsonContent ?? this.jsonContent,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      channelId: channelId ?? this.channelId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'htmlContent': htmlContent,
      'jsonContent': jsonContent,
      'content': content,
      'authorId': authorId,
      'channelId': channelId,
    }..removeWhere((key, value) => value == null);
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      title: map['title'] as String,
      htmlContent: map['htmlContent'] as String?,
      jsonContent: map['jsonContent'] as String?,
      content: map['content'] as String?,
      authorId: map['authorId'] as String,
      channelId: map['channelId'] as String,
    );
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    title,
    htmlContent,
    jsonContent,
    content,
    authorId,
    channelId,
  ];

  @override
  bool get stringify => true;
}
