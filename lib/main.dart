import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:pay2win/core/constants/app_constants.dart';
import 'package:pay2win/core/theme/app_theme.dart';
import 'package:pay2win/core/theme/theme_provider.dart';
import 'package:pay2win/features/auth/screens/splash_screen.dart';
import 'package:pay2win/features/auth/screens/login_screen.dart';
import 'package:pay2win/features/auth/screens/register_screen.dart';
import 'package:pay2win/features/auth/screens/forgot_password_screen.dart';
import 'package:pay2win/features/auth/screens/onboarding_screen.dart';
import 'package:pay2win/features/dashboard/screens/home_screen.dart';
import 'package:pay2win/features/expense/screens/add_expense_screen.dart';
import 'package:pay2win/features/expense/screens/expense_details_screen.dart';
import 'package:pay2win/features/expense/screens/expenses_history_screen.dart';
import 'package:pay2win/features/duo/screens/duo_selector_screen.dart';
import 'package:pay2win/features/messaging/screens/messages_screen.dart';
import 'package:pay2win/features/challenges/screens/challenges_screen.dart';
import 'package:pay2win/features/challenges/screens/create_challenge_screen.dart';
import 'package:pay2win/features/challenges/screens/challenge_details_screen.dart';
import 'package:pay2win/features/reports/screens/reports_screen.dart';
import 'package:pay2win/features/settings/screens/settings_screen.dart';
import 'package:pay2win/features/auth/providers/auth_provider.dart';
import 'package:pay2win/features/dashboard/providers/dashboard_provider.dart';
import 'package:pay2win/features/expense/providers/expense_provider.dart';
import 'package:pay2win/features/duo/providers/duo_provider.dart';
import 'package:pay2win/features/messaging/providers/messaging_provider.dart';
import 'package:pay2win/features/challenges/providers/challenges_provider.dart';
import 'package:pay2win/features/reports/providers/reports_provider.dart';
import 'firebase_options.dart';
import 'package:pay2win/features/duo/screens/create_duo_screen.dart';
import 'package:pay2win/features/duo/screens/join_duo_screen.dart';
import 'package:pay2win/features/duo/screens/duo_management_screen.dart';

// Global variable to track Firebase initialization status
bool isFirebaseInitialized = false;
String? firebaseErrorMessage;

// Flag to use mock data if Firestore is unavailable
bool useMockData = false;

// Class to help reset all providers' state
class GlobalProviderResets {
  static void resetAllProviders(BuildContext context) {
    // Reset the DuoProvider by forcing it to re-initialize
    final duoProvider = Provider.of<DuoProvider>(context, listen: false);
    duoProvider.clearDuo();
    
    // Call specific reset methods or clear data as needed
    // These methods will be added to the respective providers
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize Firebase using the DefaultFirebaseOptions
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    isFirebaseInitialized = true;
  } catch (e) {
    isFirebaseInitialized = false;
    firebaseErrorMessage = e.toString();
    
    // Enable mock data when Firebase is unavailable
    useMockData = true;
    debugPrint('Mock data mode enabled for development');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => DuoProvider()),
        ChangeNotifierProvider(create: (_) => MessagingProvider()),
        ChangeNotifierProvider(create: (_) => ChallengesProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: AppConstants.routeSplash,
            routes: {
              AppConstants.routeSplash: (context) => const SplashScreen(),
              AppConstants.routeOnboarding: (context) => const OnboardingScreen(),
              AppConstants.routeLogin: (context) => const LoginScreen(),
              AppConstants.routeRegister: (context) => const RegisterScreen(),
              AppConstants.routeForgotPassword: (context) => const ForgotPasswordScreen(),
              AppConstants.routeHome: (context) => const HomeScreen(),
              AppConstants.routeAddExpense: (context) => const AddExpenseScreen(),
              AppConstants.routeExpenseDetails: (context) => const ExpenseDetailsScreen(),
              AppConstants.routeExpensesHistory: (context) => const ExpensesHistoryScreen(),
              AppConstants.routeDuoSelector: (context) => const DuoSelectorScreen(),
              AppConstants.routeCreateDuo: (context) => const CreateDuoScreen(),
              AppConstants.routeJoinDuo: (context) => const JoinDuoScreen(),
              AppConstants.routeDuoManagement: (context) => const DuoManagementScreen(),
              AppConstants.routeMessages: (context) => const MessagesScreen(),
              AppConstants.routeChallenges: (context) => const ChallengesScreen(),
              AppConstants.routeCreateChallenge: (context) => const CreateChallengeScreen(),
              AppConstants.routeChallengeDetails: (context) => const ChallengeDetailsScreen(),
              AppConstants.routeReports: (context) => const ReportsScreen(),
              AppConstants.routeSettings: (context) => const SettingsScreen(),
            },
            builder: (context, child) {
              return Stack(
                children: [
                  child!,
                  if (!isFirebaseInitialized)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.red,
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Firebase not initialized properly. Some features may not work.\n'
                          'Error: ${firebaseErrorMessage ?? "Unknown error"}',
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
