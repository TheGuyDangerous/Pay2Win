class AppConstants {
  // App Information
  static const String appName = 'Pay2Win';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Save more, win more';
  
  // Routes
  static const String routeSplash = '/';
  static const String routeOnboarding = '/onboarding';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeForgotPassword = '/forgot-password';
  static const String routeHome = '/home';
  static const String routeProfile = '/profile';
  static const String routeCreateDuo = '/create-duo';
  static const String routeJoinDuo = '/join-duo';
  static const String routeDuoSelector = '/duo-selector';
  static const String routeDuoManagement = '/duo-management';
  static const String routeAddExpense = '/add-expense';
  static const String routeExpenseDetails = '/expense-details';
  static const String routeExpensesHistory = '/expenses-history';
  static const String routeMessages = '/messages';
  static const String routeReports = '/reports';
  static const String routeChallenges = '/challenges';
  static const String routeCreateChallenge = '/create-challenge';
  static const String routeChallengeDetails = '/challenge-details';
  static const String routeAchievements = '/achievements';
  static const String routeSettings = '/settings';
  
  // Shared Preferences Keys
  static const String prefKeyUser = 'user_id';
  static const String prefKeyTheme = 'is_dark_mode';
  static const String prefKeyDuo = 'duo_id';
  static const String prefKeyToken = 'token';
  static const String prefKeyOnboardingComplete = 'onboarding_complete';
  
  // Firebase Collections
  static const String collectionUsers = 'users';
  static const String collectionDuos = 'duos';
  static const String collectionExpenses = 'expenses';
  static const String collectionMessages = 'messages';
  static const String collectionChallenges = 'challenges';
  static const String collectionAchievements = 'achievements';
  
  // Default Values
  static const double defaultDailyBudget = 100.0;
  static const int duoCodeLength = 6;
  static const double defaultMonthlySalary = 0.0;
  static const List<String> defaultSavingGoals = [];
  
  // Expense Categories
  static const List<String> expenseCategories = [
    'Food',
    'Transportation',
    'Entertainment',
    'Shopping',
    'Utilities',
    'Housing',
    'Health',
    'Education',
    'Personal',
    'Other',
  ];
  
  // Time Periods
  static const List<String> timePeriods = [
    'Daily',
    'Weekly',
    'Monthly',
    'Trimester',
    'Yearly',
  ];
  
  // Challenge Types
  static const List<String> challengeTypes = [
    'Spend Less',
    'Save More',
    'No Spending',
    'Category Challenge',
    'Custom',
  ];
  
  // Achievement Types
  static const List<String> achievementTypes = [
    'Savings Milestone',
    'Streak',
    'Challenge Completion',
    'Budget Adherence',
    'App Usage',
  ];
  
  // Animation Durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 500);
  static const Duration animationDurationLong = Duration(milliseconds: 800);
  
  // API Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxDisplayNameLength = 30;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultIconSize = 24.0;
  static const double defaultButtonHeight = 48.0;
  
  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorAuth = 'Authentication failed. Please try again.';
  static const String errorPermission = 'You do not have permission to perform this action.';
} 