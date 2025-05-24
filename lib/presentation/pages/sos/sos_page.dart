import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class SOSPage extends StatefulWidget {
  const SOSPage({Key? key}) : super(key: key);

  @override
  State<SOSPage> createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final List<String> _emergencyContacts = [];
  bool _isAddingContact = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Load emergency contacts here from local storage or user preferences
    _loadEmergencyContacts();
  }

  void _loadEmergencyContacts() {
    // Mock data - in real app, load from storage
    setState(() {
      _emergencyContacts.addAll([
        'Mom: 555-123-4567',
        'Dad: 555-234-5678',
        'Therapist: 555-345-6789',
      ]);
    });
  }

  Future<void> _makeCall(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch dialer')),
        );
      }
    }
  }

  void _addEmergencyContact() {
    if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
      setState(() {
        _emergencyContacts.add('${_nameController.text}: ${_phoneController.text}');
        _isAddingContact = false;
        _nameController.clear();
        _phoneController.clear();
      });
    }
  }

  void _sendSOSMessage() async {
    if (_emergencyContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add emergency contacts first')),
      );
      return;
    }

    final String message = 
        "EMERGENCY: I need help right now. This is an automated SOS message from my MindCare app.";
    
    try {
      await Share.share(message, subject: 'EMERGENCY SOS ALERT');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending SOS: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isLandscape = screenWidth > screenHeight;

    // Set system UI overlay style for full immersive experience
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: isSmallScreen ? 45 : 56,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.red),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Emergency SOS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade700,
              Colors.red.shade500,
              Colors.red.shade100,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: isLandscape ? _buildLandscapeLayout(screenWidth, screenHeight) : _buildPortraitLayout(screenWidth, screenHeight),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(double screenWidth, double screenHeight) {
    // Calculate responsive dimensions
    final sosButtonSize = screenWidth < 400 ? screenWidth * 0.4 : 180.0;
    final innerButtonSize = sosButtonSize * 0.9;
    final double fontSize = screenWidth < 360 ? 16.0 : 18.0;

    return Column(
      children: [
        SizedBox(height: screenHeight * 0.02),
        
        // SOS Button
        Padding(
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
          child: ScaleTransition(
            scale: _pulseAnimation,
            child: GestureDetector(
              onTap: _sendSOSMessage,
              child: Container(
                width: sosButtonSize,
                height: sosButtonSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.shade600,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade300.withOpacity(0.8),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: innerButtonSize,
                    height: innerButtonSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Center(
                      child: Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth < 360 ? 36 : 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Tap the SOS button to alert your emergency contacts',
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth < 360 ? 14 : 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        SizedBox(height: screenHeight * 0.03),
        
        Expanded(
          child: _buildContactsContainer(fontSize, screenWidth),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(double screenWidth, double screenHeight) {
    // Landscape-specific responsive values
    final sosButtonSize = screenHeight * 0.35;
    final innerButtonSize = sosButtonSize * 0.9;
    final double fontSize = 16.0;

    return Row(
      children: [
        // Left side with SOS button
        SizedBox(
          width: screenWidth * 0.4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: GestureDetector(
                  onTap: _sendSOSMessage,
                  child: Container(
                    width: sosButtonSize,
                    height: sosButtonSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.shade600,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.shade300.withOpacity(0.8),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: innerButtonSize,
                        height: innerButtonSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Center(
                          child: Text(
                            'SOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap to alert contacts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        
        // Right side with contacts
        Expanded(
          child: _buildContactsContainer(fontSize, screenWidth),
        ),
      ],
    );
  }

  Widget _buildContactsContainer(double fontSize, double screenWidth) {
    final bool isSmallScreen = screenWidth < 360;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Emergency Contacts',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _isAddingContact = true;
                  });
                },
              ),
            ],
          ),
          
          SizedBox(height: isSmallScreen ? 10 : 15),
          
          // if (_isAddingContact)
          //   _buildAddContactForm(isSmallScreen),
          
          // Expanded(
          //   child: _emergencyContacts.isEmpty
          //       ? Center(
          //           child: Text(
          //             'No emergency contacts added yet.\nTap the + button to add contacts.',
          //             textAlign: TextAlign.center,
          //             style: TextStyle(
          //               color: Colors.grey,
          //               fontSize: isSmallScreen ? 14 : 16,
          //             ),
          //           ),
          //         )
          //       : ListView.builder(
          //           itemCount: _emergencyContacts.length,
          //           itemBuilder: (context, index) {
          //             final contact = _emergencyContacts[index];
          //             final parts = contact.split(': ');
          //             final name = parts[0];
          //             final phone = parts.length > 1 ? parts[1] : '';
                      
          //             return Dismissible(
          //               key: Key(contact),
          //               background: Container(
          //                 color: Colors.red.shade100,
          //                 alignment: Alignment.centerRight,
          //                 padding: const EdgeInsets.only(right: 20),
          //                 child: const Icon(Icons.delete, color: Colors.red),
          //               ),
          //               direction: DismissDirection.endToStart,
          //               onDismissed: (direction) {
          //                 setState(() {
          //                   _emergencyContacts.removeAt(index);
          //                 });
          //               },
          //               child: _buildContactCard(name, phone, isSmallScreen),
          //             );
          //           },
          //         ),
          // ),
          
          SizedBox(height: isSmallScreen ? 10 : 15),
          
          _buildHelplineSection(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildContactCard(String name, String phone, bool isSmallScreen) {
    return Card(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16, 
          vertical: isSmallScreen ? 4 : 8
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person, color: Colors.red.shade400, size: isSmallScreen ? 18 : 24),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 14 : 16,
          ),
        ),
        subtitle: Text(
          phone,
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.call, color: Colors.green.shade600, size: isSmallScreen ? 20 : 24),
          onPressed: () => _makeCall(phone.replaceAll('-', '')),
        ),
      ),
    );
  }

  Widget _buildAddContactForm(bool isSmallScreen) {
    return Card(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 15),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Emergency Contact',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isSmallScreen ? 10 : 15),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person_outline),
                contentPadding: isSmallScreen ? 
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12) : 
                    null,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 10),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.phone_outlined),
                contentPadding: isSmallScreen ? 
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12) : 
                    null,
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: isSmallScreen ? 10 : 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isAddingContact = false;
                      _nameController.clear();
                      _phoneController.clear();
                    });
                  },
                  child: const Text('Cancel'),
                ),
                SizedBox(width: isSmallScreen ? 5 : 10),
                ElevatedButton(
                  onPressed: _addEmergencyContact,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Contact'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelplineSection(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Crisis Helplines',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 10),
          _buildHelplineItem(
            'National Suicide Prevention Lifeline',
            '988',
            Icons.support_agent,
            isSmallScreen,
          ),
          Divider(height: isSmallScreen ? 18 : 24),
          _buildHelplineItem(
            'Crisis Text Line',
            'Text HOME to 741741',
            Icons.message,
            isSmallScreen,
          ),
          Divider(height: isSmallScreen ? 18 : 24),
          _buildHelplineItem(
            'Emergency Services',
            '911',
            Icons.emergency,
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildHelplineItem(String title, String contact, IconData icon, bool isSmallScreen) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.red, size: isSmallScreen ? 18 : 24),
        ),
        SizedBox(width: isSmallScreen ? 10 : 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              Text(
                contact,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
            ],
          ),
        ),
        if (title == 'National Suicide Prevention Lifeline' || title == 'Emergency Services')
          IconButton(
            icon: Icon(Icons.call, color: Colors.green, size: isSmallScreen ? 20 : 24),
            onPressed: () {
              _makeCall(contact == '988' ? '988' : '911');
            },
          ),
      ],
    );
  }
}