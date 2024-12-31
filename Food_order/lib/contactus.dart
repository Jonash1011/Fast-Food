import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'FoodListPage.dart';

class ContactUsScreen extends StatefulWidget {
  final String username;

  const ContactUsScreen({Key? key, required this.username}) : super(key: key);

  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.9),
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
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Contact Us',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNameField(),
                _buildEmailField(),
                _buildPhoneField(),
                _buildCompanyField(),
                _buildSubjectField(),
                _buildMessageField(),
                const SizedBox(height: 20),
                _buildSubmitButton(),
                const SizedBox(height: 40),
                _buildContactDetails(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _nameController,
        enabled: false,
        decoration: InputDecoration(
          labelText: "Your Name",
          prefixIcon: Icon(Icons.person_outline, color: Colors.lightGreen),
          border: OutlineInputBorder(),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: "Your Email",
          prefixIcon: Icon(Icons.email_outlined, color: Colors.lightGreen),
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Email is required";
          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
          if (!emailRegex.hasMatch(value)) return "Enter a valid email address";
          return null;
        },
      ),
    );
  }

  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        maxLength: 10,
        decoration: InputDecoration(
          labelText: "Your Phone",
          prefixIcon: Icon(Icons.phone_outlined, color: Colors.lightGreen),
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Phone number is required";
          if (value.length != 10) return "Phone number must be 10 digits";
          if (!RegExp(r'^[0-9]+$').hasMatch(value)) return "Only numbers are allowed";
          return null;
        },
      ),
    );
  }

  Widget _buildCompanyField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _companyController,
        decoration: InputDecoration(
          labelText: "Your Company",
          prefixIcon: Icon(Icons.business_outlined, color: Colors.lightGreen),
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Company name is required";
          return null;
        },
      ),
    );
  }

  Widget _buildSubjectField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _subjectController,
        decoration: InputDecoration(
          labelText: "Subject",
          prefixIcon: Icon(Icons.subject_outlined, color: Colors.lightGreen),
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Subject is required";
          return null;
        },
      ),
    );
  }

  Widget _buildMessageField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _messageController,
        maxLines: 5,
        decoration: InputDecoration(
          labelText: "Your Message",
          prefixIcon: Icon(Icons.message_outlined, color: Colors.lightGreen),
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Message is required";
          return null;
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState?.validate() == true) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreen),
                    ),
                  );
                },
              );

              bool emailSent = await _sendEmail();
              Navigator.of(context).pop();

              if (emailSent) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Form Submitted Successfully"),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => FoodListPage(username: widget.username)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Failed to submit form. Please try again."),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text(
            "Submit",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<bool> _sendEmail() async {
    try {
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': 'service_eibrkv6',
          'template_id': 'template_4asplog',
          'user_id': '8GO_XIiYVgR47SraI',
          'template_params': {
            'user_name': _nameController.text,
            'user_email': _emailController.text,
            'user_phone': _phoneController.text,
            'user_company': _companyController.text,
            'user_subject': _subjectController.text,
            'user_message': _messageController.text,
          }
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }

  Widget _buildContactDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, color: Colors.lightGreen),
            SizedBox(width: 8),
            Text(
              "Our Address",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          "34/b Mathan Kovil South Street, Melakadayanallur, Kadayanallur, Tenkasi, Pincode-627751",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.phone, color: Colors.lightGreen),
            SizedBox(width: 8),
            Text(
              "Contact Numbers",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 8),
        _buildContactTile(
          icon: Icons.phone_android,
          text: "+91 7418088568",
          onTap: () => _launchPhoneDialer("+917418088568"),
        ),
        _buildContactTile(
          icon: FontAwesomeIcons.whatsapp,
          text: "+91 9942223401",
          onTap: () => _launchWhatsApp("+919942223401"),
        ),
      ],
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          InkWell(
            onTap: onTap,
            child: Row(
              children: [
                Icon(icon, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.copy, color: Colors.green),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text.replaceAll('+91 ', ''))).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Number copied to clipboard'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              });
            },
            tooltip: 'Copy number',
            padding: EdgeInsets.all(8),
            constraints: BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  void _launchPhoneDialer(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _launchWhatsApp(String phoneNumber) async {
    final Uri url = Uri.parse("https://wa.me/$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
