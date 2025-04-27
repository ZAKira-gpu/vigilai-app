import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:new_vigilai/pages/home_page/pages/about_page.dart';
import 'package:new_vigilai/pages/home_page/pages/alerts_page.dart';
import 'package:new_vigilai/pages/home_page/pages/bottom_nav_bar.dart';
import 'package:new_vigilai/pages/home_page/pages/cloud_page.dart';
import 'package:new_vigilai/pages/home_page/pages/dashboard_page.dart';
import 'package:new_vigilai/pages/home_page/pages/user%20profile_page.dart';
import 'package:new_vigilai/pages/login_screen.dart';
import 'package:new_vigilai/pages/signin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';



class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _AnimatedProfileButton extends StatefulWidget {
  @override
  State<_AnimatedProfileButton> createState() => _AnimatedProfileButtonState();
}

class _AnimatedProfileButtonState extends State<_AnimatedProfileButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.9; // Shrink a bit on tap down
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0; // Return to normal size
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
      },
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Hero(
        tag: 'profileAvatar',
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade300,
          child: Icon(
            Icons.person,
            color: Colors.black,
          ),
        ),
      ),

    );
  }
}




class _homeState extends State<home> {

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              _onLogout();
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }




  void _onLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn'); // remove login flag

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }


  //this selected index to control the bottom bar
  int _selectedindex = 0;
  //this methode will update the selected index when
// the user selected the index from the bottom bar
  void navigatebottombar (int index) {
    setState(() {
      _selectedindex = index;
    });
  }
//pages to navigate
  final List<Widget> _pages =[
    //dashboard page
    dashboard(key: ValueKey('dashboard')),
    //alerts page
    alerts(key: ValueKey('alerts')),
    //cloud page
    cloud(key: ValueKey('cloud')),

  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F9FF),
        bottomNavigationBar: bottomNav(
          onTabChange: (index) => navigatebottombar(index),
        ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.2, 0),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: _pages[_selectedindex],
      ),

      appBar:AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Builder(builder: (context)=>
              IconButton(onPressed: (){
                Scaffold.of(context).openDrawer();
              }, icon: Icon(Icons.menu,
                color: Colors.black,)
              )),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: _AnimatedProfileButton(),
          ),
        ],

      ) ,
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: SizedBox(
                        height: 120,
                        width: 120,
                        child: Lottie.asset(
                          'assets/Logo.json',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    const SizedBox(height: 20),
                    _modernDrawerItem(
                      icon: Icons.home,
                      text: "Home",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => about()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _modernDrawerItem(
                      icon: Icons.info_outline,
                      text: "About",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => about()),
                        );
                      },
                    ),
                  ],
                ),
                Column(
                  children: [
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    const SizedBox(height: 12),
                    _modernDrawerItem(
                      icon: Icons.logout,
                      text: "Logout",
                      onTap: () {
                        Navigator.pop(context);
                        _showLogoutDialog(context);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),




    );
  }
}


Widget _modernDrawerItem({
  required IconData icon,
  required String text,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.grey.shade100,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.black, size: 24),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

