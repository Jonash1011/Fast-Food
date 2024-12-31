import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'deals_page.dart';
import 'InfoPage.dart';
import 'FoodListPage.dart';
import 'contactus.dart';
import 'CartDetailsPage.dart';
import 'Profile.dart';
import 'signin.dart';

class OrdersPage extends StatefulWidget {
  final String username;
  const OrdersPage({Key? key, required this.username}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 3;
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
  bool isAdmin = false;
  String selectedFilter = 'All';
  String? selectedUsername;
  List<String> filterOptions = ['All', 'Pending', 'Completed'];

  @override
  void initState() {
    super.initState();
    isAdmin = widget.username == '#ADMIN==1';
    fetchOrders();
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

  String formatOrderDateTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${hour}:$minute $amPm';
  }

  Widget buildFilterChips() {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filterOptions.length,
        itemBuilder: (context, index) {
          final filter = filterOptions[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              selected: selectedFilter == filter,
              label: Row(
                children: [
                  Icon(
                    filter == 'All' ? Icons.list :
                    filter == 'Pending' ? Icons.pending :
                    Icons.check_circle,
                    size: 18,
                    color: selectedFilter == filter ? Colors.white :
                    filter == 'Pending' ? Colors.orange :
                    filter == 'Completed' ? Colors.green :
                    Colors.grey,
                  ),
                  SizedBox(width: 4),
                  Text(filter),
                ],
              ),
              selectedColor: Colors.green,
              checkmarkColor: Colors.white,
              onSelected: (selected) {
                setState(() {
                  selectedFilter = filter;
                });
              },
            ),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> getFilteredOrders() {
    var baseOrders = isAdmin && selectedUsername != null
        ? orders.where((order) => order['username'] == selectedUsername).toList()
        : orders;

    if (selectedFilter == 'All') {
      return baseOrders;
    }
    return baseOrders.where((order) => order['status'] == selectedFilter).toList();
  }

  Future<void> fetchOrders() async {
    if (isAdmin) {
      await fetchAllOrders();
    } else {
      await fetchUserOrders();
    }
  }

  Future<void> fetchAllOrders() async {
    try {
      final response = await http.get(
        Uri.parse('https://food-order-api-sreh.onrender.com/api/orders'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> orderData = json.decode(response.body);
        setState(() {
          orders = orderData.map((order) => {
            'order_id': order['id'].toString(),
            'username': order['username'],
            'food_name': order['food_name'],
            'quantity': order['quantity'].toString(),
            'price': '₹${order['total_price'].toString()}',
            'contact_number': order['contact_number'],
            'address': order['address'],
            'image_url': order['image_url'],
            'order_time': order['order_time'],
            'status': order['status'] ?? 'Pending',
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Failed to load orders'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> fetchUserOrders() async {
    try {
      final response = await http.get(
        Uri.parse('https://food-order-api-sreh.onrender.com/api/orders/${widget.username}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> orderData = json.decode(response.body);
        setState(() {
          orders = orderData.map((order) => {
            'order_id': order['id'].toString(),
            'food_name': order['food_name'],
            'quantity': order['quantity'].toString(),
            'price': '₹${order['total_price'].toString()}',
            'contact_number': order['contact_number'],
            'address': order['address'],
            'image_url': order['image_url'],
            'order_time': order['order_time'],
            'status': order['status'] ?? 'Pending',
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Failed to load orders'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://food-order-api-sreh.onrender.com/api/orders/$orderId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          orders.removeWhere((order) => order['order_id'] == orderId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Order cancelled successfully'),
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
            children: const [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Failed to cancel order'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse('https://food-order-api-sreh.onrender.com/api/orders/$orderId/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': newStatus}),
      );
      if (response.statusCode == 200) {
        setState(() {
          final orderIndex = orders.indexWhere((order) => order['order_id'] == orderId);
          if (orderIndex != -1) {
            orders[orderIndex]['status'] = newStatus;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Order status updated to $newStatus'),
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
              Text('Failed to update status'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
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
      default:
        return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.lightGreen,
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
                  Text(
                    isAdmin ? 'All Orders' : 'My Orders',
                    style: const TextStyle(
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
      drawer: _buildDrawer(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Loading Orders...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    List<String> uniqueUsernames = isAdmin
        ? orders.map((order) => order['username'] as String).toSet().toList()
        : [];

    final filteredOrders = getFilteredOrders();

    return Column(
        children: [
        if (isAdmin)
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            hintText: 'Select User',
          ),
          value: selectedUsername,
          items: [
            DropdownMenuItem(
              value: null,
              child: Text('All Users'),
            ),
            ...uniqueUsernames.map((username) {
              return DropdownMenuItem(
                value: username,
                child: Text(username),
              );
            }).toList(),
          ],
          onChanged: (value) {
            setState(() {
              selectedUsername = value;
            });
          },
        ),
      ),
    ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAdmin
                      ? (selectedUsername != null
                      ? '$selectedUsername\'s Orders'
                      : 'All Orders')
                      : 'Your Orders',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12),
                buildFilterChips(),
                SizedBox(height: 8),
                Text(
                  '${filteredOrders.length} ${selectedFilter} Orders',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredOrders.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: Colors.white70,
                  ),
                  SizedBox(height: 16),
                  Text(
                    selectedUsername != null
                        ? 'No orders for $selectedUsername'
                        : 'No ${selectedFilter.toLowerCase()} orders found',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: filteredOrders.length,
              padding: EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4.0,
                  child: ExpansionTile(
                    leading: order['image_url'] != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        order['image_url'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.fastfood),
                      ),
                    )
                        : const Icon(Icons.fastfood),
                    title: Text(
                      order["food_name"]!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Status: ${order["status"]}",
                      style: TextStyle(
                        color: order["status"] == "Pending"
                            ? Colors.orange
                            : order["status"] == "Completed"
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isAdmin) Text("Customer: ${order["username"]}"),
                            Text("Order ID: ${order["order_id"]}"),
                            Text("Quantity: ${order["quantity"]}"),
                            Text("Total: ${order["price"]}"),
                            Text("Contact: ${order["contact_number"]}"),
                            Text("Address: ${order["address"]}"),
                            Text("Ordered on: ${formatOrderDateTime(order["order_time"])}"),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (isAdmin && order["status"] == "Pending")
                                  ElevatedButton.icon(
                                    onPressed: () => updateOrderStatus(order["order_id"], "Completed"),
                                    icon: Icon(Icons.check_circle_outline, color: Colors.white),
                                    label: Text(
                                        'Mark as Completed',
                                        style: TextStyle(color: Colors.white)
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                  ),

                                if (order["status"] == "Pending") ...[
                                  const SizedBox(width: 10),
                                  ElevatedButton.icon(
                                    onPressed: () => cancelOrder(order["order_id"]),
                                    icon: Icon(Icons.cancel_outlined, color: Colors.white),
                                    label: Text(
                                      'Cancel Order',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
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
    );
  }

  Widget _buildDrawer() {
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
                  const SizedBox(height: 10),
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blue),
              title: const Text('Home'),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.green),
              title: const Text('Orders'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.local_offer, color: Colors.orange),
              title: const Text('Deals'),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart, color: Colors.red),
              title: const Text('Cart'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartDetailsPage(username: widget.username)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.call, color: Colors.purple),
              title: const Text('Contact Us'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContactUsScreen(username: widget.username)),
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
    );
  }
}
