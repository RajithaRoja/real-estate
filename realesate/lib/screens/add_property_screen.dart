import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';


class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

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
    _signInAnonymously();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
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
          content: Text('Location services are disabled. Please enable the services'),
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
        desiredAccuracy: LocationAccuracy.high
      );

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Property'),
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: const Text('Post', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Form(
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
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickImages,
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
                  Icon(Icons.camera_alt_outlined, 
                      size: 40, color: Colors.grey[600]),
                  const SizedBox(height: 8),
                  Text('Add Photos (up to 10)',
                      style: TextStyle(color: Colors.grey[600])),
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
                    Positioned(
                      right: 12,
                      top: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, 
                              color: Colors.white, size: 16),
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
      decoration: InputDecoration(
        hintText: 'Paste YouTube video link',
        prefixIcon: const Icon(Icons.video_library_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildPropertyDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Property Title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            hintText: 'Select Property Type',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          value: _selectedPropertyType,
          items: _propertyTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedPropertyType = value ?? '';
            });
          },
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please select a property type';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Price',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Required';
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Invalid price';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _squareFtController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Square Ft',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Required';
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Invalid size';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _bedsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Beds',
                  prefixIcon: const Icon(Icons.bed),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Required';
                  }
                  if (int.tryParse(value!) == null) {
                    return 'Invalid';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _bathsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Baths',
                  prefixIcon: const Icon(Icons.bathroom),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Required';
                  }
                  if (int.tryParse(value!) == null) {
                    return 'Invalid';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Property Description',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
        if (_selectedPropertyType == 'Land') ...[
          TextFormField(
            controller: _plotNumberController,
            decoration: const InputDecoration(
              labelText: 'Plot Number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Land Type',
              border: OutlineInputBorder(),
            ),
            value: _selectedLandType,
            items: _landTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (String? value) {
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    onTap: (tapPosition, point) {
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
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(markers: _markers),
                  ],
                ),
              ),
            ),
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
          decoration: InputDecoration(
            hintText: 'Address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter an address';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  hintText: 'City',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _stateController,
                decoration: InputDecoration(
                  hintText: 'State',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _zipController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'ZIP Code',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter a ZIP code';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Amenities', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _amenities.entries.map((entry) {
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 48) / 2,
              child: CheckboxListTile(
                title: Row(
                  children: [
                    Icon(entry.value, size: 20),
                    const SizedBox(width: 8),
                    Text(entry.key, style: const TextStyle(fontSize: 14)),
                  ],
                ),
                value: _selectedAmenities.contains(entry.key),
                onChanged: (bool? value) {
                  setState(() {
                    if (value ?? false) {
                      _selectedAmenities.add(entry.key);
                    } else {
                      _selectedAmenities.remove(entry.key);
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
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
            const SnackBar(content: Text('Please select a location on the map')),
          );
          return;
        }

        final propertyData = {
          'title': _titleController.text,
          'type': _selectedPropertyType,
          'price': double.parse(_priceController.text),
          'area': double.parse(_squareFtController.text),
          'description': _descriptionController.text,
          'location': GeoPoint(
            _selectedLocation!.latitude,
            _selectedLocation!.longitude,
          ),
          'images': imageUrls,
          'createdAt': FieldValue.serverTimestamp(),
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
        String fileName = 'property_${DateTime.now().millisecondsSinceEpoch}_${imageUrls.length}.jpg';
        Reference ref = _storage.ref().child('property_images/$fileName');
        
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          final metadata = SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {'picked-file-path': image.path}
          );
          
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