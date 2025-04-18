class TipModel {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final String category;
  final bool isFavorite;

  const TipModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.category,
    this.isFavorite = false,
  });

  factory TipModel.fromJson(Map<String, dynamic> json) {
    return TipModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      iconName: json['iconName'] ?? '',
      category: json['category'] ?? 'general',
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'category': category,
      'isFavorite': isFavorite,
    };
  }

  TipModel copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    String? category,
    bool? isFavorite,
  }) {
    return TipModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Sample tips for the app
  static List<TipModel> getSampleTips() {
    return [
      const TipModel(
        id: '1',
        title: 'Deep Breathing',
        description: 'Take slow, deep breaths. Try inhaling for 4 seconds, holding for 4 seconds, and exhaling for 4 seconds. This helps activate your parasympathetic nervous system (relax mode).',
        iconName: 'meditation',
        category: 'breathing',
      ),
      const TipModel(
        id: '2',
        title: 'Go Outside',
        description: 'Spend time in nature — even a few minutes under a tree or a short walk can help clear your mind.',
        iconName: 'nature',
        category: 'activity',
      ),
      const TipModel(
        id: '3',
        title: '4-7-8 Breathing',
        description: 'Inhale through your nose for 4 seconds, hold your breath for 7 seconds, and exhale slowly through your mouth for 8 seconds.',
        iconName: 'breathing',
        category: 'breathing',
      ),
      const TipModel(
        id: '4',
        title: 'Mindful Journaling',
        description: 'Write down your thoughts and feelings without judgment. This can help you process emotions and gain perspective.',
        iconName: 'journal',
        category: 'mindfulness',
      ),
      const TipModel(
        id: '5',
        title: 'Progressive Relaxation',
        description: 'Tense and then relax each muscle group in your body, starting from your toes and working up to your head.',
        iconName: 'relax',
        category: 'relaxation',
      ),
      const TipModel(
        id: '6',
        title: 'Limit Screen Time',
        description: 'Take breaks from phones, computers, and TVs. The constant stimulation can increase stress and anxiety.',
        iconName: 'phone',
        category: 'lifestyle',
      ),
      const TipModel(
        id: '7',
        title: 'Stay Hydrated',
        description: 'Dehydration can worsen anxiety and mood. Drink water regularly throughout the day.',
        iconName: 'water',
        category: 'health',
      ),
      const TipModel(
        id: '8',
        title: 'Guided Imagery',
        description: 'Close your eyes and imagine a peaceful place. Engage all your senses in the visualization.',
        iconName: 'imagination',
        category: 'mindfulness',
      ),
    ];
  }
}