import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:aid_iq/services/local_module_service.dart';
import 'package:aid_iq/utils/logger.dart';

class ModuleDetailPage extends StatefulWidget {
  final Map<String, dynamic> module;

  const ModuleDetailPage({super.key, required this.module});

  @override
  State<ModuleDetailPage> createState() => _ModuleDetailPageState();
}

class _ModuleDetailPageState extends State<ModuleDetailPage> {
  final LocalModuleService _moduleService = LocalModuleService();
  final ScrollController _scrollController = ScrollController();
  bool _isCompleted = false;
  double _scrollPosition = 0.0;
  double _currentProgress = 0.0; // Real-time scroll progress (0.0 to 1.0)
  DateTime? _startTime;
  int _estimatedReadingTime = 5; // minutes (based on content length)
  final BlockquoteBuilder _blockquoteBuilder = BlockquoteBuilder();
  bool _showBackToTop = false; // Show back to top button when scrolled down

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _loadModuleProgress();
    _scrollController.addListener(_onScroll);

    // Calculate estimated reading time (rough estimate: 200 words per minute)
    final content = widget.module['content'] ?? '';
    final wordCount = content.split(' ').length;
    _estimatedReadingTime = (wordCount / 200).ceil();
    if (_estimatedReadingTime < 1) _estimatedReadingTime = 1;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Preprocess markdown to add spacing before each ## heading
  String _preprocessMarkdown(String content) {
    // Add blank lines before each ## heading for spacing
    return content.replaceAllMapped(RegExp(r'^## ', multiLine: true), (match) {
      return '\n\n## ';
    });
  }

  Future<void> _loadModuleProgress() async {
    try {
      final progress = await _moduleService.getUserModuleProgress();
      final moduleProgress =
          progress['moduleProgress'] as Map<String, dynamic>? ?? {};

      final moduleId = widget.module['id'] as String? ?? '';
      final moduleData = moduleProgress[moduleId] as Map<String, dynamic>?;

      final savedScrollPosition =
          (moduleData?['scrollPosition'] as num?)?.toDouble() ?? 0.0;

      setState(() {
        _isCompleted = moduleData?['completed'] == true;
        _scrollPosition = savedScrollPosition;
        _currentProgress = savedScrollPosition.clamp(0.0, 1.0);
      });

      // Restore scroll position if exists
      if (_scrollPosition > 0 && _scrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final maxScroll = _scrollController.position.maxScrollExtent;
          if (maxScroll > 0) {
            _scrollController.jumpTo(savedScrollPosition * maxScroll);
          }
        });
      }
    } catch (e) {
      appLogger.e('Error loading module progress', error: e);
    }
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      
      // Show back to top button when scrolled down more than 200 pixels
      final shouldShow = currentScroll > 200;
      if (shouldShow != _showBackToTop) {
        setState(() {
          _showBackToTop = shouldShow;
        });
      }
      
      if (maxScroll > 0) {
        final position = currentScroll / maxScroll;
        // Update state for real-time progress indicator
        setState(() {
          _currentProgress = position.clamp(0.0, 1.0);
        });
        // Save progress to local storage
        _moduleService.updateModuleReadingProgress(
          widget.module['id'] ?? '',
          position,
        );
      }
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _markAsCompleted() async {
    if (_startTime == null) return;

    final readingTime = DateTime.now().difference(_startTime!).inMinutes;
    final actualReadingTime =
        readingTime > 0 ? readingTime : _estimatedReadingTime;

    try {
      await _moduleService.markModuleCompleted(
        widget.module['id'] ?? '',
        widget.module['title'] ?? 'Module',
        actualReadingTime,
      );

      if (!mounted) return;
      setState(() {
        _isCompleted = true;
      });

      // Show completion dialog
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Module Completed!',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Congratulations! You\'ve completed "${widget.module['title']}".',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
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
                        'Reading time: $actualReadingTime min',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (!mounted) return;
                    Navigator.pop(context); // Close dialog
                    if (!mounted) return;
                    Navigator.pop(
                      context,
                      true,
                    ); // Return to home with refresh flag
                  },
                  child: Text(
                    'Continue Learning',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFd84040),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.module['title'] ?? 'Module';
    final String content = widget.module['content'] ?? '';
    final List<dynamic> pictures = widget.module['pictures'] ?? [];
    final String description = widget.module['description'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFd84040),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Share button
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // Share functionality
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Share feature coming soon!',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: const Color(0xFFd84040),
                ),
              );
            },
            tooltip: 'Share',
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          if (!_isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reading Progress',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '${(_currentProgress * 100).toStringAsFixed(0)}%',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFd84040),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _currentProgress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFd84040),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Completion badge
          if (_isCompleted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              color: Colors.green[50],
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Completed',
                    style: GoogleFonts.poppins(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '~$_estimatedReadingTime min read',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  if (description.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFd84040).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: const Color(0xFFd84040),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              description,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black87,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (description.isNotEmpty) const SizedBox(height: 20),

                  // Reading time estimate
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Estimated reading time: $_estimatedReadingTime min',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Pictures
                  if (pictures.isNotEmpty)
                    ...pictures.map((picture) {
                      final pictureString = picture.toString();
                      final isNetworkImage =
                          pictureString.startsWith('http://') ||
                          pictureString.startsWith('https://');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                              isNetworkImage
                                  ? Image.network(
                                    pictureString,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.broken_image,
                                              size: 48,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Failed to load image',
                                              style: GoogleFonts.poppins(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    loadingBuilder: (
                                      context,
                                      child,
                                      loadingProgress,
                                    ) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                          color: const Color(0xFFd84040),
                                        ),
                                      );
                                    },
                                  )
                                  : Image.asset(
                                    pictureString,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    package: null,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Debug: print the path being attempted
                                      print(
                                        'Failed to load asset: $pictureString',
                                      );
                                      print('Error: $error');
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.broken_image,
                                              size: 48,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Image not found',
                                              style: GoogleFonts.poppins(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              pictureString,
                                              style: GoogleFonts.poppins(
                                                color: Colors.grey[500],
                                                fontSize: 10,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                        ),
                      );
                    }),

                  if (pictures.isNotEmpty) const SizedBox(height: 20),

                  // Content
                  Builder(
                    builder: (context) {
                      final processedContent = _preprocessMarkdown(content);
                      _blockquoteBuilder.setOriginalMarkdown(processedContent);
                      return MarkdownBody(
                        data: processedContent,
                        styleSheet: MarkdownStyleSheet(
                          h1: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFd84040),
                          ),
                          h2: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          h3: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          p: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.6,
                          ),
                          pPadding: const EdgeInsets.only(bottom: 12),
                          listBullet: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          strong: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          blockquote: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.6,
                          ),
                          blockquoteDecoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          blockquotePadding: const EdgeInsets.all(16),
                          h2Padding: const EdgeInsets.only(top: 24, bottom: 8),
                        ),
                        builders: {'blockquote': _blockquoteBuilder},
                        onTapLink: (text, href, title) {
                          // Handle link taps if needed
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Completion button
                  if (!_isCompleted)
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _markAsCompleted,
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(
                          'Mark as Completed',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      // Back to Top Button
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: const Color(0xFFd84040),
              child: const Icon(
                Icons.arrow_upward,
                color: Colors.white,
              ),
              tooltip: 'Back to Top',
            )
          : null,
    );
  }
}

// Custom builder for blockquotes to add "Remember!" badge for Remember sections
// and italic styling for "Practice Makes Perfect" sections
class BlockquoteBuilder extends MarkdownElementBuilder {
  // Store the original markdown to check context
  String? _originalMarkdown;

  void setOriginalMarkdown(String markdown) {
    _originalMarkdown = markdown;
  }

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // Get the text content from the element
    final textContent = _extractText(element);

    // Check if this blockquote follows a "Remember" or "Practice Makes Perfect" heading
    bool showBadge = false;
    bool isPracticeMakesPerfect = false;
    if (_originalMarkdown != null) {
      // Find the position of this blockquote's text in the original markdown
      final blockquoteIndex = _originalMarkdown!.indexOf(textContent);
      if (blockquoteIndex > 0) {
        // Check if "## Remember" or "## Practice Makes Perfect" appears before this blockquote
        final beforeBlockquote = _originalMarkdown!.substring(
          0,
          blockquoteIndex,
        );
        // Look for "## Remember" followed by newlines and then this blockquote
        final rememberPattern = RegExp(r'## Remember\s*\n\s*\n\s*>');
        showBadge = rememberPattern.hasMatch(beforeBlockquote);
        // Look for "## Practice Makes Perfect" followed by newlines and then this blockquote
        final practicePattern = RegExp(
          r'## Practice Makes Perfect\s*\n\s*\n\s*>',
        );
        isPracticeMakesPerfect = practicePattern.hasMatch(beforeBlockquote);
      }
    }

    if (isPracticeMakesPerfect) {
      // "Practice Makes Perfect" section with italic styling
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: DefaultTextStyle(
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black87,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
            child: Text(textContent),
          ),
        ),
      );
    } else if (showBadge) {
      // "Remember" section with red badge
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: DefaultTextStyle(
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.6,
                ),
                child: Text(textContent),
              ),
            ),
            // Red "Remember!" badge in top-left corner
            Positioned(
              top: -12,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFd84040),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Remember!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Other sections - use default styling
      return null; // Return null to use default blockquote styling
    }
  }

  String _extractText(md.Element element) {
    if (element.textContent.isNotEmpty) {
      return element.textContent;
    }
    // Fallback: extract text from children
    final buffer = StringBuffer();
    for (final child in element.children ?? <md.Node>[]) {
      if (child is md.Text) {
        buffer.write(child.text);
      } else if (child is md.Element) {
        buffer.write(_extractText(child));
      }
    }
    return buffer.toString();
  }
}
