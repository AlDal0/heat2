import 'package:flutter/material.dart';
import 'news.dart';
import 'resaRoom.dart';
import 'resaMenu.dart';
import 'myReservation.dart';

class Accueil extends StatelessWidget {
  const Accueil({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body:
        Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50)
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Actualite()),
                );
              },
              child: const Text('News'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50)
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ResaRoomHome()),
                );
              },
              child: const Text('Room booking'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50)
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ResaMenuHome()),
                );
              },
              child: const Text('Menus'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50)
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MesReservationsHome()),
                );
              },
              child: const Text('My Reservations'),
            ),
          ]
        ),
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
                Navigator.pushNamed(context, '/reservations');
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
              title: const Text('Room booking'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer

                Navigator.pushNamed(context, '/resaRoom');
               
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
     
    );
  }
}