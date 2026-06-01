import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/customer_card.dart';
import '../../routes/app_routes.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('AquaCollect', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      Provider.of<CustomerProvider>(context, listen: false).searchCustomers(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm tên, địa chỉ...',
                      prefixIcon: const Icon(Icons.search),
                      fillColor: Colors.grey[100],
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                InkWell(
                  onTap: () {
                    // Hiển thị BottomSheet để lọc
                    _showFilterSheet(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.withValues(alpha: 0.3))),
                    child: const Icon(Icons.tune, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Consumer<CustomerProvider>(
              builder: (context, provider, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('DANH SÁCH GIAO VIỆC (${provider.customers.length})', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
                    const Text('Hôm nay', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<CustomerProvider>(
              builder: (context, provider, child) {
                final list = provider.customers;
                if (list.isEmpty) {
                  return const Center(child: Text('Không tìm thấy khách hàng nào.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return CustomerCard(customer: list[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Lọc theo trạng thái', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _filterOption('Tất cả', Icons.all_inclusive, () {
                Provider.of<CustomerProvider>(context, listen: false).searchCustomers('');
                Navigator.pop(context);
              }),
              _filterOption('Chưa ghi số', Icons.pending_actions, () {
                // Giả lập lọc
                Navigator.pop(context);
              }),
              _filterOption('Đã hoàn thành', Icons.check_circle_outline, () {
                // Giả lập lọc
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _filterOption(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      onTap: onTap,
    );
  }


  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 1) Navigator.pushReplacementNamed(context, AppRoutes.home); // Placeholder for schedule
        if (index == 2) Navigator.pushReplacementNamed(context, AppRoutes.settings);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Khách hàng'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Lịch trình'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Cá nhân'),
      ],
    );
  }
}
