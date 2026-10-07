class ReviewModel {
  final String id;
  final int rating;
  final String title;
  final String body;
  final List<String> images;
  final String userName;
  final String? createdAt;
  final int upvotes;
  final int downvotes;

  ReviewModel({
    required this.id,
    required this.rating,
    required this.title,
    required this.body,
    required this.images,
    required this.userName,
    this.createdAt,
    this.upvotes = 0,
    this.downvotes = 0,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // 1. Resolve User Name
    String resolvedName = '';
    if (json['fullName'] != null && json['fullName'].toString().trim().isNotEmpty) {
      resolvedName = json['fullName'].toString().trim();
    } else if (json['userName'] != null && json['userName'].toString().trim().isNotEmpty) {
      resolvedName = json['userName'].toString().trim();
    } else if (json['user_name'] != null && json['user_name'].toString().trim().isNotEmpty) {
      resolvedName = json['user_name'].toString().trim();
    } else if (json['username'] != null && json['username'].toString().trim().isNotEmpty) {
      resolvedName = json['username'].toString().trim();
    } else if (json['buyerName'] != null && json['buyerName'].toString().trim().isNotEmpty) {
      resolvedName = json['buyerName'].toString().trim();
    } else if (json['customerName'] != null && json['customerName'].toString().trim().isNotEmpty) {
      resolvedName = json['customerName'].toString().trim();
    } else if (json['name'] != null && json['name'].toString().trim().isNotEmpty) {
      resolvedName = json['name'].toString().trim();
    }

    if (resolvedName.isEmpty && json['user'] is Map) {
      final u = json['user'] as Map;
      resolvedName = (u['fullName'] ?? u['name'] ?? u['username'] ?? u['user_name'] ?? u['firstName'] ?? '').toString().trim();
    }

    if (resolvedName.isEmpty && json['buyer'] is Map) {
      final b = json['buyer'] as Map;
      resolvedName = (b['fullName'] ?? b['name'] ?? '').toString().trim();
    }

    if (resolvedName.isEmpty && json['customer'] is Map) {
      final c = json['customer'] as Map;
      resolvedName = (c['fullName'] ?? c['name'] ?? '').toString().trim();
    }

    if (resolvedName.isEmpty || RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(resolvedName)) {
      resolvedName = 'Verified Buyer';
    }

    // 2. Resolve Images
    final List<String> extractedImages = [];
    final rawImages = json['images'];
    if (rawImages is List) {
      for (var img in rawImages) {
        if (img is String && img.trim().isNotEmpty) {
          extractedImages.add(img.trim());
        } else if (img is Map) {
          final url = (img['url'] ?? img['src'] ?? img['path'] ?? '').toString().trim();
          if (url.isNotEmpty) extractedImages.add(url);
        }
      }
    }

    // 3. Resolve Rating
    final rawRating = json['rating'];
    final int parsedRating = (rawRating is num)
        ? rawRating.toInt()
        : int.tryParse(rawRating?.toString() ?? '') ?? 5;

    // 4. Resolve Upvotes
    int parsedUpvotes = 0;
    if (json['helpfulVotes'] is num) {
      parsedUpvotes = (json['helpfulVotes'] as num).toInt();
    } else if (json['helpfull votes'] is num) {
      parsedUpvotes = (json['helpfull votes'] as num).toInt();
    } else if (json['upvotes'] is num) {
      parsedUpvotes = (json['upvotes'] as num).toInt();
    } else if (json['helpful'] is num) {
      parsedUpvotes = (json['helpful'] as num).toInt();
    } else if (json['likes'] is num) {
      parsedUpvotes = (json['likes'] as num).toInt();
    } else if (json['votes'] is Map && (json['votes']['up'] is num || json['votes']['helpful'] is num)) {
      parsedUpvotes = ((json['votes']['up'] ?? json['votes']['helpful']) as num).toInt();
    }

    // 5. Resolve Downvotes
    int parsedDownvotes = 0;
    if (json['unhelpfulVotes'] is num) {
      parsedDownvotes = (json['unhelpfulVotes'] as num).toInt();
    } else if (json['unhelpfullVote'] is num) {
      parsedDownvotes = (json['unhelpfullVote'] as num).toInt();
    } else if (json['downvotes'] is num) {
      parsedDownvotes = (json['downvotes'] as num).toInt();
    } else if (json['unhelpful'] is num) {
      parsedDownvotes = (json['unhelpful'] as num).toInt();
    } else if (json['dislikes'] is num) {
      parsedDownvotes = (json['dislikes'] as num).toInt();
    } else if (json['votes'] is Map && (json['votes']['down'] is num || json['votes']['unhelpful'] is num)) {
      parsedDownvotes = ((json['votes']['down'] ?? json['votes']['unhelpful']) as num).toInt();
    }

    return ReviewModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      rating: parsedRating,
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? json['comment'] ?? json['review'] ?? '').toString(),
      images: extractedImages,
      userName: resolvedName,
      createdAt: json['createdAt']?.toString() ?? json['date']?.toString(),
      upvotes: parsedUpvotes,
      downvotes: parsedDownvotes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'rating': rating,
      'title': title,
      'body': body,
      'images': images,
      'userName': userName,
      'createdAt': createdAt,
      'helpfulVotes': upvotes,
      'unhelpfulVotes': downvotes,
    };
  }

  /// Safe map-like indexing for compatibility with legacy widgets
  dynamic operator [](String key) {
    switch (key) {
      case '_id':
      case 'id':
        return id;
      case 'rating':
        return rating;
      case 'title':
        return title;
      case 'body':
        return body;
      case 'images':
        return images;
      case 'userName':
      case 'fullName':
      case 'name':
        return userName;
      case 'createdAt':
      case 'date':
        return createdAt;
      case 'helpfulVotes':
      case 'upvotes':
        return upvotes;
      case 'unhelpfulVotes':
      case 'downvotes':
        return downvotes;
      default:
        return null;
    }
  }
}
