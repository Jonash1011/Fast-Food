import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'FoodListPage.dart';
import 'deals_page.dart';
import 'OrdersPage.dart';
import 'CartDetailsPage.dart';
import 'main.dart';
import 'contactus.dart';
import 'Profile.dart';
import 'signin.dart';

class InfoPage extends StatefulWidget {
  final String username;
  const InfoPage({Key? key, required this.username}) : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 2;
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    try {
      final response = await http.get(
        Uri.parse('https://food-order-api-sreh.onrender.com/api/cart/${widget.username}'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          cartItems = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print('Error fetching cart items: $e');
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FoodListPage(username: widget.username),
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DealsPage(username: widget.username),
        ),
      );
    } else if (index == 2) {
      // Already on InfoPage, do nothing
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrdersPage(username: widget.username),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  const Text(
                    'Information',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 28),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CartDetailsPage(username: widget.username),
                            ),
                          ).then((_) => _fetchCartItems());
                        },
                      ),
                      if (cartItems.isNotEmpty)
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${cartItems.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.grey.shade50],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
              ),
            ],
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF2ECC71),  // A richer green
                      Color(0xFF27AE60),  // A deeper shade for depth
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Fast Food',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'Welcome, ${widget.username}😊',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.blue),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodListPage(username: widget.username),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long, color: Colors.green),
                title: const Text('Orders'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrdersPage(username: widget.username),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_offer, color: Colors.orange),
                title: const Text('Deals'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DealsPage(username: widget.username),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart, color: Colors.red),
                title: const Text('Cart'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartDetailsPage(username: widget.username),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.purple),
                title: const Text('Contact Us'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactUsScreen(username: widget.username),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.greenAccent),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(username: widget.username),
                    ),
                  );
                },
              ),
              Divider(
                color: Colors.grey.withOpacity(0.3),
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.grey),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                        (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text(
              'FAQ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: const [
                  FAQTile(
                    question: 'How can I Order the Product?',
                    answer: 'On the Home page, you can order food by selecting a category of your choice. And you can choice your quantity of the Product. It will then direct you to our Order page.',

                  ),
                  FAQTile(
                    question: 'Do you offer contactless delivery?',
                    answer: 'No, we not offer contactless delivery to ensure your safety and convenience. And your product will leave your order at your doorstep.',
                  ),
                  FAQTile(
                    question: 'Do you have a catalog?',
                    answer:
                    'Yes, you can find our full catalog in the Home section, showcasing all available items.',
                  ),
                  FAQTile(
                    question: 'What payment methods are supported?',
                    answer: 'We support only cash on delivery. Please ensure you have the exact amount ready for a smooth and hassle-free transaction.',

                  ),
                  FAQTile(
                    question: 'How can I contact support?',
                    answer:   "You can contact support via email at support@foodshop674@gmail.com or call +919942223401 alternatively number +917418088568. Our team is available 24/7 to assist you with any issues or inquiries you may have. Whether you need help with placing an order, tracking your delivery, or resolving any concerns, we are here to ensure your experience is seamless. Feel free to reach out anytime!"
                  ),
                  FAQTile(
                    question: 'Can I cancel my order after placing it?',
                    answer: 'Orders can only be canceled within a short time frame after being placed. If you need to make cancel, please contact our support team immediately via email or phone.',
                  ),
                  FAQTile(
                    question: 'Can I save my favorite orders for quick reordering?',
                    answer: 'Absolutely! You can save your favorite orders in the app for easy access and quick reordering. Simply tap the "Cart Icon" button next to your preferred Product.',
                  ),
                  FAQTile(question: 'Are there any discounts available?',
                      answer: 'We regularly offer discounts to our users. Be sure to check the "Deals" section in the app for the latest offers.'),

                  FAQTile(question:'Can I order from multiple product in one transaction?',
                    answer: 'Currently, our app allows you to order from one product per transaction. However, we are working on expanding this feature for future updates.'),
                  FAQTile(question: 'How do I leave Queries about my order?',
                      answer: 'We value your Queries! After receiving your order, you can leave a Queries and your experience directly through the "Contactus" page in the app . Your input helps us improve our service and food quality.',
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Deals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Orders',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class FAQTile extends StatelessWidget {
  final String question;
  final String answer;

  const FAQTile({Key? key, required this.question, required this.answer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
