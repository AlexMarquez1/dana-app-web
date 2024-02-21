import 'package:flutter/material.dart';

class AsignarEdicion extends StatefulWidget {
  @override
  State<AsignarEdicion> createState() => _AsignarEdicionState();
}

class _AsignarEdicionState extends State<AsignarEdicion>
    with SingleTickerProviderStateMixin {
  TabController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = new TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('TestProject'),
      ),
      body: new ListView(
        children: <Widget>[
          new Card(
            child: new ListTile(
              title: const Text('Some information'),
            ),
          ),
          new Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: TabBar(
              controller: _controller,
              tabs: [
                Tab(
                  icon: const Icon(Icons.home),
                  text: 'Address',
                ),
                Tab(
                  icon: const Icon(Icons.my_location),
                  text: 'Location',
                ),
              ],
            ),
          ),
          Container(
            height: 80.0,
            child: TabBarView(
              controller: _controller,
              children: <Widget>[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.home),
                    title: TextField(
                      decoration: const InputDecoration(
                          hintText: 'Search for address...'),
                    ),
                  ),
                ),
                new Card(
                  child: new ListTile(
                    leading: const Icon(Icons.location_on),
                    title: new Text('Latitude: 48.09342\nLongitude: 11.23403'),
                    trailing: new IconButton(
                        icon: const Icon(Icons.my_location), onPressed: () {}),
                  ),
                ),
              ],
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Some more information'),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text(
              'Search for POIs',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
