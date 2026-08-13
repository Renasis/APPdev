import 'package:flutter/material.dart';

import '../../orders/screens/orders_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Success'),
        automaticallyImplyLeading: false,
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),

              const SizedBox(height: 25),

              const Text(
                'Order Placed Successfully!',
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Thank you for your purchase.',
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: () {

                    Navigator.pushReplacement(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            const OrdersScreen(),
                      ),
                    );

                  },

                  child: const Text(
                    'View My Orders',
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,

                child: OutlinedButton(
                  onPressed: () {

                    Navigator.popUntil(
                      context,
                      (route) => route.isFirst,
                    );

                  },

                  child: const Text(
                    'Continue Shopping',
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}