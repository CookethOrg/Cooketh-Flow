import 'package:cookethflow/providers/authentication_provider.dart';
import 'package:cookethflow/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<DashboardProvider, AuthenticationProvider>(
      builder: (context, provider, auth, child) {

        return FutureBuilder(
          future: auth.fetchCurrentUser(),
          builder: (context,snapshot) {
if(snapshot.connectionState == ConnectionState.waiting){
  return SizedBox();
}else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No users found"));
          }
            var user = snapshot.data;
            return Stack(
              children: [
                // Main Floating Drawer
                Positioned(
                  // duration: Duration(milliseconds: 400),
                  // curve: Curves.easeInOut,
                  top: 24,
                  left: 24,
                  child: Material(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      // duration: Duration(milliseconds: 400),
                      // curve: Curves.easeInOut,
                      width: 350,
                      height: MediaQuery.of(context).size.height * 0.95,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: AssetImage('assets/pic1.png'),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  user!['userName'],
                                  style: TextStyle(
                                      fontFamily: 'Frederik', fontSize: 20),
                                ),
                                IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.keyboard_arrow_down_outlined)),
                                SizedBox(
                                  width: 10,
                                ),
                                IconButton(
                                    onPressed: () {},
                                    iconSize: 30,
                                    icon: Icon(Icons.notifications_on_outlined))
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: ElevatedButton.icon(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    fixedSize: Size(200, 50),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12))),
                                icon: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Add another account',
                                  style: TextStyle(
                                      fontFamily: 'Frederik',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                )),
                          ),
                          SizedBox(
                            height: 35,
                          ),
                          TextButton.icon(
                              onPressed: () {},
                              icon: Icon(
                                PhosphorIconsRegular.fileDoc,
                                size: 25,
                                // fill: 20,
                              ),
                              label: Text(
                                'Drafts',
                                style: TextStyle(
                                    fontFamily: 'Frederik',
                                    fontSize: 20,
                                    // fontWeight: FontWeight.w100,
                                    color: Colors.black),
                              )),
                          SizedBox(
                            height: 8,
                          ),
                          TextButton.icon(
                              onPressed: () {},
                              icon: Icon(PhosphorIconsRegular.trash),
                              label: Text(
                                'Trash',
                                style: TextStyle(
                                    fontFamily: 'Frederik',
                                    fontSize: 20,
                                    // fontWeight: FontWeight.w100,
                                    color: Colors.black),
                              )),
                          SizedBox(
                            height: 8,
                          ),
                          TextButton.icon(
                              onPressed: () {},
                              icon: Icon(PhosphorIconsRegular.star),
                              label: Text(
                                'Starred',
                                style: TextStyle(
                                    fontFamily: 'Frederik',
                                    fontSize: 20,
                                    // fontWeight: FontWeight.w100,
                                    color: Colors.black),
                              )),
                          SizedBox(
                            height: 8,
                          ),
                          TextButton.icon(
                              onPressed: () {},
                              icon: Icon(PhosphorIconsRegular.engine),
                              label: Text(
                                'Settings',
                                style: TextStyle(
                                    fontFamily: 'Frederik',
                                    fontSize: 20,
                                    // fontWeight: FontWeight.w100,
                                    color: Colors.black),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
