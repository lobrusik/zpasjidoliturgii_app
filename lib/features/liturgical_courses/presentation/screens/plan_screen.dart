import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  bool _didLessonToday(Timestamp? lastCompletion) {
    if (lastCompletion == null) return false;
    
    final lastDate = lastCompletion.toDate();
    final now = DateTime.now();
    
    return lastDate.year == now.year &&
           lastDate.month == now.month &&
           lastDate.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text('Musisz być zalogowana, aby widzieć plan.'));
    }

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('daily_plans')
            .orderBy('dayNumber') // Sortujemy dni od 1 do 7
            .snapshots(),
        builder: (context, plansSnapshot) {
          if (plansSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final plans = plansSnapshot.data?.docs ?? [];

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final userData = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
              
              final int currentPlanDay = userData['currentPlanDay'] ?? 1;
              final Timestamp? lastCompletion = userData['lastPlanCompletionDate'];
              
              final bool doneToday = _didLessonToday(lastCompletion);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NAGŁÓWEK
                    Row(
                      children: [
                        const Text('📅', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Codziennie z liturgią',
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Zobacz – Zrozum – Sprawdź się – Zastosuj.\nJeden temat dziennie. Zbuduj nawyk!',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 32),

                    if (doneToday)
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withOpacity(0.15),
                          border: Border.all(color: const Color(0xFF2E7D32)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Świetna robota!', style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF4CAF50), fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('Wykonałeś dzisiejszy plan. Wróć tu jutro, aby odkryć kolejny dzień.', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (plans.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            'Brak wgranych planów w bazie danych.',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                      )
                    else
                      ...List.generate(plans.length, (index) {
                        final planDoc = plans[index];
                        final planData = planDoc.data() as Map<String, dynamic>;
                        
                        final int dayNumber = planData['dayNumber'] ?? (index + 1);
                        final String title = planData['title'] ?? 'Dzień $dayNumber';
                        
                        final bool isCompleted = dayNumber < currentPlanDay;
                        final bool isCurrentDay = dayNumber == currentPlanDay;
                        
                        bool isLocked = false;
                        String lockMessage = '';

                        if (isCompleted) {
                          isLocked = false;
                        } else if (isCurrentDay) {
                          if (doneToday) {
                            isLocked = true;
                            lockMessage = 'Wróć jutro, aby odblokować!';
                          } else {
                            isLocked = false;
                          }
                        } else {
                          isLocked = true;
                          lockMessage = 'Zablokowane. Ukończ poprzednie dni.';
                        }

                        return _buildDayCard(
                          context: context,
                          planId: planDoc.id,
                          dayNumber: dayNumber,
                          title: title,
                          isCompleted: isCompleted,
                          isCurrentDay: isCurrentDay,
                          isLocked: isLocked,
                          lockMessage: lockMessage,
                          doneToday: doneToday,
                        );
                      }),
                      
                      const SizedBox(height: 48),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDayCard({
    required BuildContext context,
    required String planId,
    required int dayNumber,
    required String title,
    required bool isCompleted,
    required bool isCurrentDay,
    required bool isLocked,
    required String lockMessage,
    required bool doneToday,
  }) {
    final theme = Theme.of(context);
    
    Color borderColor = const Color(0xFF2D3039);
    Widget trailingIcon = const Icon(Icons.lock, color: Colors.grey, size: 20);
    
    if (isCompleted) {
      trailingIcon = const Icon(Icons.check, color: Color(0xFF4CAF50));
    } else if (isCurrentDay && !doneToday) {
      borderColor = theme.colorScheme.primary.withOpacity(0.5);
      trailingIcon = Icon(Icons.play_circle_fill, color: theme.colorScheme.primary, size: 28);
    } else if (isCurrentDay && doneToday) {
      trailingIcon = const Icon(Icons.timelapse, color: Colors.orange, size: 24);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF22242B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: (isCurrentDay && !doneToday) ? 1.5 : 1.0,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isCompleted 
                ? const Color(0xFF4CAF50).withOpacity(0.1) 
                : (isCurrentDay && !doneToday) 
                    ? theme.colorScheme.primary.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'DZIEŃ\n$dayNumber',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isCompleted 
                    ? const Color(0xFF4CAF50) 
                    : (isCurrentDay && !doneToday) 
                        ? theme.colorScheme.primary 
                        : Colors.grey,
              ),
            ),
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isLocked ? Colors.grey.shade600 : Colors.white,
            fontWeight: (isCurrentDay && !doneToday) ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: isLocked 
            ? Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(lockMessage, style: TextStyle(color: Colors.redAccent.shade100, fontSize: 12)),
              )
            : null,
        trailing: trailingIcon,
        onTap: () {
          if (isLocked) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lockMessage)));
          } else {
            context.push(
              '/plan/details/$planId', 
              extra: {
                'title': title,
                'isCompleted': isCompleted,
              },
            );
          }
        },
      ),
    );
  }
}