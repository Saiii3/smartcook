import 'package:flutter/material.dart';
import 'package:smartcook_cor/components/index.dart'; // Ensure this contains LineChartSample1

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Analytics'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingredient Trends',
                    style: TextStyle(
                      fontSize: 24, // Large font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16), // Spacing between title and chart
                  Expanded(
                    child: LineChartSample1(), // Your line chart widget
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
