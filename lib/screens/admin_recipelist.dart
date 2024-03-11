// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRecipeListScreen extends StatefulWidget {
  const AdminRecipeListScreen({super.key});

  @override
  _AdminRecipeListScreenState createState() => _AdminRecipeListScreenState();
}

class _AdminRecipeListScreenState extends State<AdminRecipeListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isAdminUser(String userId) async {
  var userDoc = await _firestore.collection('users').doc(userId).get();
  return userDoc.data()?['role'] == 'admin';
}

void checkAdminAccess() async {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user = auth.currentUser;

  if (user != null) {
    bool isAdmin = await isAdminUser(user.uid);
    if (isAdmin) {
      // Navigate to the AdminRecipeListScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminRecipeListScreen()),
      );
    } else {
      // Show an error or navigate to a regular user screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You do not have admin privileges.')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Recipe Management'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('recipes').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          final recipes = snapshot.data?.docs ?? [];
          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              var recipe = recipes[index];
              return ListTile(
                title: Text(recipe['name']),
                subtitle: Text(recipe['description']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // TODO: Navigate to edit recipe screen
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        // TODO: Implement recipe deletion
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create new recipe screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
