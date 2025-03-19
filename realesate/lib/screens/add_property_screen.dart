import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:realesate/constant/app.colors.dart';

class AddPropertyScreen extends StatefulWidget {
  final String? id;
  final bool isViewMode;

  AddPropertyScreen({super.key, this.id, this.isViewMode = false});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _squareFtController = TextEditingController();
  final _bedsController = TextEditingController();
  final _bathsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _youtubeLinkController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final TextEditingController _plotNumberController = TextEditingController();
  String _selectedLandType = 'Residential';
  final List<String> _landTypes = ['Residential', 'Commercial', 'Agricultural'];

  String _selectedPropertyType = 'House';
  List<XFile> _selectedImages = [];
  Set<String> _selectedAmenities = {};

  final List<String> _propertyTypes = [
    'House',
    'Apartment',
    'Office',
    'Shop',
    'Land',
    'Warehouse'
  ];

  final Map<String, IconData> _amenities = {
    'Parking': Icons.local_parking,
    'Air Conditioning': Icons.ac_unit,
    'Furnished': Icons.chair,
    'Pool': Icons.pool,
    'Garden': Icons.yard,
    'Security': Icons.security,
    'Gym': Icons.fitness_center,
    'Internet': Icons.wifi,
  };

  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  List<Marker> _markers = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    if (widget.isViewMode) {
      _fetchPropertyDetails();
    } else {
      _signInAnonymously(); // Allow adding only when not in View Mode
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  /// Fetch property details from Firestore
  Future<void> _fetchPropertyDetails() async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('properties').doc(widget.id).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        setState(() {
          _titleController.text = data['title'] ?? '';
          _priceController.text = data['price'].toString();
          _squareFtController.text = data['area'].toString();
          _bedsController.text = data['bedrooms']?.toString() ?? '';
          _bathsController.text = data['bathrooms']?.toString() ?? '';
          _descriptionController.text = data['description'] ?? '';
          _youtubeLinkController.text = data['youtubeLink'] ?? '';
          _addressController.text = data['address'] ?? '';
          _cityController.text = data['city'] ?? '';
          _stateController.text = data['state'] ?? '';
          _zipController.text = data['zipCode'] ?? '';
          _selectedLocation = LatLng(
            (data['location'] as GeoPoint).latitude,
            (data['location'] as GeoPoint).longitude,
          );

          _selectedImages = data['images'] != null
              ? data['images'].map<XFile>((url) => XFile(url)).toList()
              : [];

          _selectedAmenities = data['amenities'] != null
              ? Set<String>.from(data['amenities'])
              : {};
        });
      }
    } catch (e) {
      print('Error fetching property details: $e');
    }
  }

  Future<void> _signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
      print("Signed in anonymously");
    } catch (e) {
      print("Error signing in anonymously: $e");
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 70,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e')),
        );
      }
      print('Error picking images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<bool> _handleLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Please turn on your Location to proceed or check your network connection'),
        ));
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Location permissions are denied'),
          ));
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location permissions are permanently denied'),
        ));
        return false;
      }

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error checking location permission: $e'),
      ));
      return false;
    }
  }

  Future<void> _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final LatLng location = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = location;
        _markers = [
          Marker(
            point: location,
            width: 80,
            height: 80,
            child: const Icon(
              Icons.location_pin,
              color: Colors.red,
              size: 40,
            ),
          ),
        ];
      });

      _mapController.move(location, 15);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Fixed background color
        surfaceTintColor: Colors.transparent, // Prevents auto tinting
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isViewMode ? 'View Property' : 'Add Property',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // ✅ Centers the title
        actions: widget.isViewMode
            ? [] // No actions in view mode
            : [
                TextButton(
                  onPressed: _submitForm,
                  child: const Text(
                    'Post',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
              ],
      ),
      body: Column(
        children: [
          Divider(
            // ✅ Divider added below AppBar
            color: AppColors.appshade300Grey,
            thickness: 1,
            height: 1, // Ensures it stays right below the AppBar
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageSection(),
                      const SizedBox(height: 16),
                      _buildYouTubeInput(),
                      const SizedBox(height: 16),
                      _buildPropertyDetails(),
                      const SizedBox(height: 24),
                      _buildLocationSection(),
                      const SizedBox(height: 24),
                      _buildAmenitiesSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: widget.isViewMode ? null : _pickImages, // Disable in view mode
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/camera.svg',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Add Photos (up to 10)',
                    style: TextStyle(color: AppColors.darkGrey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_selectedImages.isNotEmpty)
          Container(
            height: 100,
            margin: const EdgeInsets.only(top: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(File(_selectedImages[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (!widget.isViewMode) // Hide delete button in view mode
                      Positioned(
                        right: 12,
                        top: 7,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: SvgPicture.asset(
                              'assets/images/delete.svg',
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildYouTubeInput() {
    return TextFormField(
      controller: _youtubeLinkController,
      readOnly: widget.isViewMode,
      style: TextStyle(color: widget.isViewMode ? Colors.grey : null),
      decoration: InputDecoration(
        labelText: widget.isViewMode
            ? 'YouTube Video Link'
            : null, // Label in view mode
        labelStyle: TextStyle(color: Colors.grey.shade500),
        hintText: widget.isViewMode ? "" : 'Paste YouTube video link',
        hintStyle: TextStyle(
            color: widget.isViewMode
                ? AppColors.appshade300Grey
                : Colors.grey.shade400,
            fontSize: 14,
            fontWeight: FontWeight.w400),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12), // Adjust padding as needed
          child: SvgPicture.asset(
            'assets/images/video.svg',
            width: 20,
            height: 20,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.grey.shade400, // Active border color
            width: 1,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: widget.isViewMode, // Light gray background in view mode
        fillColor: widget.isViewMode
            ? Theme.of(context)
                .focusColor
                .withOpacity(0.06) // Uses default disabled color
            : Colors.white,
      ),
    );
  }

  Widget _buildPropertyDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _titleController,
          readOnly: widget.isViewMode,
          style: TextStyle(color: widget.isViewMode ? Colors.grey : null),
          decoration: InputDecoration(
            labelText: widget.isViewMode
                ? 'Property Title'
                : null, // Label in view mode
            labelStyle: TextStyle(color: Colors.grey.shade500),
            hintText: widget.isViewMode ? "" : 'Property Title',
            hintStyle: TextStyle(
                color: widget.isViewMode
                    ? AppColors.appshade300Grey
                    : Colors.grey.shade400,
                fontSize: 14,
                fontWeight: FontWeight.w400),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade400, // Active border color
                width: 1,
              ),
            ),
            filled: widget.isViewMode,
            fillColor: widget.isViewMode
                ? Theme.of(context).focusColor.withOpacity(0.06)
                : Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          style: TextStyle(color: widget.isViewMode ? Colors.grey : null),
          decoration: InputDecoration(
            labelText:
                widget.isViewMode ? 'Propery Type' : null, // Label in view mode
            labelStyle: TextStyle(color: Colors.grey.shade500),
            hintText: widget.isViewMode ? "" : 'Select Property Type',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade400, // Active border color
                width: 1,
              ),
            ),
            filled: widget.isViewMode,
            fillColor: widget.isViewMode
                ? Theme.of(context).focusColor.withOpacity(0.06)
                : Colors.white,
          ),
          value: _selectedPropertyType,
          items: _propertyTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: widget.isViewMode
              ? null
              : (value) {
                  setState(() {
                    _selectedPropertyType = value ?? '';
                  });
                },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                readOnly: widget.isViewMode,
                style: TextStyle(color: widget.isViewMode ? Colors.grey : null),
                decoration: InputDecoration(
                  labelText:
                      widget.isViewMode ? 'Price' : null, // Label in view mode
                  labelStyle: TextStyle(color: Colors.grey.shade500),
                  hintText: '\$ Price',
                  hintStyle: TextStyle(
                      color: widget.isViewMode
                          ? AppColors.appshade300Grey
                          : Colors.grey.shade400,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400, // Active border color
                      width: 1,
                    ),
                  ),
                  filled: widget.isViewMode,
                  fillColor: widget.isViewMode
                      ? Theme.of(context).focusColor.withOpacity(0.06)
                      : Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _squareFtController,
                keyboardType: TextInputType.number,
                readOnly: widget.isViewMode,
                style: TextStyle(color: widget.isViewMode ? Colors.grey : null),
                decoration: InputDecoration(
                  labelText: widget.isViewMode
                      ? 'Square Ft'
                      : null, // Label in view mode
                  labelStyle: TextStyle(color: Colors.grey.shade500),
                  hintText: 'Square Ft',
                  hintStyle: TextStyle(
                      color: widget.isViewMode
                          ? AppColors.appshade300Grey
                          : Colors.grey.shade400,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400, // Active border color
                      width: 1,
                    ),
                  ),
                  filled: widget.isViewMode,
                  fillColor: widget.isViewMode
                      ? Theme.of(context).focusColor.withOpacity(0.06)
                      : Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_selectedPropertyType == 'Land') ...[
          TextFormField(
            controller: _plotNumberController,
            readOnly: widget.isViewMode,
            style: TextStyle(color: widget.isViewMode ? Colors.grey : null),
            decoration: InputDecoration(
              labelText: widget.isViewMode
                  ? 'Plot Number'
                  : null, // Label in view mode
              labelStyle: TextStyle(color: Colors.grey.shade500),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.0,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey.shade400, // Active border color
                  width: 1,
                ),
              ),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            style: TextStyle(color: widget.isViewMode ? Colors.grey : null),
            decoration: InputDecoration(
              labelText:
                  widget.isViewMode ? "Land Type" : null, // Label in view mode
              labelStyle: TextStyle(color: Colors.grey.shade500),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.0,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey.shade400, // Active border color
                  width: 1,
                ),
              ),
            ),
            value: _selectedLandType,
            items: _landTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: widget.isViewMode
                ? null
                : (String? value) {
                    setState(() {
                      _selectedLandType = value ?? 'Residential';
                    });
                  },
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Location',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        const SizedBox(height: 16),
        Stack(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLocation ?? const LatLng(0, 0),
                    initialZoom: 15,
                    interactionOptions: InteractionOptions(
                      flags: widget.isViewMode
                          ? InteractiveFlag.none
                          : InteractiveFlag.all,
                    ),
                    onTap: widget.isViewMode
                        ? null
                        : (tapPosition, point) {
                            setState(() {
                              _selectedLocation = point;
                              _markers = [
                                Marker(
                                  point: point,
                                  width: 80,
                                  height: 80,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ];
                            });
                          },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(markers: _markers),
                  ],
                ),
              ),
            ),
            if (!widget.isViewMode)
              Positioned(
                right: 8,
                top: 8,
                child: FloatingActionButton.small(
                  onPressed: _getCurrentLocation,
                  child: const Icon(Icons.my_location),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          readOnly: widget.isViewMode,
          style: TextStyle(color: widget.isViewMode ? Colors.grey : null),
          decoration: InputDecoration(
            labelText:
                widget.isViewMode ? "Address" : null, // Label in view mode
            labelStyle: TextStyle(color: Colors.grey.shade500),
            hintText: 'Address',
            hintStyle: TextStyle(
                color: widget.isViewMode
                    ? AppColors.appshade300Grey
                    : Colors.grey.shade400,
                fontSize: 14,
                fontWeight: FontWeight.w400),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade400, // Active border color
                width: 1,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: widget.isViewMode,
            fillColor: widget.isViewMode
                ? Theme.of(context).focusColor.withOpacity(0.06)
                : Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityController,
                readOnly: widget.isViewMode,
                style: TextStyle(color: widget.isViewMode ? Colors.grey : null),
                decoration: InputDecoration(
                  labelText:
                      widget.isViewMode ? "City" : null, // Label in view mode
                  labelStyle: TextStyle(color: Colors.grey.shade500),
                  hintText: 'City',
                  hintStyle: TextStyle(
                      color: widget.isViewMode
                          ? AppColors.appshade300Grey
                          : Colors.grey.shade400,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400, // Active border color
                      width: 1,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: widget.isViewMode,
                  fillColor: widget.isViewMode
                      ? Theme.of(context).focusColor.withOpacity(0.06)
                      : Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _stateController,
                readOnly: widget.isViewMode,
                style: TextStyle(color: widget.isViewMode ? Colors.grey : null),
                decoration: InputDecoration(
                  labelText:
                      widget.isViewMode ? "State" : null, // Label in view mode
                  labelStyle: TextStyle(color: Colors.grey.shade500),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400, // Active border color
                      width: 1,
                    ),
                  ),
                  hintText: 'State',
                  hintStyle: TextStyle(
                      color: widget.isViewMode
                          ? AppColors.appshade300Grey
                          : Colors.grey.shade400,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: widget.isViewMode,
                  fillColor: widget.isViewMode
                      ? Theme.of(context).focusColor.withOpacity(0.06)
                      : Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _zipController,
          keyboardType: TextInputType.number,
          readOnly: widget.isViewMode,
          style: TextStyle(color: widget.isViewMode ? Colors.grey : null),
          decoration: InputDecoration(
            labelText:
                widget.isViewMode ? "Zip Code" : null, // Label in view mode
            labelStyle: TextStyle(color: Colors.grey.shade500),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade400, // Active border color
                width: 1,
              ),
            ),
            hintText: 'ZIP Code',
            hintStyle: TextStyle(
                color: widget.isViewMode
                    ? AppColors.appshade300Grey
                    : Colors.grey.shade400,
                fontSize: 14,
                fontWeight: FontWeight.w400),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: widget.isViewMode,
            fillColor: widget.isViewMode
                ? Theme.of(context).focusColor.withOpacity(0.06)
                : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amenities',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _amenities.entries.map((entry) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.06,
              width:
                  (MediaQuery.of(context).size.width - 48) / 2, // Equal width
              padding:
                  const EdgeInsets.symmetric(horizontal: 8), // Minimal padding
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .focusColor
                    .withOpacity(0.06), // Adjust opacity here
                borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _selectedAmenities.contains(entry.key),
                    onChanged: widget.isViewMode
                        ? null // Disable checkbox in view mode
                        : (bool? value) {
                            setState(() {
                              if (value ?? false) {
                                _selectedAmenities.add(entry.key);
                              } else {
                                _selectedAmenities.remove(entry.key);
                              }
                            });
                          },
                    materialTapTargetSize: MaterialTapTargetSize
                        .shrinkWrap, // Reduce extra spacing
                    visualDensity: VisualDensity.compact, // Compact checkbox
                  ),
                  Icon(
                    entry.value,
                    size: 20,
                    color: AppColors.darkGrey,
                  ),
                  const SizedBox(width: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown, // Shrinks text size if needed
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1, // Ensures single line
                      overflow: TextOverflow
                          .visible, // Prevents ellipsis and ensures full text is shown
                      softWrap: false, // Prevents wrapping
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        List<String> imageUrls = await _uploadImages();

        if (_selectedLocation == null) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please select a location on the map')),
          );
          return;
        }

        final propertyData = {
          'title': _titleController.text,
          'type': _selectedPropertyType,
          'price': double.parse(_priceController.text),
          'area': double.parse(_squareFtController.text),
          'description': _descriptionController.text,
          'status': "Under Review",
          'location': GeoPoint(
            _selectedLocation!.latitude,
            _selectedLocation!.longitude,
          ),
          'youtubeLink': _youtubeLinkController.text,
          'images': imageUrls,
          'createdAt': FieldValue.serverTimestamp(),
          'address': _addressController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'zipCode': _zipController.text,
        };

        if (_shouldShowBedBath()) {
          propertyData['bedrooms'] = int.parse(_bedsController.text);
          propertyData['bathrooms'] = int.parse(_bathsController.text);
        }

        if (_selectedPropertyType == 'Land') {
          propertyData['plotNumber'] = _plotNumberController.text;
          propertyData['landType'] = _selectedLandType;
        }

        await _firestore.collection('properties').add(propertyData);

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property added successfully!')),
        );

        Navigator.pop(context);
      } catch (e) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding property: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _squareFtController.dispose();
    _bedsController.dispose();
    _bathsController.dispose();
    _descriptionController.dispose();
    _youtubeLinkController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _plotNumberController.dispose();
    super.dispose();
  }

  bool _shouldShowBedBath() {
    return _selectedPropertyType == 'House' ||
        _selectedPropertyType == 'Apartment';
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];

    if (_auth.currentUser == null) {
      await _signInAnonymously();
    }

    for (var image in _selectedImages) {
      try {
        String fileName =
            'property_${DateTime.now().millisecondsSinceEpoch}_${imageUrls.length}.jpg';
        Reference ref = _storage.ref().child('property_images/$fileName');

        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          final metadata = SettableMetadata(
              contentType: 'image/jpeg',
              customMetadata: {'picked-file-path': image.path});

          await ref.putData(bytes, metadata);
        } else {
          await ref.putFile(File(image.path));
        }

        String downloadUrl = await ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading image: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
        }
      }
    }

    return imageUrls;
  }
}
