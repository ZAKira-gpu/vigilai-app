import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class bottomNav extends StatelessWidget {
  final void Function(int)? onTabChange;
  const bottomNav({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: GNav(
          gap: 8,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: Colors.grey[600],
          activeColor: Colors.white,
          tabBackgroundColor: Color(0xFF6EA1FF),
          backgroundColor: Colors.transparent,
          tabBorderRadius: 30,
          onTabChange: onTabChange,
          tabs: const [
            GButton(
              icon: Icons.dashboard,
              text: "Dashboard",
              iconSize: 24,
              textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            GButton(
              icon: Icons.add_alert_rounded,
              text: "Alerts",
              iconSize: 24,
              textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            GButton(
              icon: Icons.cloud_outlined,
              text: "Cloud",
              iconSize: 24,
              textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
