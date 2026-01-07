import 'package:equatable/equatable.dart';

enum ProductType { product, service }

class ProductModel extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String name;
  final String description;
  final double price;
  final String whatsappNumber;
  final String imageUrl;
  final String groupId;
  final ProductType type;
  final double? discountPrice;
  final int? rating;

  const ProductModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    required this.name,
    required this.description,
    required this.price,
    required this.whatsappNumber,
    required this.imageUrl,
    required this.groupId,
    required this.type,
    this.discountPrice,
    this.rating,
  });

  ProductModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    String? description,
    double? price,
    String? whatsappNumber,
    String? imageUrl,
    String? groupId,
    ProductType? type,
    double? discountPrice,
    int? rating,
  }) {
    return ProductModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      groupId: groupId ?? this.groupId,
      type: type ?? this.type,
      discountPrice: discountPrice ?? this.discountPrice,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'price': price,
      'whatsappNumber': whatsappNumber,
      'imageUrl': imageUrl,
      'groupId': groupId,
      'type': type.name.toUpperCase(),
      'discountPrice': discountPrice,
      'rating': rating,
    }..removeWhere((key, value) => value == null);
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      name: map['name'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      whatsappNumber: map['whatsappNumber'] as String,
      imageUrl: map['imageUrl'] as String,
      groupId: map['groupId'] as String,
      type: ProductType.values.firstWhere(
        (e) => e.name.toUpperCase() == map['type'],
        orElse: () => ProductType.product,
      ),
      discountPrice: map['discountPrice'] != null
          ? (map['discountPrice'] as num).toDouble()
          : null,
      rating: map['rating'] as int?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    updatedAt,
    name,
    description,
    price,
    whatsappNumber,
    imageUrl,
    groupId,
    type,
    discountPrice,
    rating,
  ];

  @override
  bool get stringify => true;
}
