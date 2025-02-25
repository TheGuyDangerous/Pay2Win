import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Track Your Expenses',
      description: 'Keep track of your daily expenses and compare with your friend to see who spends less.',
      image: 'assets/images/onboarding_1.svg',
    ),
    OnboardingPage(
      title: 'Compete & Save',
      description: 'Challenge your friend to save more money. The one who saves more wins!',
      image: 'assets/images/onboarding_2.svg',
    ),
    OnboardingPage(
      title: 'Achieve Goals Together',
      description: 'Set financial goals and achieve them faster through friendly competition.',
      image: 'assets/images/onboarding_3.svg',
    ),
  ];
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.animationDurationMedium,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }
  
  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefKeyOnboardingComplete, true);
    
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppConstants.routeLogin);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // Pagination indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildDotIndicator(index),
                ),
              ),
            ),
            
            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 32,
              ),
              child: CustomButton(
                text: _currentPage == _pages.length - 1
                    ? 'Get Started'
                    : 'Next',
                onPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: SvgPicture.asset(
              page.image,
              fit: BoxFit.contain,
              width: 300,
              height: 300,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
              placeholderBuilder: (BuildContext context) {
                return Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.darkGrey.withOpacity(0.1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.image_not_supported,
                        color: AppColors.white,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      if (page.title == 'Track Your Expenses')
                        const Icon(Icons.track_changes, color: AppColors.white, size: 48),
                      if (page.title == 'Compete & Save')
                        const Icon(Icons.emoji_events, color: AppColors.white, size: 48),
                      if (page.title == 'Achieve Goals Together')
                        const Icon(Icons.flag, color: AppColors.white, size: 48),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              page.title,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Description
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Text(
              page.description,
              style: const TextStyle(
                color: AppColors.lightGrey,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDotIndicator(int index) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index
            ? AppColors.white
            : AppColors.darkGrey,
        border: Border.all(
          color: AppColors.white,
          width: 1,
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;
  
  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
  });
} 