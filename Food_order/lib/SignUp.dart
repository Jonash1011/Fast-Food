import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_order/main.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'dart:convert'; // For JSON encoding
import 'signin.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isLoading = false;
  bool isPasswordVisible = false; // For toggling password visibility
  bool isConfirmPasswordVisible = false; // For toggling confirm password visibility
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repasswordController = TextEditingController();

  // Function to send signup data to the backend API
  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      // Gather user inputs
      String username = usernameController.text;
      String mobileNumber = mobileController.text;
      String password = passwordController.text;

      try {
        // Send data to backend API
        final response = await http.post(
          Uri.parse('https://food-order-api-sreh.onrender.com/api/signup'),
          body: json.encode({
            'username': username,
            'mobile_number': mobileNumber,
            'password': password,
          }),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: Colors.green, // Green color for success
              duration: Duration(seconds: 3),
            ),
          );

          // Add 3-second delay before navigating
          await Future.delayed(const Duration(seconds: 3));
          Navigator.pop(context); // Navigate back or to another screen
        } else if (response.statusCode == 409) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Username or mobile number already exists!'),
              backgroundColor: Colors.red, // Red color for errors
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create account. Please try again.'),
              backgroundColor: Colors.red, // Red color for errors
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red, // Red color for network errors
            duration: Duration(seconds: 3),
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://i.pinimg.com/736x/75/dc/73/75dc73fe07158e160d047bc84f4c1672.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Foreground content with transparency
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8), // Semi-transparent white
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10.0,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: usernameController,
                            hintText: 'User Name',
                            icon: Icons.person,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                              LengthLimitingTextInputFormatter(20),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          CustomTextField(
                            controller: mobileController,
                            hintText: 'Mobile Number',
                            icon: Icons.call,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Mobile number is required';
                              }
                              if (value.length != 10) {
                                return 'Mobile number must be 10 digits';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          CustomTextField(
                            controller: passwordController,
                            hintText: 'Password',
                            icon: Icons.lock,
                            isPassword: true,
                            isPasswordVisible: isPasswordVisible,
                            onTogglePassword: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(6),
                              FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9!@#$%^&*(),.?":{}|<>]*$')),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 6) {
                                return 'Password must be 6 characters long';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          CustomTextField(
                            controller: repasswordController,
                            hintText: 'Confirm password',
                            icon: Icons.lock,
                            isPassword: true,
                            isPasswordVisible: isConfirmPasswordVisible,
                            onTogglePassword: () {
                              setState(() {
                                isConfirmPasswordVisible = !isConfirmPasswordVisible;
                              });
                            },
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(6),
                              FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9!@#$%^&*(),.?":{}|<>]*$')),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirm password is required';
                              }
                              if (value != passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 25),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLoading ? Colors.grey : Colors.blue.shade400,
                              shadowColor: Colors.blue.shade800,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                            ),
                            onPressed: isLoading ? null : _handleSignup,
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              'SIGN UP',
                              style: TextStyle(fontSize: 16.0, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoginScreen()),
                              );
                            },
                            child: RichText(
                              text: const TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: 'Sign In',
                                    style: TextStyle(
                                      color: Colors.lightBlueAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final bool? isPasswordVisible;
  final VoidCallback? onTogglePassword;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;

  const CustomTextField({
    Key? key,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.isPasswordVisible,
    this.onTogglePassword,
    this.inputFormatters,
    this.validator,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !(isPasswordVisible ?? false),
      style: const TextStyle(color: Colors.black),
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            (isPasswordVisible ?? false) ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: onTogglePassword,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
    );
  }
}
