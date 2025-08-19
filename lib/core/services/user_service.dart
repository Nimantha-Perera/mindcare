import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class for User data
class User {
  final String? id;
  final String name;
  final String email;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    this.id,
    required this.name,
    required this.email,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  /// Create User from Firestore document
  factory User.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }

    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  /// Convert User to Firestore document data
  Map<String, dynamic> toDocument({bool isUpdate = false}) {
    final Map<String, dynamic> data = {
      'name': name,
      'email': email,
      'role': role,
    };

    if (isUpdate) {
      data['updatedAt'] = FieldValue.serverTimestamp();
    } else {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    return data;
  }

  /// Create a copy of User with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role)';
  }
}

/// Exception classes for better error handling
class UserServiceException implements Exception {
  final String message;
  final String? code;
  
  const UserServiceException(this.message, {this.code});
  
  @override
  String toString() => 'UserServiceException: $message';
}

class UserNotFoundException extends UserServiceException {
  const UserNotFoundException(String userId) 
      : super('User with ID $userId not found', code: 'user-not-found');
}

class InvalidUserDataException extends UserServiceException {
  const InvalidUserDataException(String message) 
      : super(message, code: 'invalid-data');
}

/// Service class for managing users in Firestore
class UserService {
  static const String _collection = 'users';
  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get all users from Firestore
  Future<List<User>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => User.fromDocument(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw UserServiceException('Failed to load users: ${e.message}', code: e.code);
    } catch (e) {
      throw UserServiceException('Failed to load users: $e');
    }
  }

  /// Get users stream for real-time updates
  Stream<List<User>> getUsersStream() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => User.fromDocument(doc))
            .toList());
  }

  /// Get a specific user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (!doc.exists) {
        return null;
      }
      return User.fromDocument(doc);
    } on FirebaseException catch (e) {
      throw UserServiceException('Failed to get user: ${e.message}', code: e.code);
    } catch (e) {
      throw UserServiceException('Failed to get user: $e');
    }
  }

  /// Add a new user
  Future<String> addUser(User user) async {
    // Validate user data
    _validateUserData(user);

    // Check if email already exists
    if (await _emailExists(user.email)) {
      throw UserServiceException('Email already exists: ${user.email}', code: 'email-exists');
    }

    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(user.toDocument());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw UserServiceException('Failed to add user: ${e.message}', code: e.code);
    } catch (e) {
      throw UserServiceException('Failed to add user: $e');
    }
  }

  /// Update an existing user
  Future<void> updateUser(User user) async {
    if (user.id == null) {
      throw InvalidUserDataException('User ID cannot be null for update');
    }

    // Validate user data
    _validateUserData(user);

    // Check if email exists for other users
    if (await _emailExistsForOtherUser(user.email, user.id!)) {
      throw UserServiceException('Email already exists: ${user.email}', code: 'email-exists');
    }

    try {
      await _firestore
          .collection(_collection)
          .doc(user.id!)
          .update(user.toDocument(isUpdate: true));
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw UserNotFoundException(user.id!);
      }
      throw UserServiceException('Failed to update user: ${e.message}', code: e.code);
    } catch (e) {
      throw UserServiceException('Failed to update user: $e');
    }
  }

  /// Delete a user
  Future<void> deleteUser(String userId) async {
    if (userId.isEmpty) {
      throw InvalidUserDataException('User ID cannot be empty');
    }

    try {
      await _firestore.collection(_collection).doc(userId).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw UserNotFoundException(userId);
      }
      throw UserServiceException('Failed to delete user: ${e.message}', code: e.code);
    } catch (e) {
      throw UserServiceException('Failed to delete user: $e');
    }
  }

  /// Search users by name or email
  Future<List<User>> searchUsers(String query) async {
    if (query.isEmpty) {
      return getAllUsers();
    }

    try {
      final users = await getAllUsers();
      final searchQuery = query.toLowerCase();
      
      return users.where((user) {
        return user.name.toLowerCase().contains(searchQuery) ||
               user.email.toLowerCase().contains(searchQuery);
      }).toList();
    } catch (e) {
      throw UserServiceException('Failed to search users: $e');
    }
  }

  /// Filter users by role
  Future<List<User>> getUsersByRole(String role) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('role', isEqualTo: role.toLowerCase())
          .get();
      
      return snapshot.docs
          .map((doc) => User.fromDocument(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw UserServiceException('Failed to filter users: ${e.message}', code: e.code);
    } catch (e) {
      throw UserServiceException('Failed to filter users: $e');
    }
  }

  /// Get user count
  Future<int> getUserCount() async {
    try {
      final snapshot = await _firestore.collection(_collection).count().get();
      return snapshot.count ?? 0;
    } on FirebaseException catch (e) {
      throw UserServiceException('Failed to get user count: ${e.message}', code: e.code);
    } catch (e) {
      throw UserServiceException('Failed to get user count: $e');
    }
  }

  /// Get user count by role
  Future<Map<String, int>> getUserCountByRole() async {
    try {
      final users = await getAllUsers();
      final counts = <String, int>{};
      
      for (final user in users) {
        counts[user.role] = (counts[user.role] ?? 0) + 1;
      }
      
      return counts;
    } catch (e) {
      throw UserServiceException('Failed to get user count by role: $e');
    }
  }

  /// Batch operations
  /// Add multiple users
  Future<void> addUsers(List<User> users) async {
    if (users.isEmpty) return;

    // Validate all users first
    for (final user in users) {
      _validateUserData(user);
    }

    try {
      final batch = _firestore.batch();
      
      for (final user in users) {
        final docRef = _firestore.collection(_collection).doc();
        batch.set(docRef, user.toDocument());
      }
      
      await batch.commit();
    } on FirebaseException catch (e) {
      throw UserServiceException('Failed to add users: ${e.message}', code: e.code);
    } catch (e) {
      throw UserServiceException('Failed to add users: $e');
    }
  }

  /// Delete multiple users
  Future<void> deleteUsers(List<String> userIds) async {
    if (userIds.isEmpty) return;

    try {
      final batch = _firestore.batch();
      
      for (final userId in userIds) {
        if (userId.isNotEmpty) {
          batch.delete(_firestore.collection(_collection).doc(userId));
        }
      }
      
      await batch.commit();
    } on FirebaseException catch (e) {
      throw UserServiceException('Failed to delete users: ${e.message}', code: e.code);
    } catch (e) {
      throw UserServiceException('Failed to delete users: $e');
    }
  }

  // Private helper methods

  /// Validate user data
  void _validateUserData(User user) {
    if (user.name.trim().isEmpty) {
      throw InvalidUserDataException('Name cannot be empty');
    }
    
    if (user.email.trim().isEmpty) {
      throw InvalidUserDataException('Email cannot be empty');
    }
    
    if (!_isValidEmail(user.email)) {
      throw InvalidUserDataException('Invalid email format: ${user.email}');
    }
    
    if (user.role.trim().isEmpty) {
      throw InvalidUserDataException('Role cannot be empty');
    }

    // Validate role values
    const validRoles = ['user', 'admin'];
    if (!validRoles.contains(user.role.toLowerCase())) {
      throw InvalidUserDataException('Invalid role: ${user.role}. Must be one of: ${validRoles.join(', ')}');
    }
  }

  /// Check if email format is valid
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Check if email already exists
  Future<bool> _emailExists(String email) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// Check if email exists for other users (excluding current user)
  Future<bool> _emailExistsForOtherUser(String email, String currentUserId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('email', isEqualTo: email)
        .get();
    
    return snapshot.docs.any((doc) => doc.id != currentUserId);
  }

  /// Utility method to convert role string for consistent comparison
  static String normalizeRole(String role) {
    return role.toLowerCase().trim();
  }

  /// Get available user roles
  static List<String> getAvailableRoles() {
    return ['user', 'admin'];
  }
}