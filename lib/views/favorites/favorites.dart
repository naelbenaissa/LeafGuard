import 'package:flutter/material.dart';
import 'package:ui_leafguard/views/favorites/appbar/favorites_appbar.dart';
import '../bar/custom_bottombar.dart';
import '../widgets/dotIndicator.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FavoritesAppbar(scrollController: ScrollController()),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Gérez vos plantes favorites et vos scans",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 250,
              child: TabBar(
                controller: _tabController,
                labelStyle: const TextStyle(fontSize: 18),
                tabs: const [
                  Tab(text: "Mes Scans"),
                  Tab(text: "Mes Favoris"),
                ],
                labelColor: Colors.green,
                unselectedLabelColor: Colors.grey,
                indicatorWeight: 0,
                dividerHeight: 0,
                indicator: DotIndicator(),
                labelPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: TabBarView(
                controller: _tabController,
                children: const [
                  Center(child: Text("Ici, la liste de vos scans")),
                  Center(child: Text("Ici, la liste de vos favoris")),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(),
    );
  }
}
