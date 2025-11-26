import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:aid_iq/services/module_service.dart';
import 'package:aid_iq/utils/logger.dart';

class ModuleDetailPage extends StatefulWidget {
  final Map<String, dynamic> module;

  const ModuleDetailPage({super.key, required this.module});

  @override
  State<ModuleDetailPage> createState() => _ModuleDetailPageState();
}

class _ModuleDetailPageState extends State<ModuleDetailPage> {
  final ModuleService _moduleService = ModuleService();
  final ScrollController _scrollController = ScrollController();
  bool _isCompleted = false;
  double _scrollPosition = 0.0;
  DateTime? _startTime;
  int _estimatedReadingTime = 5; // minutes (based on content length)

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

  Future<void> _loadModuleProgress() async {
    try {
      final progress = await _moduleService.getUserModuleProgress();
      final moduleProgress =
          progress['moduleProgress'] as Map<String, dynamic>? ?? {};

      final moduleId = widget.module['id'] as String? ?? '';
      final moduleData = moduleProgress[moduleId] as Map<String, dynamic>?;

      setState(() {
        _isCompleted = moduleData?['completed'] == true;
        _scrollPosition =
            (moduleData?['scrollPosition'] as num?)?.toDouble() ?? 0.0;
      });

      // Restore scroll position if exists
      if (_scrollPosition > 0 && _scrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.jumpTo(_scrollPosition);
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
      if (maxScroll > 0) {
        final position = currentScroll / maxScroll;
        _moduleService.updateModuleReadingProgress(
          widget.module['id'] ?? '',
          position,
        );
      }
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
              height: 4,
              color: Colors.grey[200],
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _scrollPosition > 0 ? _scrollPosition : 0.0,
                child: Container(color: const Color(0xFFd84040)),
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
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Image placeholder',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                  if (pictures.isNotEmpty) const SizedBox(height: 20),

                  // Content
                  MarkdownBody(
                    data: content,
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
                      listBullet: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      strong: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
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
    );
  }
}
