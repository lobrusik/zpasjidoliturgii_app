import 'package:flutter/material.dart';

class PremiumOfferDialog extends StatelessWidget {
  const PremiumOfferDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PremiumOfferDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF2D3039),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium, color: Colors.amber, size: 48),
            ),
            const SizedBox(height: 20),
            
            // Tytuł
            const Text(
              'Masz dość reklam?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Opis
            const Text(
              'Tworzymy tę aplikację z pasją, a reklamy pomagają nam pokryć koszty serwerów. Jeśli jednak chcesz poznawać liturgię, modlić się i słuchać w pełnym skupieniu, możesz je wyłączyć.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 24),

            // Cena
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF141F1C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tylko 5,00 zł ',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '/ miesiąc',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Buy button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  // HERE IN THE FUTURE, WE'LL INTEGRATE REVENUECAT (Google Play Payments)
                  Navigator.pop(context); // Close window
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funkcja płatności zostanie wkrótce podłączona!')),
                  );
                },
                child: const Text(
                  'Usuń reklamy',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // No, thanks button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Nie, dziękuję, zostaję przy darmowej wersji',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}