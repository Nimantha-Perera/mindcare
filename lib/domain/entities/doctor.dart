
class Doctor {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviews;
  final int experience;
  final bool isOnline;
  final int consultationFee;
  final String profileImage;
  final String about;
  final DateTime nextAvailable;
  final String? mobileNumber;


  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.experience,
    required this.isOnline,
    required this.consultationFee,
    required this.profileImage,
    required this.about,
    required this.nextAvailable,
    this.mobileNumber,
  });

  Doctor copyWith({
    String? id,
    String? name,
    String? specialty,
    double? rating,
    int? reviews,
    int? experience,
    bool? isOnline,
    int? consultationFee,
    String? profileImage,
    String? about,
    DateTime? nextAvailable,
    String? mobileNumber,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      experience: experience ?? this.experience,
      isOnline: isOnline ?? this.isOnline,
      consultationFee: consultationFee ?? this.consultationFee,
      profileImage: profileImage ?? this.profileImage,
      about: about ?? this.about,
      nextAvailable: nextAvailable ?? this.nextAvailable,
      mobileNumber: mobileNumber ?? this.mobileNumber,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Doctor && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
// DELETE ALL OF THIS ↑