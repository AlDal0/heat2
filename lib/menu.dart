import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
final storageRef = FirebaseStorage.instanceFor(bucket: "gs://heat-e9529.appspot.com").ref();

class MenuHome extends StatelessWidget {
  const MenuHome({super.key});

  @override
  Widget build(BuildContext context) {

    //print(FirebaseAuth.instance.currentUser);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Menus'),
          scrolledUnderElevation: 0),
        body: const Menus(),
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

class Menus extends StatefulWidget {

  const Menus({Key? key}) : super(key: key);
  @override
    _MenusState createState() => _MenusState();
}

class _MenusState extends State<Menus> {
  
  final Stream<QuerySnapshot> menuStream = FirebaseFirestore.instance.collection('menu').orderBy('name').snapshots();

  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: menuStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> menuSnapshot) {
            
                if (menuSnapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (!menuSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                final menuData = menuSnapshot.requireData;

                final ScrollController scrollController = ScrollController();

                return Scrollbar(
                thumbVisibility: true,
                thickness: 8.0,
                controller: scrollController,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: menuData.size,
                  controller: scrollController,
                  //restorationId: 'list_demo_list_view',
                  //padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
       
                    return MenuContent(context: context, index: index, menuData: menuData);
                  }
                )
                );
                      
                    }
                );
                
              }
}

Future<String> getMenuImagesMini(int index, menuData) async {

    String menuImageMini = '';

          try {

            final image1Url = await storageRef.child(menuData.docs[index].get('image1')).getDownloadURL();
            
            menuImageMini = image1Url;

          } on FirebaseException catch (e) {
          // Handle any errors.
          } 

      return menuImageMini;
}

Future<List<String>> getMenuImages(int index, menuData) async {

    List<String> menuImagesList = [];
    //print(imgMenu);

          try {

            final image1Url = await storageRef.child(menuData.docs[index].get('image1')).getDownloadURL();
            final image2Url = await storageRef.child(menuData.docs[index].get('image2')).getDownloadURL();
            final image3Url = await storageRef.child(menuData.docs[index].get('image3')).getDownloadURL();

            menuImagesList.add(image1Url);
            menuImagesList.add(image2Url);
            menuImagesList.add(image3Url);

          } on FirebaseException catch (e) {
          // Handle any errors.
          } 

      //}
      
      return menuImagesList;
}

Future<List<String>> getMenuDetails(int index, menuData) async {

    List<String> menuDetailsList = [];
    //print(imgMenu);

          try {

            final starter = menuData.docs[index].get('starter');
            final mainCourse = menuData.docs[index].get('mainCourse');
            final dessert = menuData.docs[index].get('dessert');

            menuDetailsList.add(starter);
            menuDetailsList.add(mainCourse);
            menuDetailsList.add(dessert);

          } on FirebaseException catch (e) {
          // Handle any errors.
          } 

      //}
      //print(menuDetailsList);
      return menuDetailsList;
}

class MenuContent extends StatelessWidget {
  const MenuContent({super.key, required this.context, required this.index, required this.menuData});

  final BuildContext context;
  final int index;
  final QuerySnapshot<Object?> menuData;

  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final descriptionStyle = theme.textTheme.titleMedium!;

    
    return FutureBuilder<List<String>>(
      future: getMenuImages(index, menuData),
      builder: (context, AsyncSnapshot<List<String>> snapshot1){
        if (snapshot1.hasData) {
        return FutureBuilder<String>(
          future: getMenuImagesMini(index, menuData),
          builder: (context, AsyncSnapshot<String> snapshot2){
            if (snapshot2.hasData) {
              return FutureBuilder<List<String>>(
                future: getMenuDetails(index, menuData),
                builder: (context, AsyncSnapshot<List<String>> snapshot3){
                  if (snapshot3.hasData) {
                    return SafeArea(
                      top: false,
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 350,
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () async {
                                    _navigateAndDisplaySelection(context, index, snapshot1, menuData.docs[index].get('name'), snapshot3);
                                  },
                                  splashColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                                  highlightColor: Colors.transparent,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 200,
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                // In order to have the ink splash appear above the image, you
                                                // must use Ink.image. This allows the image to be painted as
                                                // part of the Material and display ink effects above it. Using
                                                // a standard Image will obscure the ink splash.
                                                child: Ink.image(
                                                  image: CachedNetworkImageProvider(snapshot2.data.toString()),
                                                  fit: BoxFit.cover,
                                                  child: Container(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Description and share/explore buttons.
                                        Semantics(
                                          container: true,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                            child: DefaultTextStyle(
                                              softWrap: false,
                                              overflow: TextOverflow.ellipsis,
                                              style: descriptionStyle,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // This array contains the three line description on each card
                                                  // demo.
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 8),
                                                    child: Text(
                                                      //'Rooms : ${tempList.join(', ')}',
                                                      '${menuData.docs[index].get('name')} - ${menuData.docs[index].get('price')} ${menuData.docs[index].get('currency')}',
                                                      style: descriptionStyle.copyWith(color: Colors.black54),
                                                    ),
                                                  ),
                                                  Text('${menuData.docs[index].get('description')}'),
                                                  //Text(
                                                  //    //'Rooms : ${tempList.join(', ')}',
                                                  //    '${menuData.docs[index].get('price')}',
                                                  //    style: descriptionStyle.copyWith(color: Colors.black54),
                                                  //  )                              
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                )
                              )
                            )
                          ]
                    )
                    )
                    );
            } else {
              return const CircularProgressIndicator();
            }
            }
          );
          } else {
              return const CircularProgressIndicator();
          }
          }
        );
        }
        else {
              return const CircularProgressIndicator();
        }
      }
    );
  }
}

Future<void> _navigateAndDisplaySelection(BuildContext context, int index, AsyncSnapshot<List<String>> menuImages, String menuSelected, AsyncSnapshot<List<String>> menuDetails) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CarouselWithIndicatorDemo(index, menuSelected, menuImages, menuDetails)),
    );

    
      
}

class CarouselWithIndicatorDemo extends StatefulWidget {
  
  final int index;
  final String menuSelected;
  final AsyncSnapshot<List<String>> menuImages;
  final AsyncSnapshot<List<String>> menuDetails;

  const CarouselWithIndicatorDemo(
    this.index,
    this.menuSelected,
    this.menuImages,
    this.menuDetails,
    {super.key}
    );


  @override
  State<StatefulWidget> createState() {
    return _CarouselWithIndicatorState();
  }
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicatorDemo> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menuSelected),
        scrolledUnderElevation: 0),
      body: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        //Expanded(
          CarouselSlider(
            items: getListWidget(widget.index, widget.menuSelected, widget.menuImages, widget.menuDetails),
            carouselController: _controller,
            options: CarouselOptions(
                autoPlay: false,
                enlargeCenterPage: true,
                aspectRatio: 2,
                viewportFraction: 1,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                }),
          ),
       // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.menuImages.data!.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: Container(
                width: 12.0,
                height: 12.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black)
                        .withOpacity(_current == entry.key ? 0.9 : 0.4)),
              ),
            );
          }).toList(),
        ),
        ElevatedButton(
                onPressed: () {
                  // Close the screen and return "Yep!" as the result.
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
      ]),
    )
    );
  }
}

List<Widget> getListWidget(int index, String menuSelected, AsyncSnapshot<List<String>> menuImages, AsyncSnapshot<List<String>> menuDetails) {

List<Widget> imageSliders = menuImages.data!
    .map((item) => Container(
      margin: const EdgeInsets.all(5.0),
      child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          child: Stack(
            children: <Widget>[
              Image.network(item, fit: BoxFit.cover, width: 1000.0),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(200, 0, 0, 0),
                        Color.fromARGB(0, 0, 0, 0)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  child: Text(
                    menuDetails.data![menuImages.data!.indexOf(item)],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )),
    ))
    .toList();
    return imageSliders;
}