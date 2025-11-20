import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../screens/add_transaction_screen.dart';

class FloatingAddButton extends StatelessWidget {
  const FloatingAddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddTransactionScreen(),
          ),
        );
      },
      backgroundColor: AppColors.primary,
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }
}

