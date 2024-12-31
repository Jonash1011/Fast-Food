import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'FoodListPage.dart';
import 'InfoPage.dart';
import 'OrdersPage.dart';
import 'contactus.dart';
import 'CartDetailsPage.dart';
import 'Order.dart';
import 'main.dart';
import 'Profile.dart';
import 'signin.dart';

class DealsPage extends StatefulWidget {
  final String username;
  const DealsPage({Key? key, required this.username}) : super(key: key);

  @override
  _DealsPageState createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 1;
  List<Product> products = [];
  bool isLoading = true;
  bool isAdmin = false;
  int cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    isAdmin = widget.username == "#ADMIN==1";
    fetchDeals();
    fetchCartCount();
  }

  Future<void> _createDeal(Map<String, dynamic> foodItem, double discountedPrice) async {
    // Convert original price to double for comparison
    double originalPrice = double.parse(foodItem['price'].toString().replaceAll('₹', ''));

    // Check if discounted price is less than original price
    if (discountedPrice >= originalPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Discounted price must be less than original price'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://food-order-api-sreh.onrender.com/api/deals/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': foodItem['name'],
          'image_url': foodItem['image_url'],
          'original_price': originalPrice,
          'discounted_price': discountedPrice,
          'size': foodItem['size'],
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context);
        await fetchDeals();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Deal created successfully'),
              ],
            ),
            backgroundColor: Colors.purple,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        throw Exception('Failed to create deal');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Failed to create deal'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
// Add this function to fetch food items
  Future<List<Map<String, dynamic>>> _fetchFoodItems() async {
    try {
      final response = await http.get(
        Uri.parse('https://food-order-api-sreh.onrender.com/api/fooditems'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> items = json.decode(response.body);
        return List<Map<String, dynamic>>.from(items);
      } else {
        throw Exception('Failed to load food items');
      }
    } catch (e) {
      print('Error fetching food items: $e');
      return [];
    }
  }

// Add this function to show the create deal dialog
  Future<void> _showCreateDealDialog() async {
    final foodItems = await _fetchFoodItems();
    Map<String, dynamic>? selectedItem;
    final discountedPriceController = TextEditingController();

    if (!mounted) return;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.local_offer, color: Colors.purple),
                          SizedBox(width: 8),
                          Text(
                            'Create New Deal',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButtonFormField<Map<String, dynamic>>(
                                hint: Text('Select Food Item'),
                                value: selectedItem,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.add_task),
                                ),
                                items: foodItems.map((item) {
                                  return DropdownMenuItem<Map<String, dynamic>>(
                                    value: item,
                                    child: Text(
                                      '${item['name']} - ₹${item['price']}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedItem = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 16),
                            if (selectedItem != null) ...[
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.price_check, color: Colors.purple),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Original Price: ₹${selectedItem!['price']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                              TextField(
                                controller: discountedPriceController,
                                decoration: InputDecoration(
                                  labelText: 'Discounted Price',
                                  prefixText: '₹',
                                  prefixIcon: Icon(Icons.discount),
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: Icon(Icons.cancel, color: Colors.red),
                            label: Text('Cancel', style: TextStyle(color: Colors.red)),
                            onPressed: () => Navigator.pop(context),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: Icon(Icons.local_offer),
                            label: Text('Create Deal'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.purple,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                            onPressed: selectedItem == null ? null : () async {
                              if (discountedPriceController.text.isNotEmpty) {
                                await _createDeal(
                                  selectedItem!,
                                  double.parse(discountedPriceController.text),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }



  Future<void> fetchDeals() async {
    try {
      final response = await http.get(
        Uri.parse('https://food-order-api-sreh.onrender.com/api/deals'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> dealsJson = json.decode(response.body);
        print('Fetched deals: $dealsJson');

        setState(() {
          products = dealsJson.map((json) => Product.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        print('Failed to load deals: ${response.statusCode}');
        throw Exception('Failed to load deals');
      }
    } catch (e) {
      print('Error fetching deals: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addToCart(Product product) async {
    try {
      // First check if item exists in cart
      final checkResponse = await http.get(
        Uri.parse('https://food-order-api-sreh.onrender.com/api/cart/${widget.username}'),
      );

      final cartItems = json.decode(checkResponse.body) as List;
      bool itemExists = cartItems.any((item) => item['food_name'] == product.name);

      if (itemExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} is already in your cart'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('https://food-order-api-sreh.onrender.com/api/cart/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': widget.username,
          'food_name': product.name,
          'price': product.discountedPrice,
          'image_url': product.imageUrl,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 && responseData['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} added to cart successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        fetchCartCount();
      } else {
        throw Exception(responseData['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add ${product.name} to cart'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }


  Future<void> fetchCartCount() async {
    try {
      final response = await http.get(
        Uri.parse('https://food-order-api-sreh.onrender.com/api/cart/${widget.username}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> cartItems = json.decode(response.body);
        setState(() {
          cartItemCount = cartItems.length;
        });
      }
    } catch (e) {
      print('Error fetching cart count: $e');
    }
  }

  Future<void> _updateDeal(int id, double originalPrice, double discountedPrice, String size) async {
    try {
      final response = await http.put(
        Uri.parse('https://food-order-api-sreh.onrender.com/api/deals/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': id,
          'original_price': originalPrice,
          'discounted_price': discountedPrice,
          'size': size,
        }),
      );

      if (response.statusCode == 200) {
        await fetchDeals();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Deal updated successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        throw Exception('Failed to update deal');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Failed to update deal'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteDeal(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('https://food-order-api-sreh.onrender.com/api/deals/$id'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete deal');
      }
    } catch (e) {
      // Rethrow the error to be caught by the caller
      rethrow;
    }
  }
  Future<void> _showEditDealsDialog() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
      return AlertDialog(
          title: Row(
          children: [
          Icon(Icons.edit_note, color: Colors.blue),
    SizedBox(width: 8),
    Text('Edit Deals'),
    ],
    ),
    content: Container(
    width: double.maxFinite,
    child: SingleChildScrollView(
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: products.map((product) => Card(
    elevation: 2,
    margin: EdgeInsets.symmetric(vertical: 4),
    child: ListTile(
    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    leading: ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.network(
    product.imageUrl,
    width: 50,
    height: 50,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.image_not_supported, size: 50);
    },
    ),
    ),
    title: Text(
    product.name,
    style: TextStyle(fontWeight: FontWeight.bold),
    overflow: TextOverflow.ellipsis,
    ),
    subtitle: Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
    children: [
    Icon(Icons.local_offer, size: 16, color: Colors.green),
    SizedBox(width: 4),
    Text(
    '₹${product.discountedPrice}',
      style: TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    ),
    ],
    ),
    ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            constraints: BoxConstraints(),
            padding: EdgeInsets.zero,
            icon: Icon(Icons.edit, color: Colors.blue, size: 20),
            tooltip: 'Edit Deal',
            onPressed: () async {
              // Make edit function async if needed
              await _editDeal(product);
            },
          ),
          SizedBox(width: 8),
          IconButton(
            constraints: BoxConstraints(),
            padding: EdgeInsets.zero,
            icon: Icon(Icons.delete, color: Colors.red, size: 20),
            tooltip: 'Delete Deal',
            onPressed: () async {
              // Close the current dialog first
              Navigator.of(context).pop();

              // Show delete confirmation dialog
              await _showDeleteConfirmationDialog(product);
            },
          ),
        ],
      ),
    ),
    )).toList(),
    ),
    ),
    ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => Navigator.pop(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close),
                SizedBox(width: 8),
                Text('Close'),
              ],
            ),
          ),
        ],
      );
        },
    );
  }

// Separate method for delete confirmation dialog
  Future<void> _showDeleteConfirmationDialog(Product product) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Confirm Delete'),
          ],
        ),
        content: Text('Are you sure you want to delete ${product.name}?'),
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
            onPressed: () async {
              // Close the dialog first
              Navigator.pop(context);

              // Perform delete operation
              try {
                // Perform deletion
                await _deleteDeal(product.id);

                // Refresh deals list
                await fetchDeals();

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 10),
                        Text('Deal deleted successfully'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                // Show error message if deletion fails
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.white),
                        SizedBox(width: 10),
                        Text('Error deleting deal'),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
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


  Future<void> _editDeal(Product product) async {
    final originalPriceController = TextEditingController(text: product.originalPrice.toString());
    final discountedPriceController = TextEditingController(text: product.discountedPrice.toString());
    final sizeController = TextEditingController(text: product.size);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit_note, color: Colors.blue),
              SizedBox(width: 8),
              Text('Edit ${product.name}'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: originalPriceController,
                  decoration: InputDecoration(
                    labelText: 'Original Price',
                    prefixIcon: Icon(Icons.price_change),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: discountedPriceController,
                  decoration: InputDecoration(
                    labelText: 'Discounted Price',
                    prefixIcon: Icon(Icons.discount),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: sizeController,
                  decoration: InputDecoration(
                    labelText: 'Size',
                    prefixIcon: Icon(Icons.format_size),
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
              icon: Icon(Icons.save),
              label: Text('Save'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: () async {
                // Validation logic
                if (originalPriceController.text.trim().isEmpty ||
                    discountedPriceController.text.trim().isEmpty ||
                    sizeController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error, color: Colors.white),
                          SizedBox(width: 8),
                          Text('All fields are required'),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                // Parse prices
                double originalPrice;
                double discountedPrice;

                try {
                  originalPrice = double.parse(originalPriceController.text);
                  discountedPrice = double.parse(discountedPriceController.text);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Please enter valid prices'),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                // Validate discounted price
                if (discountedPrice >= originalPrice) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Discounted price must be less than original price'),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                // Update deal
                await _updateDeal(
                  product.id,
                  originalPrice,
                  discountedPrice,
                  sizeController.text.trim(),
                );

                // Close the dialog
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }


  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      shadowColor: Colors.blueGrey,
      child: InkWell(
        onTap: () {
          // Convert Product to the format expected by OrderPage
          Map<String, String> foodItem = {
            'name': product.name,
            'price': product.discountedPrice.toString(),
            'image': product.imageUrl,
            'size': product.size,
            'discount': product.discount,
            'original_price': product.originalPrice.toString(),
          };

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderPage(
                foodItem: foodItem,
                username: widget.username,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${product.size} - ₹${product.discountedPrice}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      '₹${product.originalPrice}',
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      product.discount,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  color: Colors.lightBlue,
                  onPressed: () => addToCart(product),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildDrawer(BuildContext context) {
    return Drawer(
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
          children: [
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
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
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
            _buildDrawerItem(
              icon: Icons.home,
              label: 'Home',
              iconColor: Colors.blue,
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodListPage(username: widget.username),
                ),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.receipt_long,
              label: 'Order',
              iconColor: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrdersPage(username: widget.username),
                ),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.local_offer,
              label: 'Deals',
              iconColor: Colors.orange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DealsPage(username: widget.username),
                ),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.shopping_cart,
              label: 'Cart',
              iconColor: Colors.red,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartDetailsPage(username: widget.username),
                ),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.phone,
              label: 'Contact Us',
              iconColor: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContactUsScreen(username: widget.username)),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.person,
              label: 'Profile',
              iconColor: Colors.greenAccent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(username: widget.username)),
              ),
            ),
            Divider(
              color: Colors.grey.withOpacity(0.3),
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            _buildDrawerItem(
              icon: Icons.logout,
              label: 'Logout',
              iconColor: Colors.grey,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = Colors.black, // Default color if none is provided
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(label, style: TextStyle(color: Colors.black)),
      onTap: onTap,
    );
  }





  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'Deals'),
        BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Info'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Orders'),
      ],
      onTap: (index) => _onBottomNavTap(index, context),
    );
  }

  void _onBottomNavTap(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FoodListPage(username: widget.username),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InfoPage(username: widget.username),
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrdersPage(username: widget.username),
          ),
        );
        break;
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('https://i.pinimg.com/736x/10/8b/ed/108bed3322b877f84aaba33e4950df5b.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        key: _scaffoldKey,
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
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    const Text(
                      'Special Offers',
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
                            onPressed: _showCreateDealDialog,
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white, size: 28),
                            onPressed: _showEditDealsDialog,
                          ),
                        ],
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 28),
                              onPressed: () => _navigateToCart(),
                            ),
                            if (cartItemCount > 0)
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
                                    cartItemCount.toString(),
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
        drawer: _buildDrawer(context),
        body: isLoading
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Loading Deals...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) => _buildProductCard(products[index]),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'Deals'),
            BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Info'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Orders'),
          ],
          onTap: (index) => _onBottomNavTap(index, context),
        ),
      ),
    );
  }


  Widget _buildCartIcon() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 28),
          onPressed: () => _navigateToCart(),
        ),
        if (cartItemCount > 0)
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
                cartItemCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            'Loading Deals...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) => _buildProductCard(products[index]),
      ),
    );
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartDetailsPage(username: widget.username),
      ),
    ).then((_) => fetchCartCount());
  }
}

class Product {
  final int id;
  final String imageUrl;
  final String name;
  final double originalPrice;
  final double discountedPrice;
  final String size;
  final String discount;

  Product({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.originalPrice,
    required this.discountedPrice,
    required this.size,
    required this.discount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.parse(json['id'].toString()),
      imageUrl: json['image_url'] ?? '',
      name: json['name'] ?? '',
      originalPrice: double.parse(json['original_price'].toString()),
      discountedPrice: double.parse(json['discounted_price'].toString()),
      size: json['size'] ?? '',
      discount: json['discount'] ?? '',
    );
  }
}

