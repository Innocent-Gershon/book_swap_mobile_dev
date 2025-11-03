import 'package:cloud_firestore/cloud_firestore.dart';

enum BookCondition { newBook, likeNew, good, used }

enum SwapStatus { available, pending, swapped }

class BookModel {
  final String id;
  final String title;
  final String author;
  final BookCondition condition;
  final String? imageUrl;
  final String ownerId;
  final String ownerEmail;
  final SwapStatus status;
  final DateTime createdAt;
  final String? swapRequesterId;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    this.imageUrl,
    required this.ownerId,
    required this.ownerEmail,
    this.status = SwapStatus.available,
    required this.createdAt,
    this.swapRequesterId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'condition': condition.name,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'swapRequesterId': swapRequesterId,
    };
  }

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      condition: BookCondition.values.firstWhere(
        (e) => e.name == map['condition'],
        orElse: () => BookCondition.used,
      ),
      imageUrl: map['imageUrl'],
      ownerId: map['ownerId'] ?? '',
      ownerEmail: map['ownerEmail'] ?? '',
      status: SwapStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SwapStatus.available,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      swapRequesterId: map['swapRequesterId'],
    );
  }

  factory BookModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookModel.fromMap({...data, 'id': doc.id});
  }

  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    BookCondition? condition,
    String? imageUrl,
    String? ownerId,
    String? ownerEmail,
    SwapStatus? status,
    DateTime? createdAt,
    String? swapRequesterId,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      condition: condition ?? this.condition,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      swapRequesterId: swapRequesterId ?? this.swapRequesterId,
    );
  }

  // Entity conversion methods
  factory BookModel.fromEntity(dynamic entity) {
    return BookModel(
      id: entity.id ?? '',
      title: entity.title ?? '',
      author: entity.author ?? '',
      condition: entity.condition ?? BookCondition.used,
      imageUrl: entity.imageUrl,
      ownerId: entity.ownerId ?? '',
      ownerEmail: entity.ownerEmail ?? '',
      status: entity.status ?? SwapStatus.available,
      createdAt: entity.createdAt ?? DateTime.now(),
      swapRequesterId: entity.swapRequesterId,
    );
  }

  dynamic toEntity() => this;
}
