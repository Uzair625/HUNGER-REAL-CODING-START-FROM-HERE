import 'package:flutter/material.dart';
import '../utils/colors.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Order History'), backgroundColor: Colors.white,
        leading: const BackButton(color: AppColors.textPrimary)),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('📦', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text('No orders yet', style: TextStyle(fontFamily:'Poppins', fontSize:18, fontWeight:FontWeight.w700, color:AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Your order history will appear here', style: TextStyle(fontFamily:'Poppins', fontSize:13, color:AppColors.textSecondary)),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Start Ordering'),
            ),
          ),
        ]),
      ),
    );
  }
}
