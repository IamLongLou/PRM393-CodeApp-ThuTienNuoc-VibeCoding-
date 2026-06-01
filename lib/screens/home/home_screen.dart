import 'package:flutter/material.dart';
import '../customer/customer_list_screen.dart';
import '../profile/profile_screen.dart';
import '../sync/sync_screen.dart';
import '../history/history_screen.dart';

/// Màn hình chính dành cho nhân viên đi thu/ghi chỉ số, tích hợp các chức năng cũ
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Danh sách các màn hình tương ứng với các tab (Giữ nguyên các chức năng cũ)
    final List<Widget> pages = [
      _buildDashboardTab(), // Tổng quan công việc
      const CustomerListScreen(), // Chức năng Ghi số cũ
      const HistoryScreen(), // Chức năng Lịch sử cũ
      const ProfileScreen(), // Chức năng Cá nhân cũ
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      // Giới hạn chiều rộng trên web để giao diện không bị dãn quá mức
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: "Tổng quan",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: "Ghi số"),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            label: "Lịch sử",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Cá nhân",
          ),
        ],
      ),
      floatingActionButton: Navigator.canPop(context)
          ? FloatingActionButton(
              mini: true,
              onPressed: () => Navigator.pop(context),
              tooltip: 'Quay lại',
              child: const Icon(Icons.arrow_back),
            )
          : null,
    );
  }

  /// Tab Tổng quan: Hiển thị tiến độ công việc và các phím tắt chức năng
  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header: Thông tin nhân viên
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              left: 20,
              right: 20,
              bottom: 25,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 35),
                ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nhân viên thu hộ",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      "NGUYỄN VĂN A",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Card Thống kê tiến độ
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.assignment_turned_in, color: Colors.blue),
                      SizedBox(width: 10),
                      Text(
                        "Tiến độ công việc hôm nay",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem("150", "Tổng hộ", Colors.black),
                      _buildStatItem("45", "Đã ghi", Colors.green),
                      _buildStatItem("105", "Còn lại", Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: 45 / 150,
                    backgroundColor: Colors.grey[200],
                    color: Colors.green,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),
          ),

          // Lưới chức năng (Kết nối với các chức năng cũ)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.5,
              children: [
                _buildActionCard(
                  Icons.qr_code_scanner,
                  "Quét mã QR",
                  Colors.blue,
                  () {
                    // Giả lập quét QR và chuyển đến danh sách
                    setState(() => _selectedIndex = 1);
                  },
                ),
                _buildActionCard(Icons.sync, "Đồng bộ data", Colors.orange, () {
                  // Chuyển hướng đến màn hình Đồng bộ cũ
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SyncScreen()),
                  );
                }),
                _buildActionCard(
                  Icons.history,
                  "Tra cứu lịch sử",
                  Colors.green,
                  () {
                    // Chuyển sang tab Lịch sử
                    setState(() => _selectedIndex = 2);
                  },
                ),
                _buildActionCard(
                  Icons.warning_amber_rounded,
                  "Sự cố/Vi phạm",
                  Colors.red,
                  () {},
                ),
              ],
            ),
          ),

          // Thông báo
          const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Thông báo mới",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 10),
                ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.blue),
                  title: Text("Cập nhật danh sách hộ mới khu vực Quận 1"),
                  subtitle: Text("2 giờ trước"),
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildActionCard(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
