import 'package:flutter/material.dart';
import 'package:mindcare/presentation/pages/tips/data/stress_tip.dart';
import 'package:mindcare/presentation/pages/tips/data/tips_data.dart';

enum Language { english, sinhala, tamil }

class StressTipsPage extends StatefulWidget {
  final String? stressLevel; 
  final Language? preferredLanguage;
  
  const StressTipsPage({
    Key? key,
    this.stressLevel,
    this.preferredLanguage,
  }) : super(key: key);

  @override
  _StressTipsPageState createState() => _StressTipsPageState();
}

class _StressTipsPageState extends State<StressTipsPage>
    with TickerProviderStateMixin {
  List<StressTip>? tips;
  bool isLoading = false;
  bool isGeneratingTips = false;
  String loadingMessage = '';
  Language selectedLanguage = Language.english;
  bool showLanguageSelection = true;
  String selectedCategory = 'general';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> categories = [
    'general',
    'workplace',
    'relationships',
    'physical',
    'mental',
    'sleep',
    'breathing',
    'mindfulness'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.preferredLanguage != null) {
      selectedLanguage = widget.preferredLanguage!;
      showLanguageSelection = false;
      _loadTips();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTips() async {
    setState(() {
      isLoading = true;
      isGeneratingTips = true;
      loadingMessage = _getLoadingMessage();
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      List<StressTip> loadedTips;

      switch (selectedLanguage) {
        case Language.english:
          setState(() {
            loadingMessage = 'Generating personalized stress management tips...';
          });
          loadedTips = await ShortTipsData.getShortStressTips(
            language: TipsLanguage.english,
            category: selectedCategory,
           
          );
          break;
        case Language.sinhala:
          setState(() {
            loadingMessage = 'ආතතිය කළමනාකරණ උපදෙස් සකස් කරමින්...';
          });
          loadedTips = await  ShortTipsData.getShortStressTips(
            language: TipsLanguage.sinhala,
            category: selectedCategory,
        
          );
          break;
        case Language.tamil:
          setState(() {
            loadingMessage = 'மன அழுத்த மேலாண்மை குறிப்புகளை உருவாக்குகிறது...';
          });
          loadedTips = await  ShortTipsData.getShortStressTips(
            language: TipsLanguage.tamil,
            category: selectedCategory,
          );
          break;
      }

      if (mounted) {
        setState(() {
          tips = loadedTips;
          isLoading = false;
          isGeneratingTips = false;
          showLanguageSelection = false;
          loadingMessage = '';
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          isGeneratingTips = false;
          loadingMessage = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load tips: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  String _getLoadingMessage() {
    switch (selectedLanguage) {
      case Language.sinhala:
        return 'උපදෙස් සකස් කරමින්...';
      case Language.tamil:
        return 'குறிப்புகளை தயாரிக்கிறது...';
      default:
        return 'Generating tips...';
    }
  }

  void selectLanguage(Language language) {
    setState(() {
      selectedLanguage = language;
    });
    _loadTips();
  }

  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
      _animationController.reset();
    });
    _loadTips();
  }

  void refreshTips() {
    _animationController.reset();
    _loadTips();
  }

  void changeLanguage() {
    setState(() {
      showLanguageSelection = true;
      tips = null;
      isLoading = false;
      isGeneratingTips = false;
      loadingMessage = '';
    });
    _animationController.reset();
  }

  Widget _buildLanguageSelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.psychology,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 24),
          const Text(
            'Select Language for Stress Tips\nආතතිය උපදෙස් සඳහා භාෂාව තෝරන්න\nமன அழுத்த குறिप্புகளுக்கான மொழியைத் তেर்ந்தেडুக্கவুম්',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // English Button
          _buildLanguageButton(
            language: Language.english,
            text: 'English',
            color: Colors.blue[600]!,
          ),

          const SizedBox(height: 16),

          // Sinhala Button
          _buildLanguageButton(
            language: Language.sinhala,
            text: 'සිංහල',
            color: Colors.green[600]!,
          ),

          const SizedBox(height: 16),

          // Tamil Button
          _buildLanguageButton(
            language: Language.tamil,
            text: 'தமிழ்',
            color: Colors.orange[600]!,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton({
    required Language language,
    required String text,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: isGeneratingTips ? null : () => selectLanguage(language),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(_getLoadingColor()),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            loadingMessage,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            _getSubLoadingMessage(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildProgressDots(),
        ],
      ),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 600 + (index * 200)),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _getLoadingColor().withOpacity(0.7),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(_getCategoryName(category)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) selectCategory(category);
              },
              selectedColor: _getLoadingColor().withOpacity(0.2),
              checkmarkColor: _getLoadingColor(),
              labelStyle: TextStyle(
                color: isSelected ? _getLoadingColor() : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTipsList() {
    if (tips == null || tips!.isEmpty) {
      return const Center(
        child: Text('No tips available'),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        itemCount: tips!.length,
        itemBuilder: (context, index) {
          final tip = tips![index];
          return _buildTipCard(tip, index);
        },
      ),
    );
  }

  Widget _buildTipCard(StressTip tip, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getLoadingColor().withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getLoadingColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getTipIcon(tip.category),
                        color: _getLoadingColor(),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(tip.difficulty ?? 'easy'),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getDifficultyText(tip.difficulty ?? 'easy'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  tip.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                if (tip.steps.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    _getStepsTitle(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...tip.steps.asMap().entries.map((entry) {
                    final stepIndex = entry.key;
                    final step = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _getLoadingColor(),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${stepIndex + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              step,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
                if (tip.duration != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_getDurationText()}: ${tip.duration}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getLoadingColor() {
    switch (selectedLanguage) {
      case Language.sinhala:
        return Colors.green[600]!;
      case Language.tamil:
        return Colors.orange[600]!;
      default:
        return Colors.blue[600]!;
    }
  }

  String _getSubLoadingMessage() {
    switch (selectedLanguage) {
      case Language.sinhala:
        return 'කරුණාකර රැඳී සිටින්න...';
      case Language.tamil:
        return 'தயவுசெய்து காத்திருக்கவும்...';
      default:
        return 'Please wait...';
    }
  }

  String _getAppBarTitle() {
    if (isGeneratingTips) {
      switch (selectedLanguage) {
        case Language.sinhala:
          return 'උපදෙස් සකස් කරමින්';
        case Language.tamil:
          return 'குறிப்புகள் தயாரிप்பு';
        default:
          return 'Generating Tips';
      }
    }

    switch (selectedLanguage) {
      case Language.sinhala:
        return 'ආතතිය කළමනාකරණ උපදෙස්';
      case Language.tamil:
        return 'மன அழுத்த மேலாண்மை குறிप்புகள்';
      default:
        return 'Stress Management Tips';
    }
  }

  String _getCategoryName(String category) {
    switch (selectedLanguage) {
      case Language.sinhala:
        switch (category) {
          case 'general': return 'සාමාන්‍ය';
          case 'workplace': return 'කාර්යාලය';
          case 'relationships': return 'සබඳතා';
          case 'physical': return 'ශාරීරික';
          case 'mental': return 'මානසික';
          case 'sleep': return 'නින්ද';
          case 'breathing': return 'ශ්වසන';
          case 'mindfulness': return 'සිහිකල්පනාව';
          default: return category;
        }
      case Language.tamil:
        switch (category) {
          case 'general': return 'பொது';
          case 'workplace': return 'பணியிடம்';
          case 'relationships': return 'உறవுகள்';
          case 'physical': return 'உடல்';
          case 'mental': return 'மன';
          case 'sleep': return 'தூக்கம்';
          case 'breathing': return 'சுவாசம்';
          case 'mindfulness': return 'நினைவாற்றல்';
          default: return category;
        }
      default:
        switch (category) {
          case 'general': return 'General';
          case 'workplace': return 'Workplace';
          case 'relationships': return 'Relationships';
          case 'physical': return 'Physical';
          case 'mental': return 'Mental';
          case 'sleep': return 'Sleep';
          case 'breathing': return 'Breathing';
          case 'mindfulness': return 'Mindfulness';
          default: return category;
        }
    }
  }

  IconData _getTipIcon(String? category) {
    switch (category) {
      case 'workplace': return Icons.work;
      case 'relationships': return Icons.people;
      case 'physical': return Icons.fitness_center;
      case 'mental': return Icons.psychology;
      case 'sleep': return Icons.bedtime;
      case 'breathing': return Icons.air;
      case 'mindfulness': return Icons.self_improvement;
      default: return Icons.lightbulb;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy': return Colors.green;
      case 'medium': return Colors.orange;
      case 'hard': return Colors.red;
      default: return Colors.blue;
    }
  }

  String _getDifficultyText(String difficulty) {
    switch (selectedLanguage) {
      case Language.sinhala:
        switch (difficulty.toLowerCase()) {
          case 'easy': return 'පහසු';
          case 'medium': return 'මධ්‍යම';
          case 'hard': return 'අපහසු';
          default: return difficulty;
        }
      case Language.tamil:
        switch (difficulty.toLowerCase()) {
          case 'easy': return 'எளிது';
          case 'medium': return 'நடுத்தர';
          case 'hard': return 'கடினம்';
          default: return difficulty;
        }
      default:
        return difficulty.toUpperCase();
    }
  }

  String _getStepsTitle() {
    switch (selectedLanguage) {
      case Language.sinhala:
        return 'පියවර:';
      case Language.tamil:
        return 'படிகள்:';
      default:
        return 'Steps:';
    }
  }

  String _getDurationText() {
    switch (selectedLanguage) {
      case Language.sinhala:
        return 'කාලය';
      case Language.tamil:
        return 'காலம்';
      default:
        return 'Duration';
    }
  }

  String _getRefreshButtonText() {
    switch (selectedLanguage) {
      case Language.sinhala:
        return 'නව උපදෙස්';
      case Language.tamil:
        return 'புதிய குறিப்புகள்';
      default:
        return 'New Tips';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
        actions: [
          if (!showLanguageSelection && !isLoading && !isGeneratingTips) ...[
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: refreshTips,
              tooltip: _getRefreshButtonText(),
            ),
            IconButton(
              icon: const Icon(Icons.language),
              onPressed: changeLanguage,
              tooltip: 'Change Language',
            ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: showLanguageSelection
            ? _buildLanguageSelection()
            : isLoading || isGeneratingTips
                ? _buildLoadingScreen()
                : tips == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[400],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Failed to load tips. Please try again.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: changeLanguage,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          _buildCategorySelector(),
                          Expanded(child: _buildTipsList()),
                        ],
                      ),
      ),
    );
  }
}