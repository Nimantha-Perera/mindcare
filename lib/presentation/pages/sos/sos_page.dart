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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_nameController.text} added to emergency contacts')),
      );
    }
  }

  void _sendSOSMessage() async {
    if (_emergencyContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add emergency contacts first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final String message = 
        "🆘 EMERGENCY: I need help right now. This is an automated SOS message from my MindCare app. Please contact me immediately.";
    
    try {
      await Share.share(message, subject: 'EMERGENCY SOS ALERT');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SOS message sent successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending SOS: $e'),
            backgroundColor: Colors.red,
          ),
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
          child: isLandscape 
              ? _buildLandscapeLayout(screenWidth, screenHeight) 
              : _buildPortraitLayout(screenWidth, screenHeight),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(double screenWidth, double screenHeight) {
    // Calculate responsive dimensions
    final sosButtonSize = screenWidth < 400 ? screenWidth * 0.4 : 180.0;
    final innerButtonSize = sosButtonSize * 0.9;

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
          child: _buildContactsContainer(screenWidth),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(double screenWidth, double screenHeight) {
    // Landscape-specific responsive values
    final sosButtonSize = screenHeight * 0.35;
    final innerButtonSize = sosButtonSize * 0.9;

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
          child: _buildContactsContainer(screenWidth),
        ),
      ],
    );
  }

  Widget _buildContactsContainer(double screenWidth) {
    final bool isSmallScreen = screenWidth < 360;
    final double fontSize = isSmallScreen ? 16.0 : 18.0;

    return Container(
      width: double.infinity,
      height: double.infinity, // Use all available space
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
        mainAxisSize: MainAxisSize.min, // Important: don't take more space than needed
        children: [
          // Header row - fixed at top
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _isAddingContact = true;
                  });
                },
                tooltip: 'Add Emergency Contact',
              ),
            ],
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          // Scrollable content area
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add contact form (if showing)
                  if (_isAddingContact) ...[
                    _buildAddContactForm(isSmallScreen),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                  ],
                  
                  // Emergency contacts list
                  if (_emergencyContacts.isNotEmpty) ...[
                    Text(
                      'Your Contacts',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    ...List.generate(
                      _emergencyContacts.length,
                      (index) {
                        final contact = _emergencyContacts[index];
                        final parts = contact.split(': ');
                        final name = parts[0];
                        final phone = parts.length > 1 ? parts[1] : '';
                        
                        return Dismissible(
                          key: Key(contact),
                          background: Container(
                            margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.red),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            setState(() {
                              _emergencyContacts.removeAt(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$name removed from contacts')),
                            );
                          },
                          child: _buildContactCard(name, phone, isSmallScreen),
                        );
                      },
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),
                  ],
                  
                  // Empty state message
                  if (_emergencyContacts.isEmpty && !_isAddingContact)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 20 : 32,
                        horizontal: isSmallScreen ? 16 : 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.person_add_outlined,
                            size: isSmallScreen ? 48 : 64,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 12),
                          Text(
                            'No emergency contacts added yet',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 4 : 8),
                          Text(
                            'Tap the + button above to add trusted contacts',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  if (_emergencyContacts.isEmpty && !_isAddingContact)
                    SizedBox(height: isSmallScreen ? 16 : 24),
                  
                  // Crisis helplines section
                  _buildHelplineSection(isSmallScreen),
                  
                  // Bottom padding for scroll
                  SizedBox(height: isSmallScreen ? 16 : 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(String name, String phone, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _makeCall(phone.replaceAll('-', '')),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16, 
              vertical: isSmallScreen ? 12 : 16
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person, 
                    color: Colors.red.shade400, 
                    size: isSmallScreen ? 18 : 24
                  ),
                ),
                SizedBox(width: isSmallScreen ? 10 : 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        phone,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.call, 
                      color: Colors.green.shade600, 
                      size: isSmallScreen ? 20 : 24
                    ),
                    onPressed: () => _makeCall(phone.replaceAll('-', '')),
                    tooltip: 'Call $name',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddContactForm(bool isSmallScreen) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Emergency Contact',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Enter contact name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person_outline),
                contentPadding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 10 : 14, 
                  horizontal: 12
                ),
                isDense: isSmallScreen,
              ),
              textInputAction: TextInputAction.next,
            ),
            
            SizedBox(height: isSmallScreen ? 10 : 12),
            
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter phone number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.phone_outlined),
                contentPadding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 10 : 14, 
                  horizontal: 12
                ),
                isDense: isSmallScreen,
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _addEmergencyContact(),
            ),
            
            SizedBox(height: isSmallScreen ? 12 : 16),
            
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
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
                
                SizedBox(width: isSmallScreen ? 8 : 12),
                
                ElevatedButton(
                  onPressed: _addEmergencyContact,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Emergency Helplines - Sri Lanka',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          // Mental Health Helpline - Most important for this app
          _buildHelplineItem(
            'National Mental Health Helpline',
            '1926',
            Icons.psychology,
            isSmallScreen,
            isCallable: true,
          ),
          _buildDivider(isSmallScreen),
          
          // Police Emergency
          _buildHelplineItem(
            'Police Emergency',
            '118 / 119',
            Icons.local_police,
            isSmallScreen,
            isCallable: true,
            alternateNumber: '119',
          ),
          _buildDivider(isSmallScreen),
          
          // Ambulance & Fire
          _buildHelplineItem(
            'Ambulance / Fire & Rescue',
            '110',
            Icons.emergency,
            isSmallScreen,
            isCallable: true,
          ),
          _buildDivider(isSmallScreen),
          
          // General Hospital Colombo
          _buildHelplineItem(
            'General Hospital Colombo',
            '011-2691111',
            Icons.local_hospital,
            isSmallScreen,
            isCallable: true,
          ),
          _buildDivider(isSmallScreen),
          
          // Tourist Police
          _buildHelplineItem(
            'Tourist Police',
            '011-2421052',
            Icons.support_agent,
            isSmallScreen,
            isCallable: true,
          ),
          _buildDivider(isSmallScreen),
          
          // Government Information Center
          _buildHelplineItem(
            'Government Information Center',
            '1919',
            Icons.info,
            isSmallScreen,
            isCallable: true,
          ),
          _buildDivider(isSmallScreen),
          
          // Report Crimes
          _buildHelplineItem(
            'Report Crimes',
            '011-2691500',
            Icons.report_problem,
            isSmallScreen,
            isCallable: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 12),
      child: Divider(
        color: Colors.red.shade200,
        thickness: 1,
        height: 1,
      ),
    );
  }

  Widget _buildHelplineItem(
    String title, 
    String contact, 
    IconData icon, 
    bool isSmallScreen, {
    bool isCallable = false,
    String? alternateNumber,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4 : 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.red, size: isSmallScreen ? 18 : 22),
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
                    fontSize: isSmallScreen ? 13 : 15,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                SizedBox(height: 2),
                Text(
                  contact,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isCallable) ...[
            SizedBox(width: isSmallScreen ? 4 : 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.call, 
                      color: Colors.green.shade600, 
                      size: isSmallScreen ? 18 : 22
                    ),
                    onPressed: () {
                      String numberToCall = contact.contains('/') 
                          ? contact.split('/')[0].trim() 
                          : contact;
                      _makeCall(numberToCall.replaceAll('-', ''));
                    },
                    tooltip: 'Call $contact',
                    constraints: BoxConstraints(
                      minWidth: isSmallScreen ? 36 : 40,
                      minHeight: isSmallScreen ? 36 : 40,
                    ),
                    padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                  ),
                ),
                if (alternateNumber != null) ...[
                  SizedBox(width: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.call, 
                        color: Colors.blue.shade600, 
                        size: isSmallScreen ? 18 : 22
                      ),
                      onPressed: () {
                        _makeCall(alternateNumber.replaceAll('-', ''));
                      },
                      tooltip: 'Call $alternateNumber',
                      constraints: BoxConstraints(
                        minWidth: isSmallScreen ? 36 : 40,
                        minHeight: isSmallScreen ? 36 : 40,
                      ),
                      padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}