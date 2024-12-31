import 'package:flutter/material.dart';
import 'signin.dart'; // Make sure this is the correct path to your signin.dart file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TravelIllustrationPage(),
    );
  }
}

class TravelIllustrationPage extends StatefulWidget {
  @override
  _TravelIllustrationPageState createState() =>
      _TravelIllustrationPageState();
}

class _TravelIllustrationPageState extends State<TravelIllustrationPage> {
  bool _isLoading = false;

  void _navigateToLogin() async {
    setState(() {
      _isLoading = true; // Show the loading indicator
    });

    // Simulate a 1-second delay
    await Future.delayed(const Duration(seconds: 1));

    // Use pushReplacement to replace the current screen with the Signin screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          const Text(
            'Fast Food',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Image.network(
                'https://cdni.iconscout.com/illustration/premium/thumb/woman-buying-spice-at-shop-illustration-download-in-svg-png-gif-file-formats--buy-store-season-and-seasoning-pack-food-drink-illustrations-9472214.png', // Replace with your image URL
                width: 450,
                height: 350,
                fit: BoxFit.cover, // Optional: to make the image cover the container
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Note:We have only the cash on delivery plan only',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 250,
            height: 60,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null // Disable the button when loading
                  : _navigateToLogin,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: Color(0xFF007BFF), // Blue color
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                color: Colors.white,
              ) // Show loading spinner
                  : const Text(
                'Get start',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
