import 'package:flutter/material.dart';

class SlidableBookingButton extends StatefulWidget {
  const SlidableBookingButton({
    super.key,
    this.onBookingConfirmed,
  });

  final VoidCallback? onBookingConfirmed;

  @override
  State<SlidableBookingButton> createState() => _SlidableBookingButtonState();
}

class _SlidableBookingButtonState extends State<SlidableBookingButton>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  double _dragPercentage = 0;
  bool _confirmed = false;

  final double _buttonHeight = 70;
  final double _buttonWidth = 300;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.addListener(() {
      setState(() {
        if (_animation.status == AnimationStatus.reverse) {
          _dragPercentage = _animation.value;
          _dragPosition = _dragPercentage * (_buttonWidth - _buttonHeight);
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_confirmed) return;

    setState(() {
      _dragPosition += details.delta.dx;
      if (_dragPosition < 0) {
        _dragPosition = 0;
      } else if (_dragPosition > _buttonWidth - _buttonHeight) {
        _dragPosition = _buttonWidth - _buttonHeight;
      }

      _dragPercentage = _dragPosition / (_buttonWidth - _buttonHeight);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_confirmed) return;

    if (_dragPercentage > 0.9) {
      setState(() {
        _dragPosition = _buttonWidth - _buttonHeight;
        _dragPercentage = 1.0;
        _confirmed = true;
      });
      _showConfirmationDialog();
    } else {
      _resetPosition();
    }
  }

  void _resetPosition() {
    _animationController.value = _dragPercentage;
    _animationController.reverse();
  }

  void _showConfirmationDialog() {
    Future.delayed(const Duration(milliseconds: 300), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text(' Confirm Booking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 5),
              const Text('Please confirm your slot booking.'),
              const SizedBox(height: 20),
              _bookbutton(() {
                Navigator.of(context).pop();
                widget.onBookingConfirmed?.call();
                setState(() {
                  _confirmed = false;
                  _resetPosition();
                });
              }),
              const SizedBox(height: 20),
              _cancelButton(() {
                Navigator.of(context).pop();
                setState(() {
                  _confirmed = false;
                  _resetPosition();
                });
              }),
            ],
          ),
        ),
      );
    });
  }

  Widget _bookbutton(VoidCallback? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // Green
        foregroundColor: Colors.white,
        // minimumSize: const Size(140, 45),
        // maximumSize: const Size(140, 45),
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today),
          SizedBox(width: 12),
          Text(
            'Book Slot',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cancelButton(VoidCallback? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE53935), // Red
        // minimumSize: const Size(140, 45),
        // maximumSize: const Size(140, 45),
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFFE53935), // Red border
            width: 1.5,
          ),
        ),
        elevation: 0,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.close),
          SizedBox(width: 12),
          Text(
            'Cancel Appointment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _buttonWidth,
      height: _buttonHeight,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(_buttonHeight / 2),
      ),
      child: Stack(
        children: [
          // Background text
          Align(
            alignment: Alignment.center,
            child: Text(
              'SLIDE TO BOOK',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
            ),
          ),
          // Slider handle
          Positioned(
            left: _dragPosition,
            top: 0,
            child: GestureDetector(
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              child: Container(
                width: _buttonHeight,
                height: _buttonHeight,
                decoration: BoxDecoration(
                  color: _confirmed ? Colors.green : Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _confirmed ? Icons.check : Icons.arrow_forward,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Fill color based on drag percentage
          ClipRRect(
            borderRadius: BorderRadius.circular(_buttonHeight / 2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: _dragPosition + _buttonHeight / 2,
                height: _buttonHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.5),
                      Colors.blue.withOpacity(0.3),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
