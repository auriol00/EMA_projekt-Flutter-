// import 'package:flutter/material.dart';

// class Formtextflield extends StatefulWidget {
//   final TextEditingController controller;
//   final String hintText;
//   final bool obscureText;
//   final String? Function(String?)? validator; // Optional validator

//   const Formtextflield({
//     super.key,
//     required this.controller,
//     required this.hintText,
//     required this.obscureText,
//     this.validator,
//   });

//   @override
//   State<Formtextflield> createState() => _Formtextflield();
// }

// class _Formtextflield extends State<Formtextflield> {
//   late bool _obscure;

//   @override
//   void initState() {
//     super.initState();
//     _obscure = widget.obscureText;
//   }

//   void _toggleVisibility() {
//     setState(() {
//       _obscure = !_obscure;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 25.0),
//       child: TextFormField(
//         controller: widget.controller,
//         obscureText: _obscure,
//         validator: widget.validator, // Now recognized
//         decoration: InputDecoration(
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: const BorderSide(color: Colors.white),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: Colors.grey.shade400),
//           ),
//           fillColor: Colors.grey.shade200,
//           filled: true,
//           hintText: widget.hintText,
//           hintStyle: TextStyle(color: Colors.grey[500]),
//           suffixIcon:
//               widget.obscureText
//                   ? IconButton(
//                     icon: Icon(
//                       _obscure ? Icons.visibility_off : Icons.visibility,
//                       color: Colors.grey,
//                     ),
//                     onPressed: _toggleVisibility,
//                   )
//                   : null,
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

class FormTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String? Function(String?)? validator;

  const FormTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.validator,
  });

  @override
  State<FormTextField> createState() => _FormTextFieldState();
}

class _FormTextFieldState extends State<FormTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  void _toggleVisibility() {
    setState(() {
      _obscure = !_obscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscure,
        validator: widget.validator,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
         fillColor: Theme.of(context).inputDecorationTheme.fillColor,

          filled: true,
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: _toggleVisibility,
                )
              : null,
        ),
      ),
    );
  }
}
