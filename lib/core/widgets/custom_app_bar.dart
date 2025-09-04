import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plastinder/features/auth/presentation/controllers/auth_controller.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    required this.secondary,
    required this.tertiary,
    required this.displayName,
    required this.context,
  });

  final Color secondary;
  final Color tertiary;
  final String displayName;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 45, 20, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [secondary, tertiary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: secondary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName.isEmpty
                          ? 'Hoş geldiniz!'
                          : 'Hoş geldiniz, $displayName',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox.shrink(),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<AuthController>().logout();
                },
                icon: Icon(Icons.logout, color: Colors.white.withOpacity(0.9)),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
