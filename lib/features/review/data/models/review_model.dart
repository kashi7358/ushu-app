class ReviewModel {
  final String id;
  final int rating;
  final String title;
  final String body;
  final List<String> images;
  final String? userName;
  final String? createdAt;

  ReviewModel({
    required this.id,
    required this.rating,
    required this.title,
    required this.body,
    required this.images,
    this.userName,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'] ?? '',
      rating: json['rating'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      userName: json['user']?['fullName'] ?? json['userName'] ?? 'Anonymous',
      createdAt: json['createdAt'],
    );
  }
}
