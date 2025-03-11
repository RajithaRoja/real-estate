import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realesate/agent_user_list/agent_user_model.dart';

class AgentUserPropertyController extends GetxController with GetTickerProviderStateMixin {
  var isLoading = false.obs;
  var properties = <Property>[].obs;
  var selectedTabIndex = 0.obs;
  var searchQuery = ''.obs;

  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    fetchProperties();
  }

  void fetchProperties() {
    isLoading(true);
    Future.delayed(const Duration(seconds: 1), () {
      properties.value = [
        Property(
          title: "Modern Waterfront Villa",
          location: "123 Ocean Drive, Miami Beach",
            latitude: 34.0522,
          longitude: -118.2437,
          price: 2500000,
          dateListed: "2024-02-15",
          status: "Under Review",
          statusTagColor: Colors.orange,
          images: ["https://images.unsplash.com/photo-1416339306562-f3d12fefd36f", "https://images.unsplash.com/5/unsplash-kitsune-4.jpg?ixlib=rb-0.3.5&q=85&fm=jpg&crop=entropy&cs=srgb&ixid=eyJhcHBfaWQiOjEyMDd9&s=ce40ce8b8ba365e5e6d06401e5485390"],
          videoTourAvailable: true,
          adminReviewStatus: "Waiting for admin review",
        ),
        Property(
          title: "Luxury Downtown Penthouse",
          location: "Downtown, New York City",
            latitude: 34.0522,
          longitude: -118.2437,
          price: 3500000,
          dateListed: "2024-01-20",
          status: "Active",
          statusTagColor: Colors.green,
          images: ["data:image/jpeg;base64,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"],
          videoTourAvailable: false,
          adminReviewStatus: null,
        ),
        Property(
          title: "Cozy Suburban Home",
          location: "Los Angeles, CA",
            latitude: 34.0522,
          longitude: -118.2437,
          price: 800000,
          dateListed: "2023-12-10",
          status: "Inactive",
          statusTagColor: Colors.grey,
          images: ["https://media.istockphoto.com/id/2155965052/photo/new-condo-houston-texas-usa.webp?a=1&b=1&s=612x612&w=0&k=20&c=dPPtZAII1Emj7o_VB_9r-W1wAG_snOXlGnARbog4JVY=", "https://media.istockphoto.com/id/2076934092/photo/apartment-building-with-autumn-trees-landscape.webp?a=1&b=1&s=612x612&w=0&k=20&c=X8qclT0IkDiCHyiVBRF0blEKheddt2K_Fdc08_HnTrE=", "https://media.istockphoto.com/id/1357529933/photo/digitally-generated-image-of-a-fully-furnished-living-room.jpg?s=612x612&w=0&k=20&c=wv2lkL2oV9HcZKzXtvxDvRO2FKU9o209ULVWxI3RaOY=", "https://media.istockphoto.com/id/2159502135/photo/creating-a-focal-point-statement-wall-ideas-for-your-living-room.jpg?s=612x612&w=0&k=20&c=d7Gq6hi_Cs4cU53XuHKfMrOQm2hw2kJPB0q_PF_Mc6U="],
          videoTourAvailable: false,
          adminReviewStatus: null,
        ),
         Property(
          title: "Modern Waterfront Villa",
          location: "123 Ocean Drive, Miami Beach",
            latitude: 34.0522,
          longitude: -118.2437,
          price: 2500000,
          dateListed: "2024-02-15",
          status: "Under Review",
          statusTagColor: Colors.orange,
          images: ["https://media.istockphoto.com/id/2159502135/photo/creating-a-focal-point-statement-wall-ideas-for-your-living-room.jpg?s=612x612&w=0&k=20&c=d7Gq6hi_Cs4cU53XuHKfMrOQm2hw2kJPB0q_PF_Mc6U=","https://media.istockphoto.com/id/2161329159/photo/billiard-table-with-armchairs-in-the-modern-reception.jpg?s=612x612&w=0&k=20&c=wyhMzh7k7ESFKw1iuvkapNJYJnFuIyMh9syfNjTvC1E="],
          videoTourAvailable: true,
          adminReviewStatus: "Waiting for admin review",
        ), Property(
          title: "Modern Waterfront Villa",
          location: "123 Ocean Drive, Miami Beach",
            latitude: 34.0522,
          longitude: -118.2437,
          price: 2500000,
          dateListed: "2024-02-15",
          status: "Under Review",
          statusTagColor: Colors.orange,
          images: ["https://media.istockphoto.com/id/2190483000/photo/luxury-open-concept-living-room-and-kitchen-with-modern-furniture-and-bold-accents.jpg?s=612x612&w=0&k=20&c=yG3_P5E5EJkb3PyRCVdTxVchI1CFUgEYZ9Yzaatl8S8="],
          videoTourAvailable: true,
          adminReviewStatus: "Waiting for admin review",
        ), Property(
          title: "Modern Waterfront Villa",
          location: "123 Ocean Drive, Miami Beach",
            latitude: 34.0522,
          longitude: -118.2437,
          price: 2500000,
          dateListed: "2024-02-15",
          status: "Under Review",
          statusTagColor: Colors.orange,
          images: ["https://media.istockphoto.com/id/1344082102/photo/large-glass-enclosed-balcony.jpg?s=612x612&w=0&k=20&c=gBTXgxCX8xue75LN1B6z21U_0htla88yyRpxs2to-hA="],
          videoTourAvailable: true,
          adminReviewStatus: "Waiting for admin review",
        ),
      ];
      isLoading(false);
    });
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
          p.location.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
    }

    return filteredList;
  }
}
