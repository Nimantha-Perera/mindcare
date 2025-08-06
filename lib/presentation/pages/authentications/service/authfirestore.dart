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
        // Create new user with default role
        userData['createdAt'] = FieldValue.serverTimestamp();
        userData['role'] = userData['role'] ?? 'user'; // Default role is 'user'
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

  // Get user role by UID
  Future<String?> getUserRole(String uid) async {
    try {
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        return data?['role'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  // Get current user's role
  Future<String?> getCurrentUserRole() async {
    try {
      final String? uid = getCurrentUserUid();
      if (uid != null) {
        return await getUserRole(uid);
      }
      return null;
    } catch (e) {
      print('Error getting current user role: $e');
      return null;
    }
  }

  // Set user role (for admin management)
  Future<bool> setUserRole(String uid, String role) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error setting user role: $e');
      return false;
    }
  }

  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    final String? role = await getCurrentUserRole();
    return role == 'admin';
  }

  // Get all users (admin function)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['uid'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  // Get users by role
  Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['uid'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting users by role: $e');
      return [];
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    required String uid,
    Map<String, dynamic>? updates,
  }) async {
    try {
      if (updates != null && updates.isNotEmpty) {
        updates['updatedAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('users').doc(uid).update(updates);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Delete user (admin function)
  Future<bool> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }
}