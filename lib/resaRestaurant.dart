import 'resaHome.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';


class ListItem<T> {
bool isSelected = false; //Selection property to highlight or not
T data; //Data of the user
ListItem(this.data); //Constructor to assign the data
}

List<String> menuList = [];
List<String> menuSelectedList = [];
List<DateTime> resaDateList = [];
final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 1, kToday.day);
final kLastDay = DateTime(kToday.year + 5, kToday.month, kToday.day);


var result;

List<String> imgList = [];

//var imgMini = '';

var imgMini;


// var _kEventSource;
//  var kEvents;



List<String> getMenus(menuSnapshotData) {
  //final snapshot = await db.collection('room').get();

  //var twoDList = List<List>.generate(roomSnapshotData.docs.length, (i) => List<dynamic>.generate(2, (index) => null, growable: false), growable: false);

  //print(roomSnapshotData.docs.length);

  List<String> getMenus = [];

  for (final document in menuSnapshotData.docs) {
    var data = document.data();

    getMenus.add(data['name']);
  }

  return getMenus;

}

int getMenuPrice(menuSnapshotData, menuSelected) {

  //print(roomSelected);

  int menuSelectedPrice = 0;

  for (final document in menuSnapshotData.docs) {
    var data = document.data();

    if (data['name'] == menuSelected) {
      menuSelectedPrice = data['price'];
    }

  }

  return menuSelectedPrice;

}

String getMenuCurrency(menuSnapshotData, menuSelected) {

  //print(roomSelected);

  String menuSelectedCurrency = "";

  for (final document in menuSnapshotData.docs) {
    var data = document.data();

    if (data['name'] == menuSelected) {
      menuSelectedCurrency = data['currency'];
    }

  }

  return menuSelectedCurrency;

}

addResa(DateTime? dateStart, DateTime? dateEnd, List<String> menuSelectedListToBook, void onRangeSelectedFunction(DateTime? start, DateTime? end, DateTime focusedDay)) async {
    CollectionReference reservation = FirebaseFirestore.instance.collection('reservation');
    final snapshot1 = await db.collection('menu').get();
    final snapshot2 = await db.collection('client').get();
    List<DocumentReference> menuId = [];
    List<DateTime> dateRange = [];
    List<String> menuSelectedListToBookAndPrice = [];
    late DocumentReference clientId;
    num resaAmountDay = 0;
    String resaCurrency = "";
     

    //if (dateStart != null && dateEnd != null) {

    var date = DateTime(dateStart!.year, dateStart.month, dateStart.day);

    String clientNameEmail = "";
    String clientSurnameEmail = "";

    dateRange.add(date);

    if (dateStart != dateEnd) {
      do {

        date = DateTime(date.year, date.month, date.day + 1);

        dateRange.add(date);

      }
      while (DateTime(date.year, date.month, date.day) != DateTime(dateEnd!.year, dateEnd.month, dateEnd.day));

    }

    for (final document1 in snapshot1.docs) {

      final data1 = document1.data();
      if (resaCurrency == "") {
        resaCurrency = data1['currency'];
      }

      if (menuSelectedListToBook.contains(data1['name'])) {

        menuId.add(db.doc('/menu/${document1.id}'));

        resaAmountDay = resaAmountDay + data1['price'];
        
        menuSelectedListToBookAndPrice.add(data1['name']+ ' (' + data1['price'].toString() + ' $resaCurrency / night)');

      }

    }

    for (final document2 in snapshot2.docs) {

      final data2 = document2.data();

      if (FirebaseAuth.instance.currentUser!.email!.contains(data2['email'])) {

        clientId = db.doc('/client/${document2.id}');
        clientNameEmail = data2['surname'];
        clientSurnameEmail = data2['firstName'];

      }

    }

    var mappingAdded = {
      for (var item in List.generate(dateRange.length, (index) => index)) dateRange[item] : List.generate(menuSelectedListToBook.length,(i) {
          return menuSelectedListToBook[i];
        })
          ..addAll({})
    };




    //DateTime.utc(dateStart.toDate().year,data['dateStart'].toDate().month,data['dateStart'].toDate().day);

    final dateStartEmail = DateFormat.yMMMMd('en_EN').format(dateStart);
    final dateEndEmail = DateFormat.yMMMMd('en_EN').format(dateEnd!);
    final length = dateRange.length-1;

    final resaAmountTotal = resaAmountDay * length;

    await reservation.add({
      'dateStart': dateStart,
      'dateEnd': dateEnd,
      'length': length,
      'menu': menuId,
      'client': clientId,
      'type': 'Restaurant',
      'totalAmount': resaAmountTotal,
      'currency': resaCurrency,
      'status': 'created',
      'publisher': 'client',
      'to': [FirebaseAuth.instance.currentUser!.email],
      'message': {
        'subject': 'Reservation at Heat from $dateStartEmail to $dateEndEmail confirmed',
        'html': '<code><body style="text-align:center; font-family:Verdana;"><h1>Thank you $clientSurnameEmail $clientNameEmail for your reservation !</h1>  <br></br> Please find the details: <br></br> Start date: $dateStartEmail / End date: $dateEndEmail <br></br> Total length of stay: $length nights <br></br> Menus : ${menuSelectedListToBookAndPrice.join(', ')} <br></br><br></br> Total amount: $resaAmountTotal $resaCurrency <br></body></code>',
      }
    });
    
    onRangeSelectedFunction(dateStart, dateEnd, dateStart);

  }

Future<String> getMenuMiniImage(String menuSelectedToGetImage, menuSnapshotData) async {

  imgMini = '';

  for (final document in menuSnapshotData.docs) {
    var data = document.data();
      if (data['name'].toString() == menuSelectedToGetImage) {

        try {

          final image1Url = await storageRef.child(data['image1']).getDownloadURL();

          imgMini = image1Url;

          // Data for "images/island.jpg" is returned, use this as needed.
        } on FirebaseException catch (e) {
        // Handle any errors.
        }
 
      }
  }
  return imgMini;
}

getMenuImages(String menuSelectedToGetImage, menuSnapshotData) async {

  imgList = [];

  for (final document in menuSnapshotData.docs) {
    var data = document.data();
      if (data['name'].toString() == menuSelectedToGetImage) {
        

        try {

          final image1Url = await storageRef.child(data['image1']).getDownloadURL();
          final image2Url = await storageRef.child(data['image2']).getDownloadURL();
          final image3Url = await storageRef.child(data['image3']).getDownloadURL();

          imgList.add(image1Url);
          imgList.add(image2Url);
          imgList.add(image3Url);

          // Data for "images/island.jpg" is returned, use this as needed.
        } on FirebaseException catch (e) {
        // Handle any errors.
        }
 
      }
  }
}

Future<List<String>> getMenuDetails(int index, menuSnapshotData) async {

    //print(menuData.requireData);

    List<String> menuDetailsList = [];
    //print(imgMenu);

          try {

            final starter = menuSnapshotData.docs[index].get('starter');
            final mainCourse = menuSnapshotData.docs[index].get('mainCourse');
            final dessert = menuSnapshotData.docs[index].get('dessert');

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

List<Widget> getListWidget(String menuSelected, List<String> menuDetailsList) {

List<Widget> imageSliders = imgList
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
                    menuDetailsList[imgList.indexOf(item)],
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

class ResaRestaurant extends StatefulWidget {

  final ScrollController mainControllerRestaurant;

  const ResaRestaurant(this.mainControllerRestaurant, {Key? key}) : super(key: key);
  @override
    _ResaRestaurantState createState() => _ResaRestaurantState();
}

class _ResaRestaurantState extends State<ResaRestaurant> {

  final Stream<QuerySnapshot> reservationStream = FirebaseFirestore.instance.collection('reservation').snapshots();
  final Stream<QuerySnapshot> menuStream = FirebaseFirestore.instance.collection('menu').snapshots();

  List<ListItem<String>> listDate = [];
  List<ListItem<String>> listMenu = [];
  //late final ValueNotifier<List<Event>> _bookedRooms;
  late final ValueNotifier<List<DateTime?>> _selectedDate;
  late bool isSelected;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOn; // Can be toggled on/off by longpressing a date

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  DateTime? _rangeStart = DateTime.now();
  DateTime? _rangeEnd = DateTime.now();
  bool buttonenabled = false;

  @override
  void initState() {
    super.initState();

    isSelected = false;
    populateData();

    _selectedDay = _focusedDay;
    //_bookedRooms = ValueNotifier(_getEventsForDay(_selectedDay!));
    _selectedDate = ValueNotifier(_getDatesForDay(_selectedDay!,_selectedDay!));
    menuSelectedList = [];

   
    
  }

  @override
  void dispose() {
    //_bookedRooms.dispose();
    super.dispose();
  }

  void populateData() {
  listMenu = [];
    for (int i = 0; i < 3; i++) {
      listMenu.add(ListItem<String>("item $i"));
    }

  listDate = [];
  for (int i = 0; i < 2; i++) {
    listDate.add(ListItem<String>("item $i"));
  }
  }

  List<DateTime?> _getDatesForDay(DateTime? start,DateTime? end) {
    return [start,end];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {

    if (!isSameDay(_selectedDay, selectedDay)) {
      
      setState(() {
        menuSelectedList = [];
        for (var element in listMenu) { element.isSelected = false; buttonenabled = false; }
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null; 
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
        
      });

      //_bookedRooms.value = _getEventsForDay(selectedDay);
      _selectedDate.value = _getDatesForDay(selectedDay,selectedDay);

    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {

    if ((start != null && end != null) && (start.isAfter(end))) {

      setState(() {
        menuSelectedList = [];
        for (var element in listMenu) { element.isSelected = false; buttonenabled = false; }
        _selectedDay = focusedDay;
        _focusedDay = focusedDay;
        _rangeStart = start;
        _rangeEnd = start;
        _rangeSelectionMode = RangeSelectionMode.toggledOn;
        
      });

      // `start` or `end` could be null
      if (start != null && end != null) {
        // var a = _getEventsForRange(start, start);

        // var sorted = a;

        // sorted.sort((a, b) => a.room.compareTo(b.room));

        // var seen = Set<String>();
        // List<Event> uniquelist = sorted.where((event) =>
        //     seen.add(event.room)).toList();

        // _bookedRooms.value = uniquelist;
        _selectedDate.value = _getDatesForDay(start, start);
      } else if (start != null) {
        //_bookedRooms.value = _getEventsForDay(start);
        _selectedDate.value = _getDatesForDay(start, start);
      } else if (end != null) {
        //_bookedRooms.value = _getEventsForDay(end);
        _selectedDate.value = _getDatesForDay(end, end);
      }
    }
    else {
      setState(() {
        menuSelectedList = [];
        for (var element in listMenu) { element.isSelected = false; buttonenabled = false; }
        _selectedDay = focusedDay;
        _selectedDay = focusedDay;
        _focusedDay = focusedDay;
        _rangeStart = start;
        _rangeEnd = end;
        _rangeSelectionMode = RangeSelectionMode.toggledOn;
      });
      if (start != null && end != null) {
        // var a = _getEventsForRange(start, end);

        // var sorted = a;

        // sorted.sort((a, b) => a.room.compareTo(b.room));

        // var seen = Set<String>();
        // List<Event> uniquelist = sorted.where((event) =>
        //     seen.add(event.room)).toList();

        // _bookedRooms.value = uniquelist;
        _selectedDate.value = _getDatesForDay(start, end);
      } else if (start != null) {
        //_bookedRooms.value = _getEventsForDay(start);
        _selectedDate.value = _getDatesForDay(start, start);
      } else if (end != null) {
        //_bookedRooms.value = _getEventsForDay(end);
        _selectedDate.value = _getDatesForDay(end, end);
      }
    }

  }

  void updateColorAfterSelection(int index, String menuSelected) {

    if (listMenu[index].isSelected == true) {
      ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(SnackBar(content: Text('$menuSelected already selected'), duration: const Duration(milliseconds: 1000)));
    }
    else {
    setState(() {

      listMenu[index].isSelected = true;
      menuSelectedList.add(menuSelected);
      buttonenabled = true;
    });
    }
  }

  Future<DateTime?> _selectDate(BuildContext context, DateTime? dateSelected) async {
    var datePicked = await DatePicker.showSimpleDatePicker(
      context,
      initialDate: dateSelected,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      dateFormat: "dd-MMMM-yyyy",
      locale: DateTimePickerLocale.en_us,
      looping: true,
    );

    return datePicked;
  }

  Widget _getListDateContainer(BuildContext context, int index, List<DateTime?> dateSelected) {

    var a =['Start : ','End : '];

    return InkWell(
        onTap: () async {
       

          dateSelected[index] = await _selectDate(context,dateSelected[index]);

          setState(() {
            listDate[index].isSelected = !listDate[index].isSelected;
          });
        },
        child: Container(
            padding: const EdgeInsets.all(6.0),
            //width: 190,
            margin: const EdgeInsets.symmetric(
              horizontal: 7.0,
              // vertical: 4.0,
            ),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(12.0),
              //color: const Color.fromARGB(255, 200, 229, 255),
              color: Colors.indigo.shade400,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_right_outlined, color: Colors.white),
                Text(a[index],style: const TextStyle(color: Colors.white)),
                Text('${dateSelected[index].toString().replaceFirstMapped(' 00:00:00.000Z', (match) => '').substring(8,10)} / ${dateSelected[index].toString().replaceFirstMapped(' 00:00:00.000Z', (match) => '').substring(5,7)} / ${dateSelected[index].toString().replaceFirstMapped(' 00:00:00.000Z', (match) => '').substring(0,4)}', style: const TextStyle(color: Colors.white))
              ])
        )
    );
  }

  Widget _getListItemTile(BuildContext context, int index, String menuSelected, menuSnapshot, snapshotImage, ScrollController mainScrollController) {

    var key = GlobalKey();

    //print(getRooms(roomSnapshot.requireData));

    //var twoDList = List<List>.generate(getRooms(roomSnapshot.requireData).length, (i) => List<dynamic>.generate(2, (index) => null, growable: false), growable: false);

    var menuPrice = getMenuPrice(menuSnapshot.requireData, menuSelected);

    var menuCurrency = getMenuCurrency(menuSnapshot.requireData, menuSelected);

  //twoDList[0][1] = "deneme";

  //print(twoDList);

    return InkWell(
      onTap: () {

        Scrollable.ensureVisible(key.currentContext!, alignment: 0.5, duration: const Duration(seconds: 1));

        if (listMenu[index].isSelected == true) {

          // ScaffoldMessenger.of(context)
          //   ..removeCurrentSnackBar()
          //   ..showSnackBar(SnackBar(content: Text('$roomSelected retirée'), duration: const Duration(milliseconds: 1000)));
          

        setState(() {

          listMenu[index].isSelected = !listMenu[index].isSelected;
          menuSelectedList.remove(menuSelected);
        
          var result = listMenu.any((element) => element.isSelected);
          if (result == false) {
            buttonenabled = false;
          }

        });
        }
        else {

          // ScaffoldMessenger.of(context)
          //   ..removeCurrentSnackBar()
          //   ..showSnackBar(SnackBar(
          //     content: Text('$roomSelected sélectionnée'),             
          //     duration: const Duration(milliseconds: 1000)
          // ));
          

          setState(() {

            listMenu[index].isSelected = true;

            menuSelectedList.add(menuSelected);

            buttonenabled = true;

            //print(menuSelectedList);

            //_mainController.jumpTo(_mainController.positions.last.maxScrollExtent);
            //if (index > 2) {

            //scrollController.animateTo(scrollController.positions.last.maxScrollExtent, duration: Duration(seconds: 1), curve: Curves.ease);

            //scrollController.animateTo(index * 90, duration: Duration(seconds: 1), curve: Curves.ease);
            //}

            

            mainScrollController.animateTo(mainScrollController.positions.last.maxScrollExtent, duration: const Duration(seconds: 1), curve: Curves.ease);
            //Duration(seconds: 1), Curves.ease
            
          });
        }
      },
      child: Container(
        key: key,
        //margin: EdgeInsets.symmetric(vertical: 4),
        height: 90,
        margin: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 4.0,
        ),
        //color: list[index].isSelected ? Colors.red[100] : Color.fromARGB(255, 236, 249, 221),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(snapshotImage.toString()),
            alignment: Alignment.center,
            fit: BoxFit.fitWidth,
            opacity: 0.5
            ),
          border: Border.all(),
          borderRadius: BorderRadius.circular(12.0),
          color: listMenu[index].isSelected ? Colors.red[100] : const Color.fromARGB(255, 221, 248, 249),
          //color: listMenu[index].isSelected ? Colors.red[100] : const Color.fromARGB(255, 236, 249, 221),
        //  color: isSelected ? Colors.blue : null,
        ),
        child:
          Center(
            child: 
            ListTile(

            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("$menuSelected : $menuPrice $menuCurrency", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                DetailsButton(index, menuSelected, updateColorAfterSelection, menuSnapshot),
            ]),
            
          ),

          )
      )
                              
      );
}

  @override
  Widget build(BuildContext context) {
    //var pixelRatio = MediaQuery.of(context).devicePixelRatio;
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

        //print(pixelRatio);

        if (menuSnapshot.hasError) {
          return const Text('Something went wrong');
        }
        if (!menuSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        //resaDateList = getResaDate(reservationSnapshot.requireData);
        //resaMapping = getResa(reservationSnapshot.requireData, roomSnapshot.requireData);
        menuList = getMenus(menuSnapshot.requireData);

        //print(menuList);

        final ScrollController scrollControllerList = ScrollController();

        return Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child:
              Container(
                padding: const EdgeInsets.only(right: 15.0),
                //margin: const EdgeInsets.only(bottom: 15.0),
                //height: 340,
                child:
                TableCalendar<String>(
                  locale: 'en_EN',           
                  firstDay: kFirstDay,
                  lastDay: kLastDay,
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) =>isSameDay(day, _selectedDay),
                  rangeStartDay: _rangeStart,
                  rangeEndDay: _rangeEnd,
                  calendarFormat: _calendarFormat,
                  rangeSelectionMode: _rangeSelectionMode,
                  //eventLoader:_getEventsForDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  rowHeight: MediaQuery.of(context).size.height * 0.045,
                  calendarStyle: const CalendarStyle(
                    // Use `CalendarStyle` to customize the UI
                    outsideDaysVisible: false,
                    isTodayHighlighted: false,
                    markersAlignment: Alignment.bottomRight,
                    defaultTextStyle: TextStyle(fontSize: 15)
                    //weekendDecoration: BoxDecoration(
                    //  shape: BoxShape.rectangle,
                    //  color: Color.fromARGB(255, 239, 241, 236),
                      //color: Color.fromARGB(255, 236, 249, 221),
                    //),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false
                  ),
                  onDaySelected: _onDaySelected,
                  onRangeSelected: _onRangeSelected,
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (BuildContext context, DateTime day, DateTime focusedDay) {
         
                    },
                    markerBuilder: (BuildContext context, date, events) {
                    if (menuList.length - events.length == 0) {
                      return Container(

                      );
                    }
                    else {
                    return Container(
                      width: 17,
                      height: 17,
                      alignment: Alignment.center,
                      // decoration: const BoxDecoration(
                      //   shape: BoxShape.circle,
                      //   color: Colors.green,
                      // ),
                      //child: Text(
                        //'${roomList.length - events.length}',
                       // style: const TextStyle(color: Colors.white, fontSize: 12),
                      //),
                    );
                    }
                    }
                  ),
                ),
              )
          ),
          
          //const SizedBox(height: 8.0),

          // Flexible(
          //   flex: 1,
          //   child:
          //   Container(child: 

          //     const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          //       Text('Dates :'),
          //     ]),
          //   )
          // ),

          Expanded(
            flex: 1,
            child:
            ValueListenableBuilder<List<DateTime?>>(
                valueListenable: _selectedDate,
                builder: (context, value, _) {
            
                  final List<DateTime?> result = [_rangeStart,_rangeEnd];
            
                  for (int i = 0; i < result.length; i++) {
                    listDate.add(ListItem<String>("item $i"));
                  }
            
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      return _getListDateContainer(context, index, value);
            
                    },
                  );
                },
              )
          ),

          //const SizedBox(height: 8.0),
          Expanded(
            flex: 1,
            child:
            Container(
              padding: const EdgeInsets.only(top: 15.0),
              child:
              const Text('Click to select', style: TextStyle(fontStyle: FontStyle.italic))
          )
          ),
          
          // SizedBox(
          //   height:175,
          //   child:
          Expanded(
           flex: 6,
           child: Scrollbar(
                      thumbVisibility: true,
                      thickness: 10.0,
                      controller: scrollControllerList,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: menuList.length,
                        controller: scrollControllerList,
                        itemBuilder: (context, index) {
                          for (int i = 0; i < menuList.length; i++) {
                            listMenu.add(ListItem<String>("item $i"));
                          };
                          return FutureBuilder<String>(
                            future: getMenuMiniImage(menuList[index].toString(), menuSnapshot.requireData),
                            builder: (context, AsyncSnapshot<String> snapshot){
                              if (snapshot.hasData) {
                          //getRoomMiniImage(result[index].toString(), roomSnapshot.requireData);
                          //print(result[index]);
                          //getRoomImages(result[index].toString(), roomSnapshot.requireData);
                                return _getListItemTile(context, index, menuList[index].toString(), menuSnapshot, snapshot.data, widget.mainControllerRestaurant);
                              }
                              else {
                                return const CircularProgressIndicator();
                              }
                        },
                    );
                        }
                    )
                    )
                    
          ),
          //const SizedBox(height: 10.0),
          Expanded(
            flex: 1,
            child:
            Container(
              //padding: const EdgeInsets.only(top: 15.0),
              child:
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Selected menus : '),
                  Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: Text(
                        '${menuSelectedList.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  //Text('${roomSelectedList.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, backgroundColor: Color.fromARGB(255, 240, 199, 196))),
              ])
          )
          ),

          //const SizedBox(height: 10.0),
          Expanded(
            flex: 1,
            child:
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                width: MediaQuery.of(context).size.width * 0.7,
                child:
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade400,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.black.withOpacity(0.38),
                      disabledBackgroundColor: Colors.black.withOpacity(0.12)),
                    // ButtonStyle(
                    //   backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo.shade400),
                    //   foregroundColor: MaterialStateProperty.all<Color>(Colors.white)),
                      
                    onPressed:buttonenabled?(){ //if buttonenabled == true then pass a function otherwise pass "null"
                        if(_rangeStart == null && _rangeEnd == null) {
                          addResa(_selectedDay, _selectedDay, menuSelectedList, _onRangeSelected);
                        }
                        else if (_rangeEnd == null) {
                          _rangeEnd = _rangeStart;
                          addResa(_rangeStart, _rangeEnd, menuSelectedList, _onRangeSelected);
                        }
                        else {
                          addResa(_rangeStart, _rangeEnd, menuSelectedList, _onRangeSelected);
                        }
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(const SnackBar(content: Text('Reservation confirmed'),duration: Duration(milliseconds: 1000)));
                        

                        menuSelectedList = [];

                        //listRoom[0].isSelected == true;
                        setState(() {
                          for (var j = 0; j < listMenu.length; j++) {
                            listMenu[j].isSelected = false;
                          }
                        });

                    }:null,
                    child: const Text('Book'),
                  )
              )
            )
             
        ],
      );
      }
      );
    }
    );
  }
}

class DetailsButton extends StatefulWidget {

  final String menuSelected;
  //final List<ListItem<String>> list;
  final dynamic updateContainerColor;
  final int index;
  final dynamic menuSnapshot;
  const DetailsButton(this.index, this.menuSelected, this.updateContainerColor, this.menuSnapshot, {super.key});

  @override
  State<DetailsButton> createState() => _DetailsButtonState();
}

class _DetailsButtonState extends State<DetailsButton> {

  late List<String> menuDetailsList;

  
  @override
  Widget build(BuildContext context) {
    
    return ElevatedButton(
      onPressed: () async {
        
        await getMenuImages(widget.menuSelected, widget.menuSnapshot.requireData);
        menuDetailsList = await getMenuDetails(widget.index, widget.menuSnapshot.requireData);
        //globals.widgetlist = getListWidget(widget.room_selected);

        //print(menuDetailsList);

        _navigateAndDisplaySelection(menuDetailsList);
      },
      child: const Text('Details'),
    );
  }

  // A method that launches the SelectionScreen and awaits the result from
  // Navigator.pop.
  Future<void> _navigateAndDisplaySelection(List<String> menuDetailsList) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CarouselWithIndicatorDemo(widget.menuSelected, menuDetailsList)),
    );

    // When a BuildContext is used from a StatefulWidget, the mounted property
    // must be checked after an asynchronous gap.
    if (!mounted) return;

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    
    if (result != null) {
    
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$result'),duration: const Duration(milliseconds: 1000)));
      
    
    widget.updateContainerColor(widget.index, widget.menuSelected);
    }
      
  }
}

class CarouselWithIndicatorDemo extends StatefulWidget {

  final String menuSelected;
  final List<String> menuDetailsList;
  const CarouselWithIndicatorDemo(this.menuSelected, this.menuDetailsList, {super.key});


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
            items: getListWidget(widget.menuSelected, widget.menuDetailsList),
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
          children: imgList.asMap().entries.map((entry) {
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
                  Navigator.pop(context, '${widget.menuSelected} selected');
                },
                child: const Text('Select'),
              ),
      ]),
    )
    );
  }
}

