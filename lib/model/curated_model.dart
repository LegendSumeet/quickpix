import 'package:picpixels/model/image_src.dart';

class PexelsResponse {
  final int page;
  final int perPage;
  final List<ImageSrc> photos;
  final int totalResults;
  final String? nextPage;

  PexelsResponse({
    required this.page,
    required this.perPage,
    required this.photos,
    required this.totalResults,
    this.nextPage,
  });

  factory PexelsResponse.fromJson(Map<String, dynamic> json) {
    return PexelsResponse(
      page: json['page'] as int,
      perPage: json['per_page'] as int,
      photos: (json['photos'] as List<dynamic>)
          .map((photo) => ImageSrc.fromJson(photo as Map<String, dynamic>))
          .toList(),
      totalResults: json['total_results'] as int,
      nextPage: json['next_page'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'per_page': perPage,
      'photos': photos.map((photo) => photo.toJson()).toList(),
      'total_results': totalResults,
      'next_page': nextPage,
    };
  }
}