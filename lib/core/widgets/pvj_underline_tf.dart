import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PvjUnderlineTf extends StatelessWidget {
  const PvjUnderlineTf(
      {super.key,
      required this.controller,
      required this.labelText,
      this.keyboardType,
      this.onChanged,
      this.inputFormatters,
      this.validator});

  final TextEditingController controller;
  final String labelText;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,inputFormatters:inputFormatters,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.robotoMono(
          letterSpacing: 1,
        ),
        errorStyle: GoogleFonts.robotoMono(
          letterSpacing: 1,
        ),
        hintStyle: GoogleFonts.robotoMono(
          letterSpacing: 1,
        ),
      ),
      validator: validator,
    );
  }
}
