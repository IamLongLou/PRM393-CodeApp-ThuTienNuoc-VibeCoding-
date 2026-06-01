import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/billing_provider.dart';
import '../../providers/customer_provider.dart';
import '../customer/receipt_screen.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử thu tiền', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<BillingProvider>(
        builder: (context, provider, child) {
          return FutureBuilder(
            future: provider.getAllBills(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              final bills = snapshot.data!;
              if (bills.isEmpty) return const Center(child: Text('Chưa có lịch sử thu tiền nào.'));

              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: bills.length,
                itemBuilder: (context, index) {
                  final bill = bills[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                    ),
                    child: InkWell(
                      onTap: () {
                        final customer = Provider.of<CustomerProvider>(context, listen: false)
                            .allCustomers
                            .firstWhere((c) => c.id == bill.customerId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReceiptScreen(customer: customer, bill: bill),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.blue.withValues(alpha: 0.1),
                              child: const Icon(Icons.receipt_long, color: Colors.blue),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(bill.billCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 2),
                                  Text(bill.customerName ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
                                  Text('Mã KH: ${bill.customerCode ?? 'N/A'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text(DateFormat('dd/MM/yyyy HH:mm').format(bill.date), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(currencyFormat.format(bill.totalAmount), 
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 15)
                                ),
                                Text('${bill.consumption.toInt()} m³', 
                                  style: const TextStyle(fontSize: 12, color: Colors.grey)
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
