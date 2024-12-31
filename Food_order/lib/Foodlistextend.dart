import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'CartDetailsPage.dart';
import 'Order.dart';

class FoodListExtended extends StatefulWidget {
  final String category;
  final String username;

  const FoodListExtended({
    Key? key,
    required this.category,
    required this.username,
  }) : super(key: key);

  @override
  _FoodListExtendedState createState() => _FoodListExtendedState();
}

class _FoodListExtendedState extends State<FoodListExtended> {
  List<Map<String, dynamic>> categoryItems = [];
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    isAdmin = widget.username == '#ADMIN==1';
    fetchCategoryItems();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
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
      showMessage('Error fetching cart items', Colors.red);
    }
  }
  Future<void> fetchCategoryItems() async {
    try {
      final response = await http.get(
        Uri.parse('https://food-order-api-sreh.onrender.com/api/foodvarieties/${widget.category}'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          categoryItems = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          showMessage('No ${widget.category} items found', Colors.orange);
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showMessage('Error fetching ${widget.category} items', Colors.red);
    }
  }

  Future<void> _addToCart(Map<String, dynamic> foodItem) async {
    if (cartItems.any((item) => item['food_name'] == foodItem['name'])) {
      showMessage('${foodItem["name"]} is already in your cart', Colors.orange);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://food-order-api-sreh.onrender.com/api/cart/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': widget.username,
          'food_name': foodItem['name'],
          'price': foodItem['price'].toString(),
          'image_url': foodItem['image_url']
        }),
      );
      if (response.statusCode == 201) {
        await fetchCartItems();
        showMessage('${foodItem["name"]} added to cart', Colors.green);
      }
    } catch (e) {
      showMessage('Error adding ${foodItem["name"]} to cart', Colors.red);
    }
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final imageUrlController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Add New ${widget.category} Item'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.add_task),
                ),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  prefixIcon: Icon(Icons.image),
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
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
              await _addNewVariety(
                nameController.text,
                double.parse(priceController.text),
                imageUrlController.text,
                descriptionController.text,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addNewVariety(String name, double price, String imageUrl, String description) async {
    // Validate all fields
    if (name.isEmpty || price <= 0 || imageUrl.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('All fields are mandatory'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final Uri apiUrl = Uri.parse('https://food-order-api-sreh.onrender.com/api/foodvarieties/create');

      final response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'category': widget.category,
          'name': name.trim(),
          'price': price,
          'image_url': imageUrl.trim(),
          'description': description.trim(),
        }),
      );

      if (response.statusCode == 201) {
        await fetchCategoryItems();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Item added successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning, color: Colors.white),
                SizedBox(width: 8),
                Text('Failed to add item. Please try again.'),
              ],
            ),
            backgroundColor: Colors.orange,
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
              Text('Error adding item. Please check your input and try again.'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }


// Helper function to validate price
  bool _isValidPrice(String price) {
    if (price.isEmpty) return false;
    try {
      double value = double.parse(price);
      return value > 0;
    } catch (e) {
      return false;
    }
  }

  void _displayStatusMessage(String message, Color color, {Icon? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              icon,
              SizedBox(width: 8),
            ],
            Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }


  void _showEditItemDialog(Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item['name']);
    final priceController = TextEditingController(text: item['price'].toString());
    final imageUrlController = TextEditingController(text: item['image_url']);
    final descriptionController = TextEditingController(text: item['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.blue),
            SizedBox(width: 8),
            Text('Edit ${item['name']}'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name*',
                  prefixIcon: Icon(Icons.add_task),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
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
                decoration: const InputDecoration(
                  labelText: 'Image URL*',
                  prefixIcon: Icon(Icons.image),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description*',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: 3,
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
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () {
              if (nameController.text.isEmpty ||
                  priceController.text.isEmpty ||
                  imageUrlController.text.isEmpty ||
                  descriptionController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Text('All fields are mandatory'),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              try {
                double price = double.parse(priceController.text);
                if (price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Price must be greater than 0'),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                _updateVariety(
                  item['id'],
                  nameController.text.trim(),
                  price,
                  imageUrlController.text.trim(),
                  descriptionController.text.trim(),
                );
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Please enter a valid price'),
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



  Future<void> _updateVariety(int id, String name, double price, String imageUrl, String description) async {
    try {
      final response = await http.put(
        Uri.parse('https://food-order-api-sreh.onrender.com/api/foodvarieties/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'price': price,
          'image_url': imageUrl,
          'description': description,
        }),
      );
      if (response.statusCode == 200) {
        await fetchCategoryItems();
        showMessage('${name} updated successfully', Colors.green);
      }
    } catch (e) {
      showMessage('Error updating item', Colors.red);
    }
  }


  void _showDeleteConfirmation(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete ${item['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
          ),
          ElevatedButton(
            onPressed: () async {
              await _deleteVariety(item['id'], item['name']);
              Navigator.pop(context);
            },
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
          ),
        ],
      ),
    );
  }


  Future<void> _deleteVariety(int id,String name) async {
    try {
      final response = await http.delete(
        Uri.parse('https://food-order-api-sreh.onrender.com/api/foodvarieties/$id'),
      );
      if (response.statusCode == 200) {
        await fetchCategoryItems();
        showMessage('${name} deleted successfully', Colors.green);
      }
    } catch (e) {
      showMessage('Error deleting item', Colors.red);
    }
  }

  void showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartDetailsPage(username: widget.username),
      ),
    ).then((_) => fetchCartItems());
  }

  void navigateToOrderPage(Map<String, dynamic> item) {
    Map<String, String> foodItem = {
      'name': item['name'],
      'price': '₹${item['price']}',
      'image': item['image_url'],
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
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Text(
                    '${widget.category} Varieties',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  Row(
                    children: [
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 28),
                            onPressed: navigateToCart,
                          ),
                          if (cartItems.isNotEmpty)
                            Positioned(
                              right: 0,
                              top: 0,
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
                      if (isAdmin)
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white, size: 28),
                          onPressed: _showAddItemDialog,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : categoryItems.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'No ${widget.category} items available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Check back later for updates',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              if (isAdmin) ...[
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _showAddItemDialog,
                  icon: Icon(Icons.add),
                  label: Text('Add ${widget.category} Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    foregroundColor: Colors.white, // Set the text color to white
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],

            ],
          ),
        )
            : ListView.builder(
          itemCount: categoryItems.length,
          itemBuilder: (context, index) {
            final item = categoryItems[index];
            return GestureDetector(
              onTap: () => navigateToOrderPage(item),
              child: Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                elevation: 3.0,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8.0),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      item['image_url'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    item['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${item['price']}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item['description'] != null)
                        Text(
                          item['description'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  trailing: SizedBox(
                    width: isAdmin ? 160 : 100,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart),
                          color: Colors.blue,
                          onPressed: () => _addToCart(item),
                        ),
                        if (isAdmin) ...[
                          IconButton(
                            icon: const Icon(Icons.edit),
                            color: Colors.green,
                            onPressed: () => _showEditItemDialog(item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () => _showDeleteConfirmation(item),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: cartItems.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: navigateToCart,
        label: Text(
          'View Cart (${cartItems.length})',
          style: const TextStyle(color: Colors.white), // White text color
        ),
        icon: const Icon(
          Icons.shopping_cart_checkout,
          color: Colors.white, // White icon color
        ),
        backgroundColor: Colors.lightGreen,
      )
          : null,
    );
  }
}
