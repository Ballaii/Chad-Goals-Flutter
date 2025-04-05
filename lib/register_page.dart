import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'home_screen.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final ageController = TextEditingController();

  void signUp(BuildContext context) async {
    if(emailController.text.isEmpty &&
        passwordController.text.isEmpty &&
        confirmPasswordController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
    if (passwordController.text == confirmPasswordController.text) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        ).then((value) => Navigator.pop(context));

        await addUserDataToFirestore();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
    }
  }

  Future addUserDataToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    final userData = {
      'name': nameController.text,
      'email': emailController.text,
      'height': heightController.text,
      'weight': weightController.text,
      'age': ageController.text,
    };
    await FirebaseFirestore.instance
        .collection('userdata')
        .doc(user!.uid)
        .set(userData);
  }

  void signUnWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential).then((value)
    => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)
    => const HomeScreen()))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF41318D), // Deep purple
              Colors.black,
            ],
            stops: [0.29, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Centered app logo
                  Center(
                    child: Image.asset(
                      'assets/192.png',
                      width: 150,
                      height: 150,
                    ),
                  ),
                  const SizedBox(height: 40),

                  //Name field
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Name',
                        hintStyle: const TextStyle(color: Colors.white54),
                        labelText: 'Name:',
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.grey.withAlpha(100),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  //Age field
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: TextField(
                      controller: ageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Age',
                        hintStyle: const TextStyle(color: Colors.white54),
                        labelText: 'Age:',
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.grey.withAlpha(100),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  //Height field
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: TextField(
                      controller: heightController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Height',
                        hintStyle: const TextStyle(color: Colors.white54),
                        labelText: 'Height:',
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.grey.withAlpha(100),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  //Weight field
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: TextField(
                      controller: weightController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Weight',
                        hintStyle: const TextStyle(color: Colors.white54),
                        labelText: 'Weight:',
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.grey.withAlpha(100),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),


                  // Email field
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: const TextStyle(color: Colors.white54),
                        labelText: 'Email:',
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.grey.withAlpha(100),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  // Password field
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: const TextStyle(color: Colors.white54),
                        labelText: 'Password:',
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.grey.withAlpha(100),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  // Confirm Password field
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        hintStyle: const TextStyle(color: Colors.white54),
                        labelText: 'Confirm Password:',
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.grey.withAlpha(100),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign Up button
                  Center(
                    child: InkWell(
                      onTap: () {
                        // Navigate to the NameStatsPage
                        signUp(context);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF41318D),
                              Colors.deepPurple,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // "Already have an account? Sign In Here"
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.white70),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Sign In Here',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // "Sign up with" text
                  const Center(
                    child: Text(
                      'Sign up with',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Row of social icons: Google, Instagram, X
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          signUnWithGoogle();
                        },
                        icon: Image.asset('assets/google.png'),
                        iconSize: 40,
                      ),
                      const SizedBox(width: 30),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Apple sign-in is not implemented yet.'),
                            ),
                          );
                        },
                        icon: Icon(Icons.apple_sharp, color: Colors.white),
                        iconSize: 50,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
