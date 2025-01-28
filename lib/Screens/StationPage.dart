import 'package:app_001/Screens/DataPages/ChartManager.dart';
import 'package:app_001/Screens/DataPages/CurrentData.dart';
import 'package:app_001/Screens/DataPages/CurrentDataPretty.dart';
import 'package:app_001/Screens/Forcast.dart';
import 'package:app_001/Screens/map.dart';
import 'package:flutter/material.dart';

class HydroStationPage extends StatefulWidget {
  final StationMarker station;
  final int hydroBool;
  const HydroStationPage({super.key,required this.station,required this.hydroBool});

  @override
  State<HydroStationPage> createState() => _HydroStationPageState();
}

class _HydroStationPageState extends State<HydroStationPage> {
  late List<Widget> _pages;

  @override
  void initState(){
    //set _pages list here to pass station Id to them with constructor injection
    setPages(widget.station.id,widget.hydroBool);
    super.initState();
  }

/*NOTE: Below sets the pages for onTap of station markers
    They are seperated by agri and hydromets. Add as required
    Swipe functions and marker are generated */

  void setPages(String id,int hydroBool){ //setting pages for viewing agrimet
    if (hydroBool == 1){
    _pages = [
      Forcast(lat: widget.station.lat, lng: widget.station.lon),   //setting pages 
      CurrentDataPretty(id: id),
      Chartmanager(id: id),
      //PhotoPage(id: id),
      
      
  ];
    } else{
      _pages = [
      Forcast(lat: widget.station.lat, lng: widget.station.lon),
      CurrentDataPretty(id: id),
      Chartmanager(id: id),
  ];
    }
    
  }

  final _pageController = PageController(
      initialPage: 1,  //initial page for the marker
      viewportFraction: 1,
    );

  int _activePage = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.station.name,
        style: TextStyle(fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.onPrimaryFixed),),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary
        ),
        backgroundColor: (widget.station.subNetwork == 'HydroMet') ?Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
      ),
      body: Stack(
        children: [
          PageView.builder(
        controller: _pageController,
        onPageChanged: (int page){
          setState(() {
            _activePage = page;
          });
        },
        itemCount: _pages.length,
        itemBuilder: (BuildContext context, int index){
          return _pages[index % _pages.length];
        },
      ),

        Positioned(
          bottom: 5,
          left: 125,
          right: 125,
          top: 725,
          child: Container(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(
                _pages.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: InkWell(
                      onTap: (){
                        _pageController.animateToPage(index,
                         duration: const Duration(milliseconds: 300),
                         curve: Curves.easeIn);
                      },
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: _activePage == index
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  )
              )
            ),
          ))
        ],
      )


    );
  }
}