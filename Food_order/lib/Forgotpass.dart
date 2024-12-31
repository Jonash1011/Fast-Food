import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Newpass.dart';

class ApiConstants {
  static const String baseUrl = 'https://food-order-api-sreh.onrender.com';
}

class OTPVerificationScreen extends StatefulWidget {
  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isEmailFieldEnabled = true;
  bool _isSendButtonEnabled = true;
  bool _isOTPFieldEnabled = false;
  bool _isVerifyOTPButtonEnabled = true;
  List<Widget> _dynamicFields = [];

  Future<void> sendOTP() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _isSendButtonEnabled = false;
      });

      try {
        final response = await http.post(
          Uri.parse('${ApiConstants.baseUrl}/api/send-otp'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': _emailController.text}),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data['success'] == true) {
          setState(() {
            _isEmailFieldEnabled = false;
            _isOTPFieldEnabled = true;
            _dynamicFields = [
              TextFormField(
                controller: _otpController,
                enabled: _isOTPFieldEnabled,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 6,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isVerifyOTPButtonEnabled ? verifyOTP : null,
                child: Text('Verify OTP'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                ),
              ),
            ];
          });

          _showMessage(data['message'], true);
        } else {
          _showMessage(data['message'] ?? 'Failed to send OTP', false);
          setState(() {
            _isSendButtonEnabled = true;
          });
        }
      } catch (e) {
        print('Error sending OTP: $e');
        _showMessage('Network error. Please try again.', false);
        setState(() {
          _isSendButtonEnabled = true;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> verifyOTP() async {
    setState(() {
      _isLoading = true;
      _isVerifyOTPButtonEnabled = false;
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'otp': _otpController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NewPasswordScreen()),
        );
      } else {
        _showMessage(data['message'] ?? 'Invalid OTP', false);
        setState(() {
          _isVerifyOTPButtonEnabled = true;
        });
      }
    } catch (e) {
      _showMessage('Verification failed. Please try again.', false);
      setState(() {
        _isVerifyOTPButtonEnabled = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://i.pinimg.com/736x/23/4a/8a/234a8a28e5f5a69d68475cc1d24559da.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 120.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'OTP Verification',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
                      Text(
                        'Please enter your email address. You will receive an OTP via email.',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(height: 30),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _emailController,
                              enabled: _isEmailFieldEnabled,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter an email address';
                                }
                                String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                                if (!RegExp(pattern).hasMatch(value!)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: _isLoading ? null : () {
                                    setState(() {
                                      _isEmailFieldEnabled = true;
                                      _isSendButtonEnabled = true;
                                      _dynamicFields.clear();
                                      _isOTPFieldEnabled = false;
                                      _isVerifyOTPButtonEnabled = true;
                                    });
                                  },
                                  child: Text('Resend', style: TextStyle(color: Colors.blue)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: (_isLoading || !_isSendButtonEnabled) ? null : sendOTP,
                              child: Text('Send'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Column(children: _dynamicFields),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}