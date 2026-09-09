import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/monetization/presentation/widgets/premium_offer_dialog.dart';

class MainWrapper extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapper({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/logo.png', height: 32, fit: BoxFit.contain),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        actions: [
          // Premium offer (temporary)
          IconButton(
            icon: const Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
            onPressed: () {
              PremiumOfferDialog.show(context);
            },
          ),

          IconButton(
            icon: const CircleAvatar(
              radius: 16,
              child: Icon(Icons.person, size: 20),
            ),
            onPressed: () => context.push('/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: navigationShell,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: navigationShell.currentIndex,
            onTap: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Start'),
              BottomNavigationBarItem(icon: Icon(Icons.account_tree_outlined), label: 'Ścieżka'),
              BottomNavigationBarItem(icon: Icon(Icons.nightlight_outlined), label: 'Kompleta'),
              BottomNavigationBarItem(icon: Icon(Icons.headset_mic_outlined), label: 'Podcast'),
            ],
            selectedItemColor: theme.colorScheme.primary,
            unselectedItemColor: Colors.grey,
            backgroundColor: theme.colorScheme.surface,
          ),
        ],
      ),
    );
  }
}