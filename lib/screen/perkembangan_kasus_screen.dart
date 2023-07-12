import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau/models/kasus.dart';
import 'package:pantau/widgets/kronologi_widget.dart';

class PerkembanganKasusScreen extends StatefulWidget{

  final PostinganKasus kasus;
  const PerkembanganKasusScreen({super.key, required this.kasus});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PerkembanganKasusScreenState();
  }
}
class _PerkembanganKasusScreenState extends State<PerkembanganKasusScreen> with TickerProviderStateMixin{
  TabController? _tabController;
  int _currentPageIndex = 0;
  List<String> pages = ['Versi Korban', 'Versi Kepolisian'];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: pages.length, vsync: this);
    _tabController!.addListener(() {
      if (_currentPageIndex != _tabController!.index) {
        setState(() {
          _currentPageIndex = _tabController!.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
      length: pages.length,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 16),
              child: TabBar(
                isScrollable: true,
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                tabs: List.generate(pages.length, (index) {
                  return Tab(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: _currentPageIndex == index ? Colors.blue : Colors.transparent,
                      ),
                      child: Text(
                        pages[index],
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: List.generate(pages.length, (index) {
                  if (index == 0) {
                    return PerkembanganKasusKorbanScreen(kasus: widget.kasus);
                  }
                  if (index == 1) {
                    return Center(
                      child: Text(
                        'Belum dipublikasikan oleh pihak Kepolisian',
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }
                  return Container(
                    color: Colors.blue.shade200,
                    child: Center(
                      child: Text(
                        '',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PerkembanganKasusKorbanScreen extends StatelessWidget {
  final PostinganKasus kasus;

  const PerkembanganKasusKorbanScreen({Key? key, required this.kasus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _kronologiList = kasus.kronologis;
    int? lastYearLabel;

    return Scaffold(
      body: _kronologiList.isEmpty
          ? Center(
        child: Text(
          'Tidak dipublikasikan oleh korban',
          style: TextStyle(color: Colors.black),
        ),
      )
          : ListView.builder(
        itemCount: _kronologiList.length,
        itemBuilder: (context, index) {
          final kronologi = _kronologiList[index];
          if (lastYearLabel == null || lastYearLabel != kronologi.tanggal.year) {
            lastYearLabel = kronologi.tanggal.year;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: _buildYearLabel(lastYearLabel!),
                ),
                KronologiWidget(kronologi: kronologi, maxLines: 3),
              ],
            );
          }
          return KronologiWidget(kronologi: kronologi, maxLines: 3);
        },
      ),
    );
  }

  Widget _buildYearLabel(int year) {
    return Container(
      alignment: Alignment.center,
      color: Colors.blue,
      child: Text(
        year.toString(),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}

