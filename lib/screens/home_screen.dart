import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/app_provider.dart';
import 'add_item_screen.dart';
import '../widgets/plan_card.dart';
import '../widgets/todo_item.dart';
import '../models/plan_model.dart';
import '../models/todo_model.dart';
import 'edit_item_screen.dart'; // Import the edit screen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _selectedTabIndex = 0; // To keep track of selected tab index

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tekber App"),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.month,
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                final provider = Provider.of<AppProvider>(context);
                List<Widget> markers = [];

                bool hasPlan = provider.plans.any((plan) => isSameDay(plan.date, date));
                bool hasToDo = provider.todos.any((todo) => isSameDay(todo.date, date));

                if (hasPlan) {
                  markers.add(Positioned(
                    bottom: -6,
                    left: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ));
                }

                if (hasToDo) {
                  markers.add(Positioned(
                    bottom: -6,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ));
                }

                return Stack(children: markers);
              },
            ),
          ),
          // The bubble container for the tabs
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200], // Background color for the bubble
              borderRadius: BorderRadius.circular(30), // Rounded corners
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.transparent, // Remove the indicator line
              onTap: (index) {
                setState(() {
                  _selectedTabIndex = index;  // Update the selected tab index
                });
              },
              tabs: [
                _buildTab("All", 0),
                _buildTab("Plan", 1),
                _buildTab("To-Do", 2),
              ],
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllTab(context),
                _buildPlanTab(context),
                _buildToDoTab(context),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddItemScreen()),
        ),
        child: const Icon(Icons.add),
        shape: CircleBorder(), // This will make the button round
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF49828A), // Set the BottomAppBar color to #49828a
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  // Handle menu action
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // Handle settings action
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Plan> _getPlansForSelectedDate(AppProvider provider) {
    return provider.plans.where((plan) => isSameDay(plan.date, _selectedDay)).toList();
  }

  List<ToDo> _getToDosForSelectedDate(AppProvider provider) {
    return provider.todos.where((todo) => isSameDay(todo.date, _selectedDay)).toList();
  }

  Widget _buildAllTab(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final filteredPlans = _getPlansForSelectedDate(provider);
    final filteredToDos = _getToDosForSelectedDate(provider);

    return ListView(
      children: [
        ...filteredPlans.map((plan) => _buildPlanListItem(context, plan)),
        ...filteredToDos.map((todo) => _buildToDoListItem(context, todo)),
      ],
    );
  }

  Widget _buildPlanTab(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final filteredPlans = _getPlansForSelectedDate(provider);

    return ListView(
      children: filteredPlans.map((plan) => _buildPlanListItem(context, plan)).toList(),
    );
  }

  Widget _buildToDoTab(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final filteredToDos = _getToDosForSelectedDate(provider);

    return ListView(
      children: filteredToDos.map((todo) => _buildToDoListItem(context, todo)).toList(),
    );
  }

  Widget _buildPlanListItem(BuildContext context, Plan plan) {
    return GestureDetector(
      onTap: () {
        // Navigate to Edit Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditItemScreen(item: plan),
          ),
        );
      },
      child: PlanCard(plan: plan),
    );
  }

  Widget _buildToDoListItem(BuildContext context, ToDo todo) {
    return GestureDetector(
      onTap: () {
        // Navigate to Edit Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditItemScreen(item: todo),
          ),
        );
      },
      child: ToDoItem(todo: todo),
    );
  }

  Widget _buildTab(String label, int index) {
    bool isSelected = _selectedTabIndex == index;  // Check if the tab is selected
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent, // Transparent background inside bubble
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
              if (isSelected)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 3,
                    height: double.infinity,
                    color: index == 1 // Plan tab
                        ? Colors.blue[100] // Rectangular highlight for Plan tab
                        : Colors.transparent,
                  ),
                ),
              ),
            if (isSelected && index == 2) // To-Do tab
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 3,
                    height: double.infinity,
                    color: Colors.red[100], // Rectangular highlight for ToDo tab
                  ),
                ),
              ),
            Center(child: Text(label)),
          ],
        ),
      ),
    );
  }
}
