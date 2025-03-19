import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:realesate/admin_property_approve/admin_property_list_controller.dart';
import 'package:realesate/constant/app.colors.dart';
import 'package:realesate/constant/app.strings.dart';
import 'package:realesate/models/property.dart';
import 'package:realesate/screens/add_property_screen.dart';

class AdminPropertyListPage extends StatelessWidget {
  final AdminPropertyController controller = Get.put(AdminPropertyController());

  AdminPropertyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: false,
        appBar: _buildAppBar(context),
        body: Column(
          children: [
             Divider(
            // ✅ Divider added below AppBar
            color: AppColors.appshade200Grey,
            thickness: 1,
            height: 1, // Ensures it stays right below the AppBar
          ),
          const SizedBox(height: 10,),
            _buildSearchBar(context),
            Divider(
              color: AppColors.appshade200Grey,
              thickness: 1,
            ),
            _buildTabBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: controller.filteredProperties.length,
                  itemBuilder: (context, index) {
                    return PropertyCard(
                        property: controller.filteredProperties[index]);
                  },
                );
              }),
            ),
          ],
        ));
  }

  /// The _buildAppBar function creates an AppBar with a title and an IconButton for adding properties.
  ///
  /// Returns:
  ///   An AppBar widget is being returned. The AppBar has a title with the text 'My Properties' styled
  /// with a bold font weight and a font size of 20. It also contains an actions list with one IconButton
  /// that displays an SVG icon and has an empty onPressed function.
  PreferredSize _buildAppBar(context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(66),
      child: AppBar(
        backgroundColor: Colors.transparent, // Fixed background color
        surfaceTintColor: Colors.transparent, // Prevents auto tinting
        elevation: 0,   
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Ensures proper spacing
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20), // Moves the title down
              child: Text(
                AppStrings.propertyApproval,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(top: 20), // Aligns icon with the title
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/images/addplus.svg', // ✅ Correct path
                  width: 32,
                  height: 32,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPropertyScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The _buildSearchBar function returns a TextField widget with search functionality and styling.
  ///
  /// Returns:
  ///   A `Widget` is being returned, specifically a `SizedBox` containing a `TextField` widget with
  /// specific styling and functionality for a search bar.
  Widget _buildSearchBar(context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.height * 0.08,
      child: TextField(
        decoration: InputDecoration(
          hintText: AppStrings.search,
          hintStyle: TextStyle(
              color: AppColors.labelColor), // Set hint text color to red
          prefixIcon: Icon(Icons.search, color: AppColors.labelColor),
          filled: true,
          fillColor: AppColors.searchColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          controller.searchQuery.value = value;
        },
      ),
    );
  }

  /// The above Dart code is defining a method `_buildTabBar()` that returns a TabBar widget. The TabBar
  /// widget is used to display a set of tabs with different labels.
  Widget _buildTabBar() {
    return TabBar(
      tabAlignment:
          TabAlignment.start, // Ensures first tab starts from the left
      controller: controller.tabController,
      onTap: (index) => controller.selectedTabIndex.value = index,
      isScrollable: true,
      labelPadding: const EdgeInsets.symmetric(horizontal: 20),
      labelColor: AppColors.darkblue,
      unselectedLabelColor: AppColors.grey,
      indicatorColor: AppColors.darkblue,
      dividerColor: AppColors.appshade200Grey,
      tabs: [
        Tab(
            child: Text(AppStrings.all,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500))),
        Tab(
            child: Text(AppStrings.pending,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500))),
        Tab(
            child: Text(AppStrings.approved,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500))),
        Tab(
            child: Text(AppStrings.rejected,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500))),
      ],
    );
  }
}

/// The `PropertyCard` class is a StatelessWidget in Dart that displays various sections of information
/// about a property, including images, details, gallery, video tour, and status.
class PropertyCard extends StatelessWidget {
  final Property property;

  const PropertyCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.appshade300Grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PropertyImageSection(property: property),
          PropertyDetailsSection(property: property),
          PropertySection(property: property),
          const SizedBox(height: 10), // Space before buttons
          buildPropertyCard(context, property),
          const SizedBox(height: 10), // Space after buttons
        ],
      ),
    );
  }
}

Widget buildPropertyCard(BuildContext context, Property property) {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdminPropertyController controller =
      Get.find<AdminPropertyController>();

  void updateStatus(String status, Color color) {
    _firestore.collection('properties').doc(property.id).update({
      'status': status,
    }).then((_) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Property marked as $status",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );

      // Reload the property list after approval/rejection
      controller.fetchProperties();
    }).catchError((error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update status"),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Show buttons only if the status is "Under Review"
      if (property.status == "Under Review") ...[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ElevatedButton.icon(
              onPressed: () =>
                  updateStatus(AppStrings.active, const Color(0xFF10B981)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon:                 SvgPicture.asset('assets/images/approve.svg'),
              label:
                  const Text("Approve", style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () =>
                updateStatus(AppStrings.inActive, const Color(0xFFEF4444)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: SvgPicture.asset('assets/images/reject.svg'),
            label: const Text("Reject", style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 10),
      ],

      // Eye Icon (Always Visible)
      IconButton(
        style: IconButton.styleFrom(
          backgroundColor: AppColors.appshade200Grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddPropertyScreen(id: property.id, isViewMode: true),
            ),
          );
        },
        icon: SvgPicture.asset(
          "assets/images/eye_icon.svg",
          colorFilter: ColorFilter.mode(AppColors.darkGrey, BlendMode.srcIn),
        ),
      ),
    ],
  );
}

/// The `PropertyImageSection` class is a Flutter widget that displays an image of a property with a
/// status tag in a stack layout.
class PropertyImageSection extends StatelessWidget {
  final Property property;
  const PropertyImageSection({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (property.images.isNotEmpty)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              property.images.first,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: getStatusColor(property.status),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              property.status,
              style: TextStyle(
                  color: AppColors.appWhite, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

/// The `PropertyDetailsSection` class in Dart is a stateless widget that displays details of a property
/// including title, location, price, and date listed.
class PropertyDetailsSection extends StatelessWidget {
  final Property property;
  const PropertyDetailsSection({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(property.title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                "assets/images/location.svg",
                colorFilter:
                    ColorFilter.mode(AppColors.darkGrey, BlendMode.srcIn),
                height: 20,
                width: 20,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${property.address} ${property.city}, ${property.state} ${property.zipCode}",
                      style: TextStyle(
                          color: AppColors.darkGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "\$${NumberFormat("#,###").format(property.price)}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PropertySection extends StatelessWidget {
  final Property property;
  const PropertySection({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group 1: Beds
              Row(
                children: [
                  SvgPicture.asset("assets/images/bed.svg"),
                  const SizedBox(width: 5),
                  Text(
                    "${(property.beds != null && property.beds.toString().isNotEmpty) ? property.beds : 0} beds",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),

              // Group 2: Baths
              Row(
                children: [
                  SvgPicture.asset("assets/images/drop.svg"),
                  const SizedBox(width: 5),
                  Text(
                    "${(property.baths != null && property.baths.toString().isNotEmpty) ? property.baths : 0} baths",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),

              // Group 3: Square Feet
              Row(
                children: [
                  SvgPicture.asset("assets/images/square_feet.svg"),
                  const SizedBox(width: 5),
                  Text(
                    "${property.squareFt} sqft",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Group 4: Submitted Date
          Row(
            children: [
              SvgPicture.asset("assets/images/clock.svg"),
              const SizedBox(width: 5),
              Text(
                "Submitted ${property.createdAt != null ? DateFormat('MMM dd, yyyy').format(property.createdAt!) : 'N/A'}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case "active":
      return const Color(0xFF10B981);
    case "under review":
      return const Color(0xFF3B82F6); // Hex color format for Flutter
    case "sold":
      return Colors.red;
    default:
      return Colors.grey;
  }
}
