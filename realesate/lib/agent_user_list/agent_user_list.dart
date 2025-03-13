import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:realesate/agent_user_list/agent_user_controller.dart';
import 'package:realesate/agent_user_list/agent_user_model.dart';
import 'package:realesate/constant/app.colors.dart';
import 'package:realesate/constant/app.strings.dart';

class AgentPropertyListPage extends StatelessWidget {
  final AgentUserPropertyController controller =
      Get.put(AgentUserPropertyController());

  AgentPropertyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar:
            false, // Ensures AppBar background remains solid

        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildSearchBar(),
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
  PreferredSize _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(66),
      child: AppBar(
        backgroundColor: Colors.white, // Fixed background color
        surfaceTintColor: Colors.transparent, // Prevents auto tinting
        elevation: 0,
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Ensures proper spacing
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20), // Moves the title down
              child: Text(
                AppStrings.myProperty,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(top: 20), // Aligns icon with the title
              child: IconButton(
                icon: SvgPicture.asset(
                  'addplus.svg',
                  width: 32,
                  height: 32,
                ),
                onPressed: () {},
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
  Widget _buildSearchBar() {
    return SizedBox(
      width: 350,
      height: 48,
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
            child: Text(AppStrings.underReview,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500))),
        Tab(
            child: Text(AppStrings.active,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500))),
        Tab(
            child: Text(AppStrings.inActive,
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
        border: Border.all(color: AppColors.appshade200Grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PropertyImageSection(property: property),
          PropertyDetailsSection(property: property),
          if (property.images.isNotEmpty) PropertyGallery(property: property),
          if (property.videoTourAvailable) const VideoTourSection(),
          Divider(color: AppColors.appshade200Grey, thickness: 1),
          PropertyStatusSection(property: property),
        ],
      ),
    );
  }
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
              color: property.statusTagColor,
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
                "location.svg",
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
                      property.location,
                      style: TextStyle(
                          color: AppColors.darkGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${property.latitude}° N, ${property.longitude}° W",
                      style: TextStyle(
                          fontSize: 14,
                          color: AppColors.darkGrey,
                          fontWeight: FontWeight.w400),
                    ),
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
              Row(
                children: [
                  SvgPicture.asset(
                    "clock.svg",
                    colorFilter:
                        ColorFilter.mode(AppColors.darkGrey, BlendMode.srcIn),
                    height: 16,
                    width: 16,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    property.dateListed,
                    style: TextStyle(color: AppColors.darkGrey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}



/// This Dart function displays a full-size image in a dialog with a close button.
///
/// Args:
///   context (BuildContext): The `context` parameter in Flutter represents the location of a widget
/// within the widget tree. It is typically used to access information about the current theme, media
/// query, navigator, etc. The `BuildContext` class provides methods for finding the nearest widget of a
/// specified type in the widget tree.
///   imageUrl (String): The `imageUrl` parameter in the `_showFullImage` function is a string that
/// represents the URL of the image that you want to display in a dialog box. This URL is used to fetch
/// the image from the network and display it in the dialog box when the function is called.
///
/// Returns:
///   A Dialog widget is being returned. The Dialog widget contains a Stack widget as its child, which
/// in turn contains a ClipRRect widget with an Image.network widget inside it. Additionally, there is a
/// Positioned widget with an IconButton inside it for closing the dialog.
void _showFullImage(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (context) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20), 
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            right:
                MediaQuery.of(context).size.width * 0.08,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      );
    },
  );
}

/// The `PropertyGallery` class displays a gallery of images for a property with a count of photos and a
/// preview of the first three images.
class PropertyGallery extends StatelessWidget {
  final Property property;

  const PropertyGallery({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset("gallery.svg"),
              const SizedBox(width: 5),
              Text(
                "${property.images.length} photos",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGrey),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: property.images.take(3).map((imageUrl) {
              return GestureDetector(
                onTap: () {
                  _showFullImage(context, imageUrl);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(imageUrl,
                        height: 64, width: 64, fit: BoxFit.cover),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// The `VideoTourSection` class is a StatelessWidget that displays a video tour availability message
/// with an icon and text.
class VideoTourSection extends StatelessWidget {
  const VideoTourSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          SvgPicture.asset("youtube.svg"),
          const SizedBox(width: 5),
          Text(
            AppStrings.videoAvailable,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.darkGrey),
          ),
        ],
      ),
    );
  }
}

/// The `PropertyStatusSection` class displays the status of a property with an icon and text based on
/// its current status.
class PropertyStatusSection extends StatelessWidget {
  final Property property;

  const PropertyStatusSection({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                "pending.svg",
                colorFilter:
                    ColorFilter.mode(property.statusTagColor, BlendMode.srcIn),
              ),
              const SizedBox(width: 5),
              Text(
                property.status == AppStrings.underReview
                    ? AppStrings.underReviewText
                    : property.status == AppStrings.active
                        ? AppStrings.activeProperty
                        : AppStrings.inActiveProperty,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGrey),
              ),
            ],
          ),
          SvgPicture.asset("next_arrow.svg"),
        ],
      ),
    );
  }
}
