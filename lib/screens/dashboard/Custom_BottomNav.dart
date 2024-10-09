import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/screens/auth/sign_in_screen.dart';
import 'package:hands_user_app/screens/dashboard/fragment/booking_fragment.dart';
import 'package:hands_user_app/utils/colors.dart';

const Color greylight = Color.fromARGB(255, 191, 185, 185);
Widget customFloatingActionButton(BuildContext context) {
  return Align(
    alignment: Alignment(0.1, 1.2),
    child: Container(
      height: 55,
      width: 55,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(50)),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 191, 185, 185),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          // Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          //   MaterialPageRoute(
          //     builder: (BuildContext context) {
          //       return Observer(
          //           builder: (context) => appStore.isLoggedIn
          //               ? BookingFragment()
          //               : SignInScreen(isFromDashboard: true));
          //     },
          //   ),
          //   (_) => false,
          // );
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Observer(
                      builder: (context) => appStore.isLoggedIn
                          ? BookingFragment()
                          : SignInScreen(isFromDashboard: true))));
        },
        backgroundColor: primaryColor,
        shape: const CircleBorder(),
        child: ClipOval(
          child: Image.asset(
            'assets/logo_large.png',
            fit: BoxFit.cover,
            width: 190,
            height: 190,
          ),
        ),
      ),
    ),
  );
}

Widget custombottomNavigationBar(BuildContext context) {
  return Container(
    decoration: const BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: greylight,
          offset: Offset(-2, 0),
          blurRadius: 4,
        ),
      ],
    ),
    child: BottomAppBar(
      color: primaryColor,
      child: Container(
        height: 41,
        child: Padding(
          padding: const EdgeInsets.only(left: 53, right: 53),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              customnavBarItem(context, Icons.home_filled, 'Home'),
              customnavBarItem(context, Icons.person_2_outlined, 'Profile'),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget customnavBarItem(BuildContext context, IconData icon, String label) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      FaIcon(
        icon,
        size: 24,
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
      GestureDetector(
        onTap: () {
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => ProfileScreen()));
        },
        child: Text(
          label,
          style: GoogleFonts.almarai(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    ],
  );
}
