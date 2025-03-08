import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all properties
  Stream<QuerySnapshot> getProperties() {
    return _firestore
        .collection('properties')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get properties by type
  Stream<QuerySnapshot> getPropertiesByType(String type) {
    return _firestore
        .collection('properties')
        .where('type', isEqualTo: type)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Delete property
  Future<void> deleteProperty(String id) {
    return _firestore.collection('properties').doc(id).delete();
  }

  // Update property
  Future<void> updateProperty(String id, Map<String, dynamic> data) {
    return _firestore.collection('properties').doc(id).update(data);
  }
}