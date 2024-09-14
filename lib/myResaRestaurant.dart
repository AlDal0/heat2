import 'myResaHome.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';

String imgList = '';

class MyResaRestaurant extends StatefulWidget {

  //final ScrollController mainControllerRestaurant;

  //const MyResaRestaurant(this.mainControllerRestaurant, {Key? key}) : super(key: key);
  const MyResaRestaurant({Key? key}) : super(key: key);
  @override
    _MyResaRestaurantState createState() => _MyResaRestaurantState();
}

class _MyResaRestaurantState extends State<MyResaRestaurant> {

  final Stream<QuerySnapshot> clientStream = FirebaseFirestore.instance.collection('client').where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots();
  
  final Stream<QuerySnapshot> menuStream = FirebaseFirestore.instance.collection('menu').snapshots();

  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: clientStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> clientSnapshot) {
        if (clientSnapshot.hasError) {
                  return const Text('Something went wrong');
                }
        if (!clientSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
        
        DocumentReference<Map<String, dynamic>> clientRef;
        final clientData = clientSnapshot.requireData;

        clientRef = db.collection('client').doc(clientData.docs[0].id);

        final Stream<QuerySnapshot> reservationStream = FirebaseFirestore.instance.collection('reservation').where('client', isEqualTo: clientRef).where('type', isEqualTo: 'Restaurant').snapshots();

        return StreamBuilder<QuerySnapshot>(
          stream: reservationStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> reservationSnapshot) {

            if (reservationSnapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (!reservationSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }


            return StreamBuilder<QuerySnapshot>(
              stream: menuStream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> menuSnapshot) {
            
                if (menuSnapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (!menuSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                final reservationData = reservationSnapshot.requireData;
                final menuData = menuSnapshot.requireData;

                final ScrollController scrollController = ScrollController();

                return Scrollbar(
                thumbVisibility: true,
                thickness: 8.0,
                controller: scrollController,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: reservationData.size,
                  controller: scrollController,
                  //restorationId: 'list_demo_list_view',
                  //padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    
                      List<String> tempList = [];

                      for (var j = 0; j < reservationData.docs[index].get('menu').length; j++) {

                        for (var element in menuData.docs) {
                          if (element.id == reservationData.docs[index].get('menu')[j].toString().replaceAllMapped('DocumentReference<Map<String, dynamic>>(menu/', (match) => '').replaceAllMapped(')', (match) => '')) {
                            tempList.add(element.get('name'));
                          }
                        }
                      }
                      
                      return ResaContent(context: context,index: index,reservationData: reservationData, menuData: menuData, tempList: tempList);
                    }
                )
                );
              },
            );
          },
        );
    }
    );
  }

}

Future<String> getMenuImagesMini(String menuSelectedToGetImage, menuSnapshotData) async {

  imgList = '';

  for (final document in menuSnapshotData.docs) {
    var data = document.data();

      if (data['name'].toString() == menuSelectedToGetImage) {

        try {

          final image1Url = await storageRef.child(data['image1']).getDownloadURL();

          imgList = image1Url;

        } on FirebaseException catch (e) {
        // Handle any errors.
        }
 
      }

    }
    return imgList;
}

Future<Map<String, List<String>>> getMenuImages(menuData) async {

    Map<String, List<String>> menuImagesList = {};

    for (var element in menuData.docs) {

          try {

            final image1Url = await storageRef.child(element.get('image1')).getDownloadURL();
            final image2Url = await storageRef.child(element.get('image2')).getDownloadURL();
            final image3Url = await storageRef.child(element.get('image3')).getDownloadURL();

            menuImagesList.addAll({element.get('name'):[image1Url,image2Url,image3Url]});

          } on FirebaseException catch (e) {
          // Handle any errors.
          }
    }
      
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

List<Widget> getListWidget(int index, String menuSelected, AsyncSnapshot<Map<String, List<String>>> menuImages, AsyncSnapshot<List<String>> menuDetails) {

List<Widget> imageSliders = menuImages.data![menuSelected.toString()]!
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
                    menuDetails.data![menuImages.data![menuSelected.toString()]!.indexOf(item)],
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

class ResaContent extends StatelessWidget {
  const ResaContent({super.key, required this.context, required this.index, required this.reservationData, required this.menuData, required this.tempList});

  final BuildContext context;
  final int index;
  final QuerySnapshot<Object?> reservationData;
  final QuerySnapshot<Object?> menuData;
  final List<String> tempList;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final titleStyle = theme.textTheme.headlineSmall!.copyWith(
    //   color: Colors.white,
    // );
    final descriptionStyle = theme.textTheme.titleMedium!;

    final tsdateStart = DateFormat.yMMMMd('en_US').format(reservationData.docs[index].get('dateStart').toDate());
    final tsdateEnd = DateFormat.yMMMMd('en_US').format(reservationData.docs[index].get('dateEnd').toDate());

    
    return FutureBuilder<Map<String, List<String>>>(
      future: getMenuImages(menuData),
      builder: (context, AsyncSnapshot<Map<String, List<String>>> snapshot1){
        if (snapshot1.hasData) {
          return FutureBuilder<String>(
            future: getMenuImagesMini(tempList[0].toString(), menuData),
            builder: (context, AsyncSnapshot<String> snapshot2){
              if (snapshot2.hasData) {
                return FutureBuilder<List<String>>(
                  future: getMenuDetails(index, menuData),
                  builder: (context, AsyncSnapshot<List<String>> snapshot3){
                  if (snapshot3.hasData) {
                    tempList.sort();
                  
                    return SafeArea(
                      top: false,
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 400,
                              child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 184,
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
                                                'Reservation : ${reservationData.docs[index].id}',
                                                style: descriptionStyle.copyWith(color: Colors.black54),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 4),
                                              child: Text(
                                                'Start : $tsdateStart',
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 4),
                                              child: Text(
                                                'End : $tsdateEnd',
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 0),
                                              child: Text(
                                                'Total length : ${reservationData.docs[index].get('length')}',
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 4),
                                              child: Row(children: [
                                                const Text('Menus: '),
                                                for (var i = 0; i < 3; i++)
                                                  if (i < tempList.length) 
                                                    TextButton(
                                                      onPressed: () async {

                                                        _navigateAndDisplaySelection(context, index, snapshot1, menuData.docs[index].get('name'), snapshot3);
                                                      },
                                                      style: TextButton.styleFrom(
                                                        textStyle: const TextStyle(fontSize: 15),
                                                      ),
                                                      child: Text(tempList[i]),
                                                    )
                                              ]),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 0),
                                              child: Text(
                                                'Total amount : ${reservationData.docs[index].get('totalAmount')} EUR',
                                                style: const TextStyle(fontWeight:FontWeight.bold)
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                              )
                            )
                          ]
                    )
                    )
                    );
                  }
                  else {
                    return const CircularProgressIndicator();
                  }
                }
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
}

Future<void> _navigateAndDisplaySelection(BuildContext context, int index, AsyncSnapshot<Map<String, List<String>>> menuImages, String menuSelected, AsyncSnapshot<List<String>> menuDetails) async {
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
  final AsyncSnapshot<Map<String, List<String>>> menuImages;
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
  final CarouselSliderController _controller = CarouselSliderController();

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
          children: widget.menuImages.data![widget.menuSelected.toString()]!.asMap().entries.map((entry) {
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

