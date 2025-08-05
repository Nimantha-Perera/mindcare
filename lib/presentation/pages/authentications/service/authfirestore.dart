import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user data from Firestore
  Future<DocumentSnapshot?> getCurrentUser() async {
    try {
      final User? currentUser = _auth.currentUser;
      
      if (currentUser != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
        
        return userDoc;
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Get current user data as a stream (real-time updates)
  Stream<DocumentSnapshot>? getCurrentUserStream() {
    final User? currentUser = _auth.currentUser;
    
    if (currentUser != null) {
      return _firestore
          .collection('users')
          .doc(currentUser.uid)
          .snapshots();
    }
    return null;
  }

  // Get current user data as a Map
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final DocumentSnapshot? userDoc = await getCurrentUser();
      
      if (userDoc != null && userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting current user data: $e');
      return null;
    }
  }

  // Create or update user data in Firestore (useful after Google Sign-In)
  Future<bool> createOrUpdateUser({
    required String uid,
    required String email,
    required String name,
    String? photoUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(uid);
      
      // Check if user already exists
      final userDoc = await userRef.get();
      
      Map<String, dynamic> userData = {
        'email': email,
        'name': name,
        'photoUrl': photoUrl,
        'lastLogin': FieldValue.serverTimestamp(),
        ...?additionalData,
      };

      if (userDoc.exists) {
        // Update existing user
        await userRef.update(userData);
      } else {
        // Create new user
        userData['createdAt'] = FieldValue.serverTimestamp();
        await userRef.set(userData);
      }
      
      return true;
    } catch (e) {
      print('Error creating/updating user: $e');
      return false;
    }
  }

  // Get current user's UID
  String? getCurrentUserUid() {
    return _auth.currentUser?.uid;
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Get current Firebase Auth user
  User? getCurrentFirebaseUser() {
    return _auth.currentUser;
  }
}