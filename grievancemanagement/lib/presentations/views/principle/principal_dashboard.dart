import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grievancemanagement/presentations/views/login_screen.dart';
import 'package:grievancemanagement/presentations/views/principle/complaint_history_screen.dart'; // Import the new screen
import 'package:grievancemanagement/services/auth_service.dart';
import 'package:provider/provider.dart';

import 'complaint_list_screen.dart'; // Import the _ComplaintListScreen

class PrincipalDashboard extends StatelessWidget {
  PrincipalDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue.shade900,
        title: Text(
          'Principal Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // View Complaints Button
              SizedBox(
                height: 150,
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to _ComplaintListScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComplaintListScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'View Complaints',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20), // Add spacing between buttons
              // History Button
              SizedBox(
                height: 150,
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to ComplaintHistoryScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComplaintHistoryScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'History',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
