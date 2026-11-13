import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final int? age;
  final String? country;
  final String? medicalConditions;
  final bool profileCompleted;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    required this.createdAt,
    this.age,
    this.country,
    this.medicalConditions,
    this.profileCompleted = false,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final age = (data['age'] as num?)?.toInt();
    final country = data['country'] as String?;

    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      age: age,
      country: country,
      medicalConditions: data['medicalConditions'],
      profileCompleted: data['profileCompleted'] as bool? ??
          (age != null && country != null && country.isNotEmpty),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': Timestamp.fromDate(createdAt),
      'age': age,
      'country': country,
      'medicalConditions': medicalConditions,
      'profileCompleted': profileCompleted,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    DateTime? createdAt,
    int? age,
    String? country,
    String? medicalConditions,
    bool? profileCompleted,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      age: age ?? this.age,
      country: country ?? this.country,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      profileCompleted: profileCompleted ?? this.profileCompleted,
    );
  }
}
