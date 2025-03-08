class Property {
  final String id;
  final String title;
  final String type;
  final double price;
  final double squareFt;
  final int ? beds;
  final int? baths;
  final String description;
  final List<String> images;
  final String youtubeLink;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final List<String> amenities;
  final double? latitude;
  final double? longitude;

  Property({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
    required this.squareFt,
    this.beds,
    this.baths,
    required this.description,
    required this.images,
    this.youtubeLink = '',
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.amenities,
    this.latitude,
    this.longitude,
  });

  Property copyWith({
    String? title,
    String? type,
    double? price,
    double? squareFt,
    int? beds,
    int? baths,
    String? description,
    List<String>? images,
    String? youtubeLink,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    List<String>? amenities,
    double? latitude,
    double? longitude,
  }) {
    return Property(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      price: price ?? this.price,
      squareFt: squareFt ?? this.squareFt,
      beds: beds ?? this.beds,
      baths: baths ?? this.baths,
      description: description ?? this.description,
      images: images ?? this.images,
      youtubeLink: youtubeLink ?? this.youtubeLink,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      amenities: amenities ?? this.amenities,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
} 