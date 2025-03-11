import 'dart:ui';

class Property {
  final String title;
  final String location;
  final double latitude;  // Added latitude
  final double longitude; // Added longitude
  final int price;
  final String dateListed;
  final String status;
  final Color statusTagColor;
  final List<String> images;
  final bool videoTourAvailable;
  final String? adminReviewStatus;

  Property({
    required this.title,
    required this.location,
    required this.latitude,   // Required field
    required this.longitude,  // Required field
    required this.price,
    required this.dateListed,
    required this.status,
    required this.statusTagColor,
    required this.images,
    required this.videoTourAvailable,
    this.adminReviewStatus,
  });
}
