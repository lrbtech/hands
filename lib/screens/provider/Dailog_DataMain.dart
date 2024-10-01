import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hands_user_app/screens/provider/Colors.dart';
import 'package:hands_user_app/screens/provider/NonResident_Page.dart';
import 'package:hands_user_app/screens/provider/Resident_Page.dart';
import 'package:hands_user_app/utils/colors.dart';

class CustomDialogBox extends StatefulWidget {
  const CustomDialogBox({super.key});

  @override
  State<CustomDialogBox> createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int activeStep = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _goToStep1() {
    setState(() {
      activeStep = 0;
      _tabController.animateTo(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: primaryColor,
      insetPadding: const EdgeInsets.only(bottom: 15, right: 15, left: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (activeStep == 1)
                  GestureDetector(
                    onTap: _goToStep1,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          width: 2.0,
                        ),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back,
                          color: Theme.of(context).colorScheme.onSecondary,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        width: 2.0,
                      ),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onSecondary,
                        size: 24.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            height: 54,
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 1),
                  color: AppColors.greylight,
                ),
              ],
              borderRadius: BorderRadius.all(Radius.circular(125)),
              color: AppColors.skyblue,
            ),
            child: TabBar(
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.only(
                top: 6,
                left: 4,
                right: 4,
                bottom: 3,
              ),
              indicatorColor: Colors.transparent,
              controller: _tabController,
              labelColor: AppColors.purewhite,
              unselectedLabelColor: const Color.fromARGB(255, 75, 87, 135),
              indicator: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                color: AppColors.bgcolor,
              ),
              tabs: [
                Tab(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text('Resident',
                        style: GoogleFonts.almarai(
                            fontSize: 17, fontWeight: FontWeight.w700)),
                  ),
                ),
                Tab(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text('Non Resident',
                        style: GoogleFonts.almarai(
                            fontSize: 17, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
              onTap: (index) {
                setState(() {
                  activeStep = index;
                });
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ResidentPage(
                  onNext: () {
                    setState(() {
                      activeStep = 1;
                      _tabController.animateTo(1);
                    });
                  },
                ),
                const NonresidentPage()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
