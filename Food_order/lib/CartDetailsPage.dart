import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'FoodListPage.dart';
import 'InfoPage.dart';
import 'deals_page.dart';
import 'OrdersPage.dart';
import 'Order.dart';

class CartDetailsPage extends StatefulWidget {
  final String username;
  const CartDetailsPage({Key? key, required this.username}) : super(key: key);

  @override
  _CartDetailsPageState createState() => _CartDetailsPageState();
}

class _CartDetailsPageState extends State<CartDetailsPage> {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
  double totalAmount = 0;
  bool isCheckoutInProgress = false;
  String contactNumber = '';
  String deliveryAddress = '';

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    if (!mounted) return;

    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://food-order-api-sreh.onrender.com/api/cart/${widget.username}'),
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          cartItems = List<Map<String, dynamic>>.from(data);
          calculateTotal();
        });
      } else {
        String errorMessage = 'Failed to fetch cart items.';
        if (response.statusCode == 404) {
          errorMessage = 'Cart not found for user ${widget.username}.';
        } else if (response.statusCode == 500) {
          errorMessage = 'Server error occurred while fetching cart items.';
        }
        if (mounted) showError(errorMessage);
      }
    } catch (e) {
      if (mounted) showError('An error occurred while fetching cart items: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void calculateTotal() {
    totalAmount = cartItems.fold(
      0.0,
          (sum, item) {
        final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
        final quantity = item['quantity'] ?? 1;
        return sum + (price * quantity);
      },
    );
  }

  void navigateToOrderPage(Map<String, dynamic> item) {
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderPage(
          foodItem: {
            'name': item['food_name'] ?? '',
            'price': '₹${item['price'] ?? 0}',
            'image': item['image_url'] ?? '',
          },
          username: widget.username,
        ),
      ),
    );
  }

  Future<void> removeFromCart(int itemId, String itemName) async {
    try {
      final response = await http.delete(
        Uri.parse('https://food-order-api-sreh.onrender.com/api/cart/remove/$itemId'),
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        await fetchCartItems();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('$itemName removed from cart'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Failed to remove $itemName'),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Error removing $itemName'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<Map<String, String>?> _showCheckoutDialog() async {
    if (!mounted) return null;

    final contactController = TextEditingController();
    final addressController = TextEditingController();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.local_shipping, color: Colors.green),
            SizedBox(width: 10),
            Text('Delivery Details'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contactController,
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  prefixIcon: Icon(Icons.phone, color: Colors.green),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                maxLength: 10,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Delivery Address',
                  prefixIcon: Icon(Icons.location_on, color: Colors.green),
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
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
            icon: Icon(Icons.check_circle, color: Colors.white),
            label: Text('Confirm', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (contactController.text.length == 10 &&
                  addressController.text.isNotEmpty) {
                Navigator.pop(context, {
                  'contact': contactController.text,
                  'address': addressController.text,
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Please fill all details correctly'),
                      ],
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> checkout() async {
    if (cartItems.isEmpty || !mounted) return;

    setState(() => isCheckoutInProgress = true);
    try {
      for (var item in cartItems) {
        if (!mounted) return;

        final orderResponse = await http.post(
          Uri.parse('https://food-order-api-sreh.onrender.com/api/orders'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'username': widget.username,
            'food_name': item['food_name'] ?? '',
            'quantity': item['quantity'] ?? 1,
            'contact_number': contactNumber,
            'address': deliveryAddress,
            'total_price': (double.tryParse(item['price']?.toString() ?? '0') ?? 0.0) * (item['quantity'] ?? 1),
            'image_url': item['image_url'] ?? '',
          }),
        );

        if (!mounted) return;

        if (orderResponse.statusCode != 201) {
          throw Exception('Failed to place order for ${item['food_name']}');
        }
      }

      final clearCartResponse = await http.delete(
        Uri.parse('https://food-order-api-sreh.onrender.com/api/cart/clear/${widget.username}'),
      );

      if (!mounted) return;

      if (clearCartResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Orders placed successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          cartItems.clear();
          totalAmount = 0;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrdersPage(username: widget.username),
          ),
        );
      } else {
        throw Exception('Failed to clear cart');
      }
    } catch (e) {
      if (mounted) showError('Error during checkout: ${e.toString()}');
    } finally {
      if (mounted) setState(() => isCheckoutInProgress = false);
    }
  }

  void showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showRemoveItemDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 10),
            Text('Remove Item'),
          ],
        ),
        content: Text('Are you sure you want to remove ${item['food_name']} from your cart?'),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.close, color: Colors.red),
            label: Text('Cancel', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.delete, color: Colors.white),
            label: Text('Remove', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              removeFromCart(item['id'], item['food_name']);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
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
                    'Cart Details',
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
                        onPressed: null,
                      ),
                      if (cartItems.isNotEmpty)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${cartItems.length}',
                              style: TextStyle(
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
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Loading Cart Items...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          : cartItems.isEmpty
          ? _buildEmptyCart()
          : _buildCartList(),
      bottomNavigationBar: cartItems.isEmpty ? _buildBottomNav() : _buildCheckoutBar(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.white),
        const SizedBox(height: 16),
        const Text(
          'Your cart is empty',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
        onPressed: () => Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FoodListPage(username: widget.username),
      ),
    ),
    icon: Icon(Icons.shopping_bag_outlined, color: Colors.black),
    label: Text('Continue Shopping', style: TextStyle(color: Colors.
    black)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
            ],
        ),
    );
  }

  Widget _buildCartList() {
    return ListView.builder(
      itemCount: cartItems.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final item = cartItems[index];
        int quantity = item['quantity'] ?? 1;

        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['image_url'] ?? '',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.fastfood, size: 40, color: Colors.grey);
                },
              ),
            ),
            title: Text(
              item['food_name'] ?? '',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${item['price'] ?? 0}',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() {
                            quantity--;
                            item['quantity'] = quantity;
                            calculateTotal();
                          });
                        } else {
                          _showRemoveItemDialog(item);
                        }
                      },
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$quantity',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.green),
                      onPressed: () {
                        if (quantity < 99) {
                          setState(() {
                            quantity++;
                            item['quantity'] = quantity;
                            calculateTotal();
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.warning, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text('Maximum quantity limit is 99'),
                                ],
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showRemoveItemDialog(item),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                '₹${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: isCheckoutInProgress ? null : () async {
              bool? confirmCheckout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.shopping_cart_checkout, color: Colors.green),
                      SizedBox(width: 10),
                      Text('Confirm Order'),
                    ],
                  ),
                  content: Text('Are you sure you want to place this order?'),
                  actions: [
                    TextButton.icon(
                      icon: Icon(Icons.close, color: Colors.red),
                      label: Text('Cancel', style: TextStyle(color: Colors.red)),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.check_circle, color: Colors.white),
                      label: Text('Confirm', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              );

              if (confirmCheckout == true) {
                final details = await _showCheckoutDialog();
                if (details != null) {
                  setState(() {
                    contactNumber = details['contact']!;
                    deliveryAddress = details['address']!;
                  });
                  checkout();
                }
              }
            },
            icon: Icon(
              isCheckoutInProgress ? Icons.hourglass_empty : Icons.shopping_cart_checkout,
              color: Colors.white,
            ),
            label: Text(
              isCheckoutInProgress ? 'Processing...' : 'Place Order',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              disabledBackgroundColor: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      onTap: (index) {
        Widget page;
        switch (index) {
          case 0:
            page = FoodListPage(username: widget.username);
            break;
          case 1:
            page = DealsPage(username: widget.username);
            break;
          case 2:
            page = InfoPage(username: widget.username);
            break;
          case 3:
            page = OrdersPage(username: widget.username);
            break;
          default:
            page = FoodListPage(username: widget.username);
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      items: const [
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
    );
  }
}
