import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

class CreateFaydaBillPage extends StatelessWidget {
  const CreateFaydaBillPage({super.key});

  static const String route = '/create-faydabill';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create FaydaBill'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Create FaydaBill – screen placeholder. Implement form and API integration here.',
            style: TextStyle(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
