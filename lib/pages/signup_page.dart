import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:new_vigilai/pages/home_page/home_page.dart';
import 'package:new_vigilai/pages/signin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl_phone_field/intl_phone_field.dart';


import '../firebase_auth/firebase_auth.dart'; // make sure your signup function is here

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final phoneController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();




  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\+?\d{9,15}$'); // allows +1234567890 (9 to 15 digits)
    return phoneRegex.hasMatch(phone);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final phone = phoneController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your phone number")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => isLoading = true);

    bool signupSuccess = await signup(context, email, password, phone);

    setState(() => isLoading = false);

    if (signupSuccess) {
      await _onSignUpSuccess(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sign up failed. Please try again.")),
      );
    }
  }


  Future<void> _onSignUpSuccess(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false); // Don't auto-login after signup

    // Show dialog to notify user
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Verify Your Email"),
        content: const Text(
          "We've sent a verification link to your email. Please verify it before signing in.",
        ),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SignInPage()),
              );
            },
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF2F5F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'VigilAI',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A3A3A),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 180,
                        child: Lottie.asset('assets/Logo.json'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Please fill the details below.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          controller: emailController,
                          hint: "Email",
                          icon: Icons.email_outlined,
                          onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: 12),
                        IntlPhoneField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            filled: true,
                            fillColor: const Color(0xFFF7F8FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          initialCountryCode: 'DZ', // Change to your default country
                          onChanged: (phone) {
                            print(phone.completeNumber); // Full number with country code
                          },
                          onCountryChanged: (country) {
                            print('Country changed to: ' + country.name);
                          },
                        ),

                        const SizedBox(height: 12),
                        _buildPasswordField(),
                        const SizedBox(height: 12),
                        _buildConfirmPasswordField(),
                        const SizedBox(height: 12),
                        _buildSignUpButton(context),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SignInPage()),
                              );
                            },
                            child: const Text(
                              "Already have an account? Sign In",
                              style: TextStyle(color: Color(0xFF6EA1FF)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    FocusNode? focusNode,
    TextInputAction textInputAction = TextInputAction.next,
    void Function(String)? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction,
      keyboardType: TextInputType.emailAddress,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFF6EA1FF)),
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }




  Widget _buildPasswordField() {
    return TextField(
      controller: passwordController,
      focusNode: _passwordFocusNode,
      obscureText: !isPasswordVisible,
      textInputAction: TextInputAction.next,
      onSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF6EA1FF)),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
        ),
        hintText: "Password",
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextField(
      controller: confirmPasswordController,
      focusNode: _confirmPasswordFocusNode,
      obscureText: !isConfirmPasswordVisible,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF6EA1FF)),
        suffixIcon: IconButton(
          icon: Icon(
            isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              isConfirmPasswordVisible = !isConfirmPasswordVisible;
            });
          },
        ),
        hintText: "Confirm Password",
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _handleSignUp(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6EA1FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          "Sign Up",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
