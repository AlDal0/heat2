import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


class ResaRestauration extends StatelessWidget {
  const ResaRestauration({super.key});

  List<Card> _buildGridCards(int count) {
  List<Card> cards = List.generate(
    count,
    (int index) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 18.0 / 11.0,
              child: Image.asset('images/PXL_20230827_183250894.MP~2.jpg'),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Title'),
                  //SizedBox(height: 8.0),
                  //Text('Secondary Text'),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
  return cards;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restauration'),
      ),
     body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        childAspectRatio: 8.0 / 9.0,
        //children: _buildGridCards(10),
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
              title: const Text('Accueil'),
                    onTap: () {

                      Navigator.pushNamed(context, '/accueil');
                      
                    },
            ),
            ListTile(
              leading: const Icon(Icons.account_box),
              title: const Text('Mes Réservations'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pushNamed(context, '/mesreservations');
              },
            ),
            ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text('Actualité'),
                    onTap: () {

                      Navigator.pushNamed(context, '/actualite');
                      
                    },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Chambres'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer

                Navigator.pushNamed(context, '/resachambres');
               
                //Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_restaurant),
              title: const Text('Restauration'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pushNamed(context, '/resarestauration');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
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
