import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kalorimu/core/constants/app_colors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  final List<Map<String, String>> _slides = [
    {
      'label': 'AI-POWERED PRECISION',
      'title': 'Dine with Intelligence',
      'description': 'Transform every meal into a step toward your wellness goals with AI-powered nutrition tracking.',
      'image': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=600&auto=format&fit=crop', // Salad
    },
    {
      'label': 'SMART ANALYSIS',
      'title': 'Precision Meets Simplicity',
      'description': 'Point your camera at any meal for an instant nutritional breakdown with surgical precision.',
      'image': 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?q=80&w=600&auto=format&fit=crop', // Food & Phone
    },
    {
      'label': 'PERSONAL GROWTH',
      'title': 'Insights for a Better You',
      'description': 'Understand your habits through elegant visualizations that highlight your progress over time.',
      'image': 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?q=80&w=600&auto=format&fit=crop', // Walking/Wellness
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Sticky Header
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: AppColors.primaryContainer.withValues(alpha: 0.5), // Golden stroke
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/logo.png', width: 28, height: 28, fit: BoxFit.contain),
                    const SizedBox(width: 8),
                    Text(
                      'KALORIMU',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4.0, // 0.2em
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (isDesktop) ...[
                  Row(
                    children: [
                      _buildHeaderLink('Our Method'),
                      const SizedBox(width: 32),
                      _buildHeaderLink('Wellness'),
                    ],
                  ),
                ],
                Icon(Icons.account_circle_outlined, color: AppColors.primary, size: 28),
              ],
            ),
          ),

          // Main Content Area (Carousel + Buttons)
          SliverToBoxAdapter(
            child: SizedBox(
              height: size.height - kToolbarHeight,
              child: Stack(
                children: [
                  // Background Accents
                  Positioned(
                    top: size.height * 0.2,
                    left: -100,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      // Simulate blur with backdrop filter or just rely on low opacity
                    ),
                  ),

                  Column(
                    children: [
                      // Carousel
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _slides.length,
                          itemBuilder: (context, index) {
                            final slide = _slides[index];
                            return _buildSlide(slide, isDesktop);
                          },
                        ),
                      ),
                      
                      // Indicators
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: _slides.length,
                          effect: ExpandingDotsEffect(
                            activeDotColor: AppColors.primaryContainer,
                            dotColor: AppColors.primaryContainer.withValues(alpha: 0.3),
                            dotHeight: 6,
                            dotWidth: 6,
                            expansionFactor: 4,
                          ),
                        ),
                      ),

                      // Fixed Action Buttons
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                        child: isDesktop
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildGetStartedButton(context),
                                  const SizedBox(width: 16),
                                  _buildLoginButton(context),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildGetStartedButton(context),
                                  const SizedBox(height: 16),
                                  _buildLoginButton(context),
                                ],
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Features Section
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.backgroundCardLight,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              child: Column(
                children: [
                  // Section Header
                  Column(
                    children: [
                      Text(
                        'PRECISION MEETS SIMPLICITY',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 4.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(width: 96, height: 1, color: AppColors.primaryContainer),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Feature Cards
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildFeatureCard(Icons.auto_awesome, 'Instant Scanning', 'Point your camera at any meal for an instant nutritional breakdown with surgical precision.', false)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildFeatureCard(Icons.insights, 'Deep Insights', 'Understand your habits through elegant visualizations that highlight your progress over time.', true)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildFeatureCard(Icons.restaurant, 'Curated Menus', 'Receive personalized meal suggestions that align with your taste profile and health targets.', false)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildFeatureCard(Icons.auto_awesome, 'Instant Scanning', 'Point your camera at any meal for an instant nutritional breakdown with surgical precision.', false),
                        const SizedBox(height: 16),
                        _buildFeatureCard(Icons.insights, 'Deep Insights', 'Understand your habits through elegant visualizations that highlight your progress over time.', true),
                        const SizedBox(height: 16),
                        _buildFeatureCard(Icons.restaurant, 'Curated Menus', 'Receive personalized meal suggestions that align with your taste profile and health targets.', false),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Footer
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.primaryContainer.withValues(alpha: 0.1))),
              ),
              child: isDesktop
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFooterBrand(),
                        _buildFooterLinks(),
                      ],
                    )
                  : Column(
                      children: [
                        _buildFooterBrand(),
                        const SizedBox(height: 24),
                        _buildFooterLinks(),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderLink(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildSlide(Map<String, String> slide, bool isDesktop) {
    final content = [
      Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(height: 1, width: 48, color: AppColors.primaryContainer),
                  const SizedBox(width: 16),
                  Text(
                    slide['label']!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryContainer,
                      letterSpacing: 3.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                slide['title']!,
                style: GoogleFonts.montserrat(
                  fontSize: isDesktop ? 42 : 32,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                slide['description']!,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                slide['image']!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
      ),
    ];

    if (isDesktop) {
      return Row(children: content);
    } else {
      return Column(children: content.reversed.toList());
    }
  }

  Widget _buildGetStartedButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.go('/register'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        elevation: 0,
      ),
      child: Text(
        'GET STARTED',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => context.go('/login'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
        side: const BorderSide(color: AppColors.primaryContainer, width: 1.5),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      child: Text(
        'LOG IN',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description, bool isHighlight) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: isHighlight ? const Border(top: BorderSide(color: AppColors.primaryContainer, width: 2)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 40, color: AppColors.primaryContainer),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterBrand() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/logo.png', width: 24, height: 24, fit: BoxFit.contain, color: AppColors.textHint),
        const SizedBox(width: 8),
        Text(
          'KALORIMU © 2024',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textHint,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLinks() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFooterLink('Privacy'),
        const SizedBox(width: 32),
        _buildFooterLink('Terms'),
        const SizedBox(width: 32),
        _buildFooterLink('Support'),
      ],
    );
  }

  Widget _buildFooterLink(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textHint,
      ),
    );
  }
}
