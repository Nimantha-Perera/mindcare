class StressTip {
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final String? duration;
  final List<String> steps;

  const StressTip({
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    this.duration,
    this.steps = const [],
  });

  factory StressTip.fromJson(Map<String, dynamic> json) {
    return StressTip(
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      duration: json['duration'] as String?,
      steps: (json['steps'] as List<dynamic>?)
          ?.map((step) => step.toString())
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'duration': duration,
      'steps': steps,
    };
  }

  StressTip copyWith({
    String? title,
    String? description,
    String? category,
    String? difficulty,
    String? duration,
    List<String>? steps,
  }) {
    return StressTip(
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      steps: steps ?? this.steps,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is StressTip &&
        other.title == title &&
        other.description == description &&
        other.category == category &&
        other.difficulty == difficulty &&
        other.duration == duration &&
        _listEquals(other.steps, steps);
  }

  @override
  int get hashCode {
    return title.hashCode ^
        description.hashCode ^
        category.hashCode ^
        difficulty.hashCode ^
        duration.hashCode ^
        steps.hashCode;
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'StressTip(title: $title, category: $category, difficulty: $difficulty, duration: $duration)';
  }
}