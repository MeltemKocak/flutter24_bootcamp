import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planova/pages/today_add.dart';
import 'package:planova/pages/welcome_screen.dart';

void main() => runApp(const Homes());

class Homes extends StatelessWidget {
  const Homes({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: const Color.fromARGB(255, 3, 218, 198),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.white),
          ),
        ),
      ),
      home: const NavigationExample(),
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  static int currentPageIndex = 0;

  final List<String> appBarTitles = ['Today', 'Habits', 'Journal', 'Profile'];

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
 
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.08), // Boş alan
            Text(appBarTitles[currentPageIndex], style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Implement your search action here
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Implement your more action here
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF333333),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF333333),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      user?.email ?? 'Anonymous User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list, color: Colors.white),
              title: const Text('All tasks', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() {
                  currentPageIndex = 0;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.white),
              title: const Text('Habits', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() {
                  currentPageIndex = 1;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.white),
              title: const Text('Important Task', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() {
                  currentPageIndex = 2;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.white),
              title: const Text('Deleted', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() {
                  currentPageIndex = 3;
                });
                Navigator.of(context).pop();
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Implement your settings action here
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await Auth().signOut(context: context);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
            switch (currentPageIndex) {
      case 0:
        // İlk durum için yapılacak işlemler
        showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const TodayAddSubPage(),
            );
        break;
      case 1:
        // İkinci durum için yapılacak işlemler
        print('Button pressed on page 1');
        break;
      case 2:
        // Üçüncü durum için yapılacak işlemler
        print('Button pressed on page 2');
        break;
      default:
        // Varsayılan durum (isteğe bağlı)
    }
        },
        backgroundColor: const Color.fromARGB(255, 3, 218, 198),
        child: const Icon(
          Icons.add,
          size: 32,
          color: Colors.black,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color.fromARGB(255, 42, 42, 42),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(
              Icons.calendar_month_outlined,
              color: Colors.black,
              size: 20,
            ),
            icon: Icon(
              Icons.calendar_month_outlined,
              color: Colors.white,
              size: 20,
            ),
            label: 'Today',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.flag_outlined,
              color: Colors.black,
              size: 20,
            ),
            icon: Icon(
              Icons.flag_outlined,
              color: Colors.white,
              size: 20,
            ),
            label: 'Habits',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.library_books_outlined,
              color: Colors.black,
              size: 20,
            ),
            icon: Icon(
              Icons.library_books_outlined,
              color: Colors.white,
              size: 20,
            ),
            label: 'Journal',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.person_outline,
              color: Colors.black,
              size: 20,
            ),
            icon: Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 20,
            ),
            label: 'Profile',
          ),
        ],
      ),
      body: [
        Card(
          color: const Color.fromARGB(255, 30, 30, 30),
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: Text(
                'Home page',
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),
        ),
        Card(
          color: const Color.fromARGB(255, 30, 30, 30),
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: Text(
                'Home page2',
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),
        ),
        Card(
          color: const Color.fromARGB(255, 30, 30, 30),
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: Text(
                'Home page3',
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),
        ),
        Card(
          color: const Color.fromARGB(255, 30, 30, 30),
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: Text(
                'Home page4',
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),
        ),
        ListView.builder(
          reverse: true,
          itemCount: 3,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'Hello',
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: Colors.white38),
                  ),
                ),
              );
            }
            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'Hi!',
                  style: theme.textTheme.bodyMedium!
                      .copyWith(color: theme.colorScheme.onPrimary),
                ),
              ),
            );
          },
        ),
      ][currentPageIndex],
    );
  }


}

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> signOut({required BuildContext context}) async {
    await _firebaseAuth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()));
  }
}
