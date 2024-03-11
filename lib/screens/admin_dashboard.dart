// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartcook_cor/screens/index.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  Future<void> _signOut(BuildContext context) async {
    final scaffoldContext = ScaffoldMessenger.of(context);

    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      scaffoldContext.showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: <Widget>[
          _buildTile(
            context,
            color: Colors.blue,
            icon: Icons.book,
            title: 'Manage Recipes',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    const ManageRecipesScreen(), // Make sure you have a ManageRecipesScreen defined
              ));
            },
          ),
          _buildTile(
            context,
            color: Colors.green,
            icon: Icons.people,
            title: 'Manage Users',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    const ManageUsersPage(), // Make sure you have a ManageRecipesScreen defined
              ));
            },
          ),
          _buildTile(
            context,
            color: Colors.amber,
            icon: Icons.analytics,
            title: 'View Analytics',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    const AnalyticsScreen(), // Make sure you have an AnalyticsScreen defined
              ));
            },
          ),
          _buildTile(
            context,
            color: Colors.red,
            icon: Icons.exit_to_app,
            title: 'Logout',
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context,
      {required Color color,
      required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 50.0, color: Colors.white),
              Text(title, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
