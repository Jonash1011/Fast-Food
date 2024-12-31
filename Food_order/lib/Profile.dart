import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'OrdersPage.dart';
import 'contactus.dart';
import 'signin.dart';

class ProfilePage extends StatefulWidget {
  final String username;

  const ProfilePage({Key? key, required this.username}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditMode = false;
  String _username = '';
  String _phoneNumber = '';

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _username = widget.username;
    _usernameController.text = _username;
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final response = await http.get(
          Uri.parse('https://food-order-api-sreh.onrender.com/api/users/$_username')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _phoneNumber = data['user']['mobile_number'] ?? '+1 (123) 456-7890';
          _phoneController.text = _phoneNumber;
        });
      }
    } catch (e) {
      _showNotification('Failed to load user details', isError: true);
    }
  }

  Future<void> _saveProfileChanges() async {
    // Validate phone number length
    if (_phoneController.text.length != 10) {
      _showNotification('Phone number must be 10 digits', isError: true);
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('https://food-order-api-sreh.onrender.com/api/users/$_username'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _username,
          'mobile_number': _phoneController.text,
        }),
      );

      if (response.statusCode == 200 && mounted) {
        setState(() {
          _phoneNumber = _phoneController.text;
          _isEditMode = false;
        });
        _showNotification('Profile updated successfully!', isError: false);
      } else {
        _showNotification('Failed to update profile', isError: true);
      }
    } catch (e) {
      _showNotification('Failed to update profile', isError: true);
    }
  }

  void _showNotification(String message, {required bool isError}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _navigateToOrderHistory() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OrdersPage(username: _username))
    );
  }

  void _navigateToContactUs() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ContactUsScreen(username: widget.username))
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: _buildCustomAppBar(context),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.greenAccent, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 20),
              _buildUserDetails(),
              const SizedBox(height: 20),
              _buildProfileOptions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.greenAccent.withOpacity(0.9), Colors.white.withOpacity(0.5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Profile',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.greenAccent.withOpacity(0.8), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.greenAccent.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.person,
            size: 80,
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _username,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
            shadows: [
              Shadow(
                color: Colors.white.withOpacity(0.5),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildUserDetails() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_outline, color: Colors.green.shade700),
                    SizedBox(width: 8),
                    const Text(
                      'User Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    _isEditMode ? Icons.save_rounded : Icons.edit_rounded,
                    color: Colors.green.shade700,
                  ),
                  onPressed: () {
                    setState(() {
                      _isEditMode = !_isEditMode;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            _isEditMode
                ? TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_android, color: Colors.green.shade700),
                hintText: '10 digit phone number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.green.shade700),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.green.shade700, width: 2),
                ),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            )
                : _buildDetailRow('Phone Number', _phoneNumber, Icons.phone_android),
            if (_isEditMode)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton.icon(
                  onPressed: _saveProfileChanges,
                  icon: Icon(Icons.save_rounded, color: Colors.white),
                  label: Text('Save Changes', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.shopping_bag_outlined, color: Colors.green.shade700),
            title: const Text('Order History'),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.green.shade700, size: 20),
            onTap: _navigateToOrderHistory,
          ),
          Divider(color: Colors.green.shade100),
          ListTile(
            leading: Icon(Icons.support_agent, color: Colors.green.shade700),
            title: const Text('Contact Us'),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.green.shade700, size: 20),
            onTap: _navigateToContactUs,
          ),
          Divider(color: Colors.green.shade100),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: Colors.red.shade400),
            title: Text('Logout', style: TextStyle(color: Colors.red.shade400)),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.red.shade400, size: 20),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green.shade700, size: 24),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
