import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'FoodListPage.dart';
import 'SignUp.dart';
import 'Forgotpass.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _handleLogin(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String username = _userNameController.text;
      String password = _passwordController.text;

      try {
        final response = await http.post(
          Uri.parse('https://food-order-api-sreh.onrender.com/api/login'),
          body: jsonEncode({
            'username': username,
            'password': password,
          }),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message']),
              backgroundColor: Colors.green, // Green color for success
              duration: Duration(seconds: 3),
            ),
          );
          await Future.delayed(Duration(seconds: 3));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodListPage(username: username),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Login failed. Please try again.'),
              backgroundColor: Colors.red, // Red color for errors
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: ${e.toString()}'),
            backgroundColor: Colors.red, // Red color for network errors
            duration: Duration(seconds: 3),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://img.freepik.com/free-vector/green-curve-abstract-background_53876-99571.jpg?w=360'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24),
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: _buildWelcomeText(),
                    ),
                    SizedBox(height: 30),
                    _buildUsernameField(),
                    SizedBox(height: 20),
                    _buildPasswordField(),
                    SizedBox(height: 15),
                    _buildForgotPasswordLink(),
                    SizedBox(height: 30),
                    _buildSignInButton(),
                    SizedBox(height: 25),
                    _buildSignUpLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        'Welcome',
        textAlign: TextAlign.center,
        style: GoogleFonts.akayaKanadaka(
          textStyle: TextStyle(
            color: Colors.black,
            fontSize: 46,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 15,
                color: Colors.black.withOpacity(0.3),
                offset: Offset(4, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _userNameController,
      keyboardType: TextInputType.text,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@#\$_\-=]')),
        LengthLimitingTextInputFormatter(20),
      ],
      decoration: _buildInputDecoration(
        hintText: 'User Name',
        icon: Icons.person,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'User name is required';
        }
        if (!RegExp(r'[a-zA-Z0-9@#\$_\-=]').hasMatch(value)) {
          return 'Please enter valid username';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      inputFormatters: [
        LengthLimitingTextInputFormatter(6),
      ],
      decoration: _buildInputDecoration(
        hintText: 'Password',
        icon: Icons.lock,
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        if (value.length < 6) {
          return 'Password length is up to 6';
        }
        return null;
      },
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade600),
      prefixIcon: Icon(icon, color: Colors.grey),
      suffixIcon: suffixIcon,
      border: _buildOutlineInputBorder(),
      enabledBorder: _buildOutlineInputBorder(),
      focusedBorder: _buildOutlineInputBorder(color: Color(0xFF2196F3)),
      errorBorder: _buildOutlineInputBorder(color: Colors.red.shade400),
      focusedErrorBorder: _buildOutlineInputBorder(color: Colors.red.shade400),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }

  OutlineInputBorder _buildOutlineInputBorder({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(
        color: color ?? Colors.grey.shade300,
        width: 2,
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(),
            ),
          );
        },
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Container(
      height: 60, // Consistent height
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _handleLogin(context),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
        ),
        child: Center(
          child: _isLoading
              ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          )
              : Text(
            'SIGN IN',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildSignUpLink() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignupScreen(),
            ),
          );
        },
        child: RichText(
          text: TextSpan(
            text: "Don't have an account?  ",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
            children: [
              TextSpan(
                text: 'Sign Up',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
