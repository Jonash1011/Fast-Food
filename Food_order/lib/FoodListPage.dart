import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'Order.dart';
import 'OrdersPage.dart';
import 'InfoPage.dart';
import 'deals_page.dart';
import 'main.dart';
import 'CartDetailsPage.dart';
import 'contactus.dart';
import 'Foodlistextend.dart';
import 'Profile.dart';
import 'signin.dart';

class FoodListPage extends StatefulWidget {
  final String username;

  const FoodListPage({Key? key, required this.username}) : super(key: key);

  @override
  _FoodListPageState createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  int _selectedIndex = 0;
  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, String>> foodItems1 = [];
  bool _isLoading = true;
  String _errorMessage = "";
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    isAdmin = widget.username == '#ADMIN==1';
    _fetchFoodItems();
    _fetchCartItems();
  }

  void _showAddFoodDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final imageUrlController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Add New Food Item'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Food Name*',
                  prefixIcon: Icon(Icons.add_task),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Price*',
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                controller: imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL*',
                  prefixIcon: Icon(Icons.image),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description*',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(
                  labelText: 'Category*',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.cancel, color: Colors.red),
            label: Text('Cancel', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text('Add'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () async {
              try {
                final response = await http.post(
                  Uri.parse('https://food-order-api-sreh.onrender.com/api/fooditems'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode({
                    'name': nameController.text,
                    'price': double.parse(priceController.text),
                    'image_url': imageUrlController.text,
                    'description': descriptionController.text,
                    'category': categoryController.text,
                  }),
                );
                if (response.statusCode == 201) {
                  Navigator.pop(context);
                  _fetchFoodItems();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Food item added successfully'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Error adding food item: $e'),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }



  void _showEditFoodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.blue),
            SizedBox(width: 8),
            Text('Edit Food Items', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: foodItems1.length,
            itemBuilder: (context, index) {
              final item = foodItems1[index];
              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['image'] ?? '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.add_task, size: 50, color: Colors.grey),
                    ),
                  ),
                  title: Text(
                    item['name']!,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '₹${item['price']}',
                    style: TextStyle(color: Colors.green),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Edit Item',
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditItemDialog(item);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete Item',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Confirm Delete'),
                              content: Text('Are you sure you want to delete ${item['name']}?'),
                              actions: [
                                TextButton(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.close, color: Colors.red),
                                      SizedBox(width: 4),
                                      Text(
                                          'Cancel',
                                          style: TextStyle(color: Colors.red)
                                      ),
                                    ],
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.delete, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.white)
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteFood(item['id']!);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          ElevatedButton.icon(
            icon: Icon(Icons.close),
            label: Text('Close'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }



  void _showEditItemDialog(Map<String, String> item) {
    final nameController = TextEditingController(text: item['name']);
    final priceController = TextEditingController(text: item['price']?.replaceAll('\u20b9', ''));
    final imageUrlController = TextEditingController(text: item['image']);
    final descriptionController = TextEditingController(text: item['description']);
    final categoryController = TextEditingController(text: item['category']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.blue),
            SizedBox(width: 8),
            Text('Edit Food Item'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Food Name*',
                  prefixIcon: Icon(Icons.add_task),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Price*',
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                controller: imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL*',
                  prefixIcon: Icon(Icons.image),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description*',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(
                  labelText: 'Category*',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.cancel, color: Colors.red),
            label: Text('Cancel', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.update),
            label: Text('Update'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () async {
              try {
                print('Updating item with ID: ${item['id']}');
                final response = await http.put(
                  Uri.parse('https://food-order-api-sreh.onrender.com/api/fooditems/${item['id']}'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode({
                    'name': nameController.text,
                    'price': double.parse(priceController.text),
                    'image_url': imageUrlController.text,
                    'description': descriptionController.text,
                    'category': categoryController.text,
                  }),
                );
                if (response.statusCode == 200) {
                  Navigator.pop(context);
                  await _fetchFoodItems();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Food item updated successfully'),
                        ],
                      ),
                      backgroundColor: Colors.blue,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  print('Update failed with status: ${response.statusCode}');
                  print('Response body: ${response.body}');
                }
              } catch (e) {
                print('Error updating food item: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Error updating food item: $e'),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }



  Future<void> _deleteFood(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('https://food-order-api-sreh.onrender.com/api/fooditems/$id'),
      );
      if (response.statusCode == 200) {
        await _fetchFoodItems(); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Food item deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting food item')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting food item: $e')),
      );
    }
  }

// Rest of the code remains the same

  Future<void> _fetchFoodItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final response = await http
          .get(Uri.parse('https://food-order-api-sreh.onrender.com/api/fooditems'))
          .timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        List<dynamic> fetchedItems = json.decode(response.body);
        setState(() {
          foodItems1 = fetchedItems.map((item) {
            return {
              "id": (item['id'] ?? '').toString(),
              "name": (item['name'] ?? 'Unknown').toString(),
              "price": "\u20b9${(item['price'] ?? '0').toString()}",
              "image": (item['image_url'] ?? '').toString(),
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load food items. Status: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error: ${e.toString()}";
      });
      print('Error fetching food items: $e');
    }
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

  Future<void> _addToCart(Map<String, String> foodItem) async {
    // First check if item already exists in cart
    bool itemExists = cartItems.any((item) =>
    item['food_name'] == foodItem['name']
    );

    if (itemExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${foodItem["name"]} is already in your cart'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://food-order-api-sreh.onrender.com/api/cart/add'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': widget.username,
          'food_name': foodItem['name'],
          'price': foodItem['price']?.replaceAll('\u20b9', ''),
          'image_url': foodItem['image']
        }),
      );

      if (response.statusCode == 201) {
        await _fetchCartItems(); // Refresh cart items
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${foodItem["name"]} added to cart'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add item to cart'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = foodItems1.where((foodItem) {
      return foodItem['name']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: Colors.white,
            elevation: 8,
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Exit App',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Are you want to exit?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            actionsPadding: EdgeInsets.symmetric(horizontal: 79, vertical: 8),
            actionsAlignment: MainAxisAlignment.start, // Align buttons to the left
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'No',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Yes',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        );
        if (shouldExit ?? false) {
          SystemNavigator.pop();
        }
        return false;
      },

      child: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
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
                      icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                    const Text(
                      'Fast Food',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    Row(
                      children: [
                        if (isAdmin) ...[
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.white, size: 28),
                            onPressed: _showAddFoodDialog,
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white, size: 28),
                            onPressed: _showEditFoodDialog,
                          ),
                        ],
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
                        Color(0xFF2ECC71),
                        Color(0xFF27AE60),
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
                    Navigator.push(
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage(username: widget.username)),
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
                          (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://i.pinimg.com/736x/10/8b/ed/108bed3322b877f84aaba33e4950df5b.jpg',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 70),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search for food...',
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              Image.network(
                'https://img.freepik.com/premium-photo/premium-rice-great-quality-design-concept-vector_1029476-123565.jpg?w=996',
                height: 220.0,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Shop by Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _buildFoodList(filteredItems),
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
          onTap: _handleNavigation,
        ),
      ),
    );
  }






  Widget _buildFoodList(List<Map<String, String>> items) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final foodItem = items[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodListExtended(
                    category: foodItem["name"]!,
                    username: widget.username,
                  ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 5.0),
              elevation: 3.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                height: 100,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        bottomLeft: Radius.circular(10.0),
                      ),
                      child: Image.network(
                        foodItem["image"]!,
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100.0,
                            height: 100.0,
                            color: Colors.grey[200],
                            child: Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              foodItem["name"]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  void _handleNavigation(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DealsPage(username: widget.username),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InfoPage(username: widget.username),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrdersPage(username: widget.username),
          ),
        );
        break;
      default:
        setState(() {
          _selectedIndex = index;
        });
    }
  }
}