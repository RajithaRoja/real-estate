import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realesate/models/property.dart';


class AgentUserPropertyController extends GetxController with GetTickerProviderStateMixin {
  var isLoading = false.obs;
  var properties = <Property>[].obs;
  var selectedTabIndex = 0.obs;
  var searchQuery = ''.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var createdAt = "";
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    fetchProperties();
  }

void fetchProperties() async {
    try {
    isLoading(true);
    
      QuerySnapshot querySnapshot = await _firestore
          .collection('properties')
          .orderBy('createdAt', descending: true)
          .get();

      List<Property> loadedProperties = querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        print(data);
        print("Extracted createdAt: ${data['createdAt']}");

        //   return Property(
        //     id: doc.id,
        //     title: data['title'] ?? '',
        //     type: data['type'] ?? '',
        //     price: (data['price'] as num?)?.toDouble() ?? 0.0,
        //     squareFt: (data['area'] as num?)?.toDouble() ?? 0.0,
        //     beds: (data['bedrooms'] as num?)?.toInt(),
        //     baths: (data['bathrooms'] as num?)?.toInt(),
        //     description: data['description'] ?? '',
        //     images: data['images'] != null
        //         ? List<String>.from(
        //             data['images']['values'].map((e) => e['stringValue']))
        //         : [],
        //     youtubeLink: data['youtubeLink'] ?? '',
        //     address: data['address'] ?? '',
        //     city: data['city'] ?? '',
        //     state: data['state'] ?? '',
        //     zipCode: data['zipCode'] ?? '',
        //     amenities: data['amenities'] != null
        //         ? List<String>.from(data['amenities'])
        //         : [],
        //     latitude: (data['location'] as GeoPoint?)?.latitude,
        //     longitude: (data['location'] as GeoPoint?)?.longitude,
        //     status: data['status'] ?? '',
        //   );
        // }).toList();
        return Property(
          id: doc.id,
          title: data['title'] ?? '',
          type: data['type'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          squareFt: (data['area'] as num?)?.toDouble() ?? 0.0,
          beds: (data['bedrooms'] as num?)?.toInt(),
          baths: (data['bathrooms'] as num?)?.toInt(),
          description: data['description'] ?? '',

          // ✅ FIX: Directly cast List<String>
          images:
              data['images'] != null ? List<String>.from(data['images']) : [],

          youtubeLink: data['youtubeLink'] ?? '',
          address: data['address'] ?? '',
          city: data['city'] ?? '',
          state: data['state'] ?? '',
          zipCode: data['zipCode'] ?? '',
          amenities: data['amenities'] != null
              ? List<String>.from(data['amenities'])
              : [],
          // ✅ FIX: Correct GeoPoint handling
          latitude: (data['location'] as GeoPoint?)?.latitude,
          longitude: (data['location'] as GeoPoint?)?.longitude,

          status: data['status'] ?? '',
          createdAt: data['createdAt'] != null && data['createdAt'] is Timestamp
              ? DateTime.fromMillisecondsSinceEpoch(
                  (data['createdAt'] as Timestamp).seconds * 1000,
                )
              : null, // Keep it nullable
          // Keep it as DateTime? instead of String
        );
      }).toList();
      properties.value = loadedProperties;
    } catch (e) {
      print("e$e");
    } finally {
      isLoading(false);
    }
  }


List<Property> get filteredProperties {
    List<Property> filteredList = properties;

    // Filter by selected tab
    switch (selectedTabIndex.value) {
      case 1:
        filteredList = filteredList.where((p) => p.status == "Under Review").toList();
        break;
      case 2:
        filteredList = filteredList.where((p) => p.status == "Active").toList();
        break;
      case 3:
        filteredList = filteredList.where((p) => p.status == "Inactive").toList();
        break;
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filteredList = filteredList.where((p) =>
              p.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
              p.city.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
              p.state.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
              p.zipCode
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ||
              p.address.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    return filteredList;
  }
}
