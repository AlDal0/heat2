import 'package:heat/resaRoom.dart';
import 'package:heat/resaRestaurant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
final storageRef = FirebaseStorage.instanceFor(bucket: "gs://heat-e9529.appspot.com").ref();

ScrollController _mainControllerRoom = ScrollController();
ScrollController _mainControllerRestaurant = ScrollController();

class ResaHome extends StatelessWidget {
  const ResaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Booking'),
            toolbarHeight: 30,
            scrolledUnderElevation: 0,
            bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.bed),
              ),
              Tab(
                icon: Icon(Icons.local_restaurant),
              ),
            ],
          ),
            ),
          body:  TabBarView(
          children: <Widget>[
            SingleChildScrollView(
              controller: _mainControllerRoom,
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height,
                child: Center(child: ResaRoom(_mainControllerRoom))
              )
            ),
            SingleChildScrollView(
              controller: _mainControllerRestaurant,
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height,
                child: Center(child: ResaRestaurant(_mainControllerRestaurant))
              )
            ),
          ]
          ),
          drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(
              height: 200,
              width: double.infinity,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  //color: Colors.blue,
                  image: DecorationImage(
                    image: AssetImage('images/PXL_20230827_183250894.MP~2.jpg'),
                    //fit: BoxFit.fill
                    ), 
                ),
                child: Text(''),
              ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                      onTap: () {

                        Navigator.pushNamed(context, '/home');
                        
                      },
              ),
              ListTile(
                leading: const Icon(Icons.account_box),
                title: const Text('My Reservations'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pushNamed(context, '/myResaHome');
                },
              ),
              ListTile(
                leading: const Icon(Icons.newspaper),
                title: const Text('News'),
                      onTap: () {

                        Navigator.pushNamed(context, '/news');
                        
                      },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Booking'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer

                  Navigator.pushNamed(context, '/resaHome');
                
                  //Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_restaurant),
                title: const Text('Menus'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pushNamed(context, '/menus');
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Log out'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pushNamedAndRemoveUntil(context,'/login', (_) => false);
                },
              )
            ],
          ),
        ),
        )
    );
  }
}

