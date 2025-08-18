import 'package:flutter/material.dart';
import 'package:mindcare/presentation/pages/docter_channel/widget/user_profile/currency_formatter.dart';

class SubmitButton extends StatelessWidget {
  final bool isLoading;
  final int consultationFee;
  final VoidCallback onSubmit;

  const SubmitButton({
    Key? key,
    required this.isLoading,
    required this.consultationFee,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: _buildButtonContent(context, isTablet),
      ),
    );
  }

  Widget _buildButtonContent(BuildContext context, bool isTablet) {
    if (isTablet && MediaQuery.of(context).size.width >= 1024) {
      // Desktop layout - center the button with max width
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: _buildButton(isTablet),
        ),
      );
    } else {
      // Mobile/Tablet layout - full width
      return _buildButton(isTablet);
    }
  }

  Widget _buildButton(bool isTablet) {
    return SizedBox(
      width: double.infinity,
      height: isTablet ? 56 : 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A4C93),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isLoading ? 0 : 2,
          shadowColor: const Color(0xFF6A4C93).withOpacity(0.3),
        ),
        child: isLoading
            ? SizedBox(
                width: isTablet ? 24 : 20,
                height: isTablet ? 24 : 20,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : _buildButtonText(isTablet),
      ),
    );
  }

  Widget _buildButtonText(bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonText = 'Book Appointment - LKR ${CurrencyFormatter.format(consultationFee)}';
        final textStyle = TextStyle(
          fontSize: isTablet ? 18 : 16,
          fontWeight: FontWeight.bold,
        );

        // Check if text fits in one line
        final textPainter = TextPainter(
          text: TextSpan(text: buttonText, style: textStyle),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: constraints.maxWidth - 60); // Account for icon and padding

        if (textPainter.didExceedMaxLines) {
          // Text is too long, split into two lines
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_available, size: isTablet ? 20 : 18),
                  const SizedBox(width: 8),
                  const Text('Book Appointment'),
                ],
              ),
              Text(
                'LKR ${CurrencyFormatter.format(consultationFee)}',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        } else {
          // Text fits in one line
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_available, size: isTablet ? 20 : 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  buttonText,
                  style: textStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }
      },
    );
  }
}