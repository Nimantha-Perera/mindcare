import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirestoreDebugScreen extends StatefulWidget {
  const FirestoreDebugScreen({Key? key}) : super(key: key);

  @override
  State<FirestoreDebugScreen> createState() => _FirestoreDebugScreenState();
}

class _FirestoreDebugScreenState extends State<FirestoreDebugScreen> {
  String _status = 'Not tested';
  bool _isLoading = false;
  List<String> _logs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Debug'),
        backgroundColor: const Color(0xFF6A4C93),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: TextStyle(
                        color: _status.contains('Success') 
                            ? Colors.green 
                            : _status.contains('Error') 
                                ? Colors.red 
                                : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testBasicConnection,
                  child: const Text('Test Connection'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testRead,
                  child: const Text('Test Read'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testWrite,
                  child: const Text('Test Write'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addSampleDoctor,
                  child: const Text('Add 1 Doctor'),
                ),
                ElevatedButton(
                  onPressed: _clearLogs,
                  child: const Text('Clear Logs'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),

            // Loading Indicator
            if (_isLoading)
              const LinearProgressIndicator(),

            const SizedBox(height: 16),

            // Logs
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Debug Logs',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            final log = _logs[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                log,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  color: log.startsWith('❌') 
                                      ? Colors.red 
                                      : log.startsWith('✅') 
                                          ? Colors.green 
                                          : Colors.black87,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _log(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} $message');
    });
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  Future<void> _testBasicConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing basic connection...';
    });
    _log('🔄 Testing Firebase/Firestore initialization...');

    try {
      // Check if Firebase is initialized
      await Firebase.initializeApp();
      _log('✅ Firebase initialized successfully');

      // Get Firestore instance
      final firestore = FirebaseFirestore.instance;
      _log('✅ Firestore instance created');

      // Try to enable network (in case it was disabled)
      await firestore.enableNetwork();
      _log('✅ Firestore network enabled');

      setState(() {
        _status = 'Success: Basic connection working';
        _isLoading = false;
      });
      _log('✅ Basic connection test passed');

    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
      _log('❌ Basic connection failed: $e');
    }
  }

  Future<void> _testRead() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing read operation...';
    });
    _log('🔄 Testing Firestore read operation...');

    try {
      final firestore = FirebaseFirestore.instance;
      
      // Try to read from doctors collection
      final querySnapshot = await firestore
          .collection('doctors')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 15));

      _log('✅ Read operation successful');
      _log('📊 Found ${querySnapshot.docs.length} documents in doctors collection');

      setState(() {
        _status = 'Success: Read operation working (${querySnapshot.docs.length} docs)';
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _status = 'Error reading: $e';
        _isLoading = false;
      });
      _log('❌ Read operation failed: $e');
    }
  }

  Future<void> _testWrite() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing write operation...';
    });
    _log('🔄 Testing Firestore write operation...');

    try {
      final firestore = FirebaseFirestore.instance;
      
      // Try to write a test document
      await firestore
          .collection('test')
          .doc('connection_test')
          .set({
            'timestamp': FieldValue.serverTimestamp(),
            'test': true,
            'message': 'Connection test successful'
          })
          .timeout(const Duration(seconds: 15));

      _log('✅ Write operation successful');

      setState(() {
        _status = 'Success: Write operation working';
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _status = 'Error writing: $e';
        _isLoading = false;
      });
      _log('❌ Write operation failed: $e');
    }
  }

  Future<void> _addSampleDoctor() async {
    setState(() {
      _isLoading = true;
      _status = 'Adding sample doctor...';
    });
    _log('🔄 Adding one sample Sri Lankan doctor...');

    try {
      final firestore = FirebaseFirestore.instance;
      
      // Add one simple doctor
      await firestore
          .collection('doctors')
          .add({
            'name': 'Dr. Test Perera',
            'specialty': 'Clinical Psychology',
            'rating': 4.5,
            'reviews': 10,
            'experience': 5,
            'isOnline': true,
            'consultationFee': 5000,
            'profileImage': '',
            'about': 'Test doctor for connection verification',
            'nextAvailable': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 1))),
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'isActive': true,
            'languages': ['Sinhala', 'English'],
            'sessionTypes': ['video', 'chat'],
          })
          .timeout(const Duration(seconds: 15));

      _log('✅ Sample doctor added successfully');

      setState(() {
        _status = 'Success: Sample doctor added';
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _status = 'Error adding doctor: $e';
        _isLoading = false;
      });
      _log('❌ Failed to add sample doctor: $e');
    }
  }
}