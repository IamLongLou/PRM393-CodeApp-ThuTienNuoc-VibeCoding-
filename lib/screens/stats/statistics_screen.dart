import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../routes/app_routes.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedCustomerId = 1; // Mặc định chọn khách hàng đầu tiên (ID: 1)
  
  // Dữ liệu giả lập biểu đồ cho từng khách hàng để minh họa logic thay đổi
  final Map<int, List<double>> _mockChartData = {
    1: [12.0, 15.0, 18.0, 14.0, 16.0, 14.5],
    2: [10.0, 12.0, 14.0, 13.0, 15.0, 13.5],
    3: [15.0, 18.0, 22.0, 19.0, 21.0, 20.0],
    4: [8.0, 9.0, 11.0, 10.0, 12.0, 10.5],
    5: [13.0, 16.0, 19.0, 17.0, 18.0, 17.5],
  };

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final String updateTime = DateFormat('HH:mm, dd/MM/yyyy').format(now);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Thống kê'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          final customers = provider.allCustomers;
          if (customers.isEmpty) return const Center(child: Text('Không có dữ liệu khách hàng.'));
          
          // Lấy thông tin khách hàng đang được chọn
          final selectedCustomer = customers.firstWhere((c) => c.id == _selectedCustomerId, orElse: () => customers.first);
          final chartData = _mockChartData[selectedCustomer.id] ?? [10, 10, 10, 10, 10, 10];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Khách hàng gần đây', style: TextStyle(fontWeight: FontWeight.bold)),
                      Icon(Icons.search, size: 18, color: Colors.grey),
                    ],
                  ),
                ),
                
                // 1. Danh sách Avatar lấy từ CustomerProvider
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: customers.length,
                    itemBuilder: (context, i) {
                      final customer = customers[i];
                      bool isSelected = _selectedCustomerId == customer.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCustomerId = customer.id!),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.blue : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${customer.id}'),
                                ),
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                width: 70,
                                child: Text(
                                  customer.name.split(' ').last, // Hiển thị tên (ví dụ: Long, Anh, Giang...)
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11, 
                                    color: isSelected ? Colors.blue : Colors.black, 
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tổng quan: ${selectedCustomer.name}', 
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                            ),
                            Text('Cập nhật lúc $updateTime', 
                              style: const TextStyle(color: Colors.grey, fontSize: 11)
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_outline, size: 12, color: Colors.grey),
                            SizedBox(width: 4),
                            Text('Đã đồng bộ', style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                // 2. Grid thông số thay đổi theo khách hàng được chọn
                _buildInfoGrid(selectedCustomer),
                
                // 3. Biểu đồ thay đổi theo khách hàng
                _buildChartSection(chartData),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text('Lịch sử ghi gần đây', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                _recentItem('${selectedCustomer.currentReading} m³', 'Hôm nay, 10:30', '120.000đ'),
                _recentItem('${(selectedCustomer.currentReading - 15)} m³', '15/09/2023', '144.000đ'),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildInfoGrid(dynamic customer) {
    // Logic tính toán giả lập dựa trên chỉ số hiện tại của khách hàng
    String totalCost = NumberFormat.currency(locale: 'vi_VN', symbol: '').format(customer.currentReading * 12000);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        children: [
          _statCard(Icons.water_drop_outlined, 'Tổng tiêu thụ', '${customer.currentReading}', 'M³'),
          _statCard(Icons.attach_money, 'Tổng chi phí', totalCost, 'VND'),
          _statCard(Icons.trending_up, 'Trung bình/tháng', '${(customer.currentReading / 12).toStringAsFixed(1)}', 'M³'),
          _statCard(Icons.calendar_today, 'Mã khách hàng', customer.code, ''),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String value, String unit) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.blue),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(5)),
                child: const Text('ĐÃ THANH TOÁN', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const Spacer(),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          Row(
            children: [
              Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(color: Colors.grey, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(List<double> chartPoints) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Xu hướng tiêu thụ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const Text('Tiêu thụ 6 tháng gần nhất (m³)', style: TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 5),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      getTitlesWidget: (v, m) => Text('${v.toInt()}', style: const TextStyle(fontSize: 8, color: Colors.grey)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, m) => Text('Th${v.toInt() + 5}', style: const TextStyle(fontSize: 8, color: Colors.grey)),
                    ),
                  ),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                ),
                borderData: FlBorderData(show: false),
                barGroups: chartPoints.asMap().entries.map((e) => BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value,
                      color: Colors.blue,
                      width: 15,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                    )
                  ],
                )).toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 3, backgroundColor: Colors.blue),
              SizedBox(width: 5),
              Text('Tiêu thụ (m³)', style: TextStyle(fontSize: 9, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _recentItem(String val, String date, String price) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.05), shape: BoxShape.circle),
          child: const Icon(Icons.water_drop, color: Colors.blue, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chỉ số: $val', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('Ngày ghi: $date', style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
              child: const Text('Tiền mặt', style: TextStyle(color: Colors.grey, fontSize: 9)),
            )
          ],
        )
      ],
    ),
  );

  Widget _buildBottomNav(BuildContext context) => BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    currentIndex: 1,
    selectedItemColor: Colors.blue,
    unselectedItemColor: Colors.grey,
    onTap: (index) {
      if (index == 0) Navigator.pushReplacementNamed(context, AppRoutes.home);
      if (index == 2) Navigator.pushReplacementNamed(context, AppRoutes.sync);
    },
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Payment'),
      BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
      BottomNavigationBarItem(icon: Icon(Icons.sync), label: 'Sync'),
    ],
  );
}
