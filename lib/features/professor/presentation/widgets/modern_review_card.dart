import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:plastinder/features/assistant/data/models/patient_model.dart';
import 'package:plastinder/features/professor/presentation/controllers/review_deck_controller.dart';
import 'package:plastinder/core/cache/image_cache_manager.dart';

final class ModernReviewCard extends StatefulWidget {
  final Patient patient;
  final ReviewDeckController controller;
  final Color secondary;
  final Color tertiary;

  const ModernReviewCard({
    super.key,
    required this.patient,
    required this.controller,
    required this.secondary,
    required this.tertiary,
  });

  @override
  State<ModernReviewCard> createState() => _ModernReviewCardState();
}

final class _ModernReviewCardState extends State<ModernReviewCard>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _swipeAnimationController;
  late AnimationController _scaleAnimationController;
  late AnimationController _slideInController;

  double _dragOffset = 0;
  bool _isDragging = false;
  String? _swipeDirection; // 'left' for reject, 'right' for accept

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _swipeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideInController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Start slide-in animation
    _slideInController.forward();
  }

  @override
  void didUpdateWidget(ModernReviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If patient changed, reset position and start slide-in animation
    if (oldWidget.patient.id != widget.patient.id) {
      _resetCardPosition();
      _slideInController.reset();
      _slideInController.forward();
    }
  }

  void _resetCardPosition() {
    setState(() {
      _dragOffset = 0;
      _swipeDirection = null;
      _isDragging = false;
    });
    _swipeAnimationController.reset();
    _scaleAnimationController.reset();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _swipeAnimationController.dispose();
    _scaleAnimationController.dispose();
    _slideInController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _swipeAnimationController,
          _slideInController,
        ]),
        builder: (context, child) {
          // Calculate slide-in offset
          final slideOffset = (1.0 - _slideInController.value) * 300;

          return Transform.translate(
            offset: Offset(_dragOffset + slideOffset, 0),
            child: Transform.scale(
              scale: 1.0 - (_dragOffset.abs() / 1000),
              child: Stack(
                children: [
                  // Main card
                  Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: widget.secondary.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildHeader(),
                        Expanded(child: _buildImageGallery()),
                        _buildActionButtons(),
                      ],
                    ),
                  ),

                  // Swipe feedback overlay
                  if (_isDragging && _swipeDirection != null)
                    _buildSwipeFeedback(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwipeFeedback() {
    final isReject = _swipeDirection == 'left'; // left = reject
    final opacity = (_dragOffset.abs() / 100).clamp(0.0, 1.0);

    return Positioned.fill(
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: (isReject ? Colors.red : Colors.green).withOpacity(
            opacity * 0.2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (isReject ? Colors.red : Colors.green).withOpacity(
                    opacity,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isReject ? Icons.close : Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isReject ? 'REDDET' : 'KABUL ET',
                style: TextStyle(
                  color: (isReject ? Colors.red : Colors.green).withOpacity(
                    opacity,
                  ),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [widget.secondary.withOpacity(0.1), Colors.white],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.person_outline,
              color: widget.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.patient.displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  '${widget.patient.images.length} fotoğraf',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          _buildSwipeIndicator(),
        ],
      ),
    );
  }

  Widget _buildSwipeIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.swipe_left, size: 16, color: Colors.red.shade400),
          const SizedBox(width: 4),
          Text(
            'Reddet',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.swipe_right, size: 16, color: Colors.green.shade400),
          const SizedBox(width: 4),
          Text(
            'Kabul',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    if (widget.patient.images.isEmpty) {
      return _buildEmptyState();
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: widget.patient.images.length,
      itemBuilder: (context, index) {
        final image = widget.patient.images[index];
        return GestureDetector(
          onTap: () => _showFullScreenImage(index),
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: image.url,
                fit: BoxFit.cover,
                cacheManager: PatientImageCacheManager(),
                placeholder: (context, url) => Container(
                  color: widget.tertiary.withOpacity(0.1),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.tertiary,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: widget.tertiary.withOpacity(0.1),
                  child: Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Fotoğraf Bulunamadı',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu hastaya ait fotoğraf bulunmuyor',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: _ModernActionButton(
              icon: Icons.close,
              label: 'Reddet',
              color: Colors.red,
              onTap: () => _handleReject(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _ModernActionButton(
              icon: Icons.skip_next,
              label: 'Atla',
              color: Colors.orange,
              onTap: () => _handleSkip(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _ModernActionButton(
              icon: Icons.check,
              label: 'Kabul Et',
              color: Colors.green,
              onTap: () => _handleAccept(),
            ),
          ),
        ],
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
    _scaleAnimationController.forward();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    setState(() {
      _dragOffset += details.delta.dx;

      // Determine swipe direction (right = accept, left = reject)
      if (_dragOffset > 20) {
        _swipeDirection = 'right'; // Accept
      } else if (_dragOffset < -20) {
        _swipeDirection = 'left'; // Reject
      } else {
        _swipeDirection = null;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;

    _isDragging = false;
    _scaleAnimationController.reverse();

    const threshold = 100.0;

    if (_dragOffset > threshold) {
      _handleAccept();
    } else if (_dragOffset < -threshold) {
      _handleReject();
    } else {
      _resetCard();
    }
  }

  void _resetCard() {
    _swipeAnimationController.forward().then((_) {
      setState(() {
        _dragOffset = 0;
        _swipeDirection = null;
      });
      _swipeAnimationController.reset();
    });
  }

  void _handleAccept() {
    // Animate card out to the right
    _animateCardOut('right', () {
      widget.controller.acceptPatient(widget.patient);
    });
  }

  void _handleReject() {
    // Animate card out to the left
    _animateCardOut('left', () {
      widget.controller.rejectPatient(widget.patient);
    });
  }

  void _handleSkip() {
    // Animate card out to the bottom
    _animateCardOut('bottom', () {
      widget.controller.skipPatient(widget.patient);
    });
  }

  void _animateCardOut(String direction, VoidCallback onComplete) {
    final targetOffset = direction == 'right'
        ? MediaQuery.of(context).size.width
        : direction == 'left'
        ? -MediaQuery.of(context).size.width
        : 0;

    _swipeAnimationController.forward().then((_) {
      setState(() {
        _dragOffset = targetOffset.toDouble();
      });

      // Wait a bit then call the controller method
      Future.delayed(const Duration(milliseconds: 200), onComplete);
    });
  }

  void _showFullScreenImage(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImageViewer(
          patient: widget.patient,
          initialIndex: initialIndex,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}

final class _ModernActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ModernActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _FullScreenImageViewer extends StatefulWidget {
  final Patient patient;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.patient,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

final class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.patient.displayName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          if (widget.patient.images.length > 1)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${_currentIndex + 1} / ${widget.patient.images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.patient.images.length,
        itemBuilder: (context, index) {
          final image = widget.patient.images[index];
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 5.0,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: image.url,
                fit: BoxFit.contain,
                cacheManager: PatientImageCacheManager(),
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.white, size: 64),
                      SizedBox(height: 16),
                      Text(
                        'Fotoğraf yüklenemedi',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
