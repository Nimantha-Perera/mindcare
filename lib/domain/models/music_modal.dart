class Music {
  final String name;
  final String url;
  final String downloadUrl;
  final DateTime? createdAt;
  final int? size;
  final String? contentType;

  Music({
    required this.name,
    required this.url,
    required this.downloadUrl,
    this.createdAt,
    this.size,
    this.contentType,
  });

  factory Music.fromFirebaseMetadata(
    String name,
    String downloadUrl,
    Map<String, dynamic>? metadata,
  ) {
    return Music(
      name: name,
      url: downloadUrl,
      downloadUrl: downloadUrl,
      createdAt: metadata?['timeCreated'] != null
          ? DateTime.parse(metadata!['timeCreated'])
          : null,
      size: metadata?['size'] != null
          ? int.tryParse(metadata!['size'].toString())
          : null,
      contentType: metadata?['contentType'],
    );
  }

  // Convert to JSON for local storage if needed
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'downloadUrl': downloadUrl,
      'createdAt': createdAt?.toIso8601String(),
      'size': size,
      'contentType': contentType,
    };
  }

  // Create from JSON
  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      downloadUrl: json['downloadUrl'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      size: json['size'],
      contentType: json['contentType'],
    );
  }

  @override
  String toString() {
    return 'Music{name: $name, size: $size, contentType: $contentType}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Music && other.name == name && other.downloadUrl == downloadUrl;
  }

  @override
  int get hashCode => name.hashCode ^ downloadUrl.hashCode;
}