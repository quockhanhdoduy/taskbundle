import 'package:flutter/material.dart';

class CustomPasswordField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;

  const CustomPasswordField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.prefixIcon,
    this.validator,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[600],
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

