import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/models/reminder.dart';
import 'package:dima/services/app_data.dart';
import 'package:dima/services/database.dart';
import 'package:dima/shared/formatter.dart';
import 'package:dima/shared/loading.dart';
import 'package:dima/shared/themes.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:table_calendar/table_calendar.dart';

class Dates extends StatefulWidget {
  const Dates({Key? key}) : super(key: key);

  @override
  State<Dates> createState() => _DatesState();
}

class _DatesState extends State<Dates> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;
  bool addReminder = true;
  final List<Reminder> _allReminders = [];
  final List<int> _selectedItems = [];

  Widget _getReminders() {
    _allReminders.clear();
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('reminders')
          .doc(AppData().user.getGroupId())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.data() == null) {
            return const Center(
              child: Text('You have no reminders'),
            );
          }
          List list = List.from(snapshot.data!.data()!['reminders']);
          return Container(
            margin: const EdgeInsets.only(bottom: 80),
            child: Scrollbar(
              child: ListView.separated(
                reverse: true,
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  Reminder reminder = Reminder(
                    title: list[index]['title'],
                    dateTime: (list[index]['dateTime'] as Timestamp).toDate(),
                    creatorUid: list[index]['creator'],
                  );
                  _allReminders.add(reminder);
                  return GestureDetector(
                    onLongPress: () {
                      setState(() {
                        addReminder = false;
                        _selectedItems.add(index);
                      });
                    },
                    onTap: () {
                      if (!addReminder) {
                        setState(() {
                          if (!_selectedItems.contains(index)) {
                            _selectedItems.add(index);
                          } else {
                            _selectedItems.remove(index);
                            if (_selectedItems.isEmpty) {
                              addReminder = true;
                            }
                          }
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: !_selectedItems.contains(index)
                            ? Colors.transparent
                            : Colors.blue,
                      ),
                      margin: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                      child: reminder,
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    height: 5,
                  );
                },
                itemCount: list.length,
              ),
            ),
          );
        }
        return const Loading();
      },
    );
  }

  Widget get _buildCalendar {
    return TableCalendar(
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        }
      },
      onFormatChanged: (format) {
        if (format != _format) {
          setState(() {
            _format = format;
          });
        }
      },
      calendarFormat: _format,
      startingDayOfWeek: StartingDayOfWeek.monday,
      focusedDay: _focusedDay,
      firstDay: DateTime(2000),
      lastDay: DateTime(2030),
    );
  }

  FloatingActionButton _buildRemoveRemindersFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () async {
        showGeneralDialog(
          barrierLabel: 'deleteReminders',
          barrierDismissible: true,
          context: context,
          pageBuilder: (ctx, a1, a2) {
            return Container();
          },
          transitionBuilder: (ctx, a1, a2, child) {
            var curve = Curves.easeInOut.transform(a1.value);
            return Transform.scale(
              scale: curve,
              child: Dialog(
                backgroundColor: ThemeProvider().isDarkMode
                    ? Colors.grey[900]
                    : Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        _selectedItems.length == 1
                            ? 'Do you really want to remove this reminder?'
                            : 'Do you really want to remove these ${_selectedItems.length} reminders?',
                        style: TextStyle(
                          color: ThemeProvider().isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.orangeAccent,
                          ),
                          onPressed: () {
                            List<Reminder> toBeRemoved = [];
                            for (int index in _selectedItems) {
                              toBeRemoved.add(_allReminders[index]);
                            }
                            DatabaseService().removeReminders(
                                toBeRemoved, AppData().user.getGroupId());
                            Navigator.of(ctx).pop();
                          },
                          child: const Text(
                            'Remove',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.orangeAccent,
                          ),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          child: const Text(
                            'No',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      icon: const Icon(Icons.delete),
      label: const Text('Remove'),
    );
  }

  FloatingActionButton _buildAddReminderFloatingActionButton() {
    final TextEditingController titleController = TextEditingController();
    DateTime pickedDate = DateTime.now();
    TimeOfDay pickedTime = TimeOfDay.now();
    Formatter formatter = Formatter();
    return FloatingActionButton.extended(
      onPressed: () {
        showModalBottomSheet(
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          )),
          context: context,
          builder: (context) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: GestureDetector(
                    onTap: () {},
                    child: DraggableScrollableSheet(
                      initialChildSize: 0.5,
                      minChildSize: 0.1,
                      builder: (_, controller) {
                        return Container(
                          decoration: const BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              )),
                          child: Container(
                            margin: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Add reminder',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        if (titleController.text.isNotEmpty) {
                                          DatabaseService db =
                                              DatabaseService();
                                          DateTime dateTime = DateTime(
                                            pickedDate.year,
                                            pickedDate.month,
                                            pickedDate.day,
                                            pickedTime.hour,
                                            pickedTime.minute,
                                          );
                                          Fluttertoast.showToast(
                                              msg: dateTime.toString());
                                          Reminder reminder = Reminder(
                                              title: titleController.text,
                                              dateTime: dateTime,
                                              creatorUid:
                                                  AppData().user.getGroupId());
                                          db.addReminder(reminder,
                                              AppData().user.getGroupId());
                                          Navigator.of(context).pop();
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: 'Set a title');
                                        }
                                      },
                                      icon: const Icon(Icons.check),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Flexible(
                                  child: TextField(
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    controller: titleController,
                                    cursorColor: Colors.orangeAccent,
                                    decoration: const InputDecoration(
                                      label: Text(
                                        'Title',
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const Divider(),
                                GestureDetector(
                                  onTap: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2030),
                                    ).then(
                                      (value) {
                                        if (value != null &&
                                            value != pickedDate) {
                                          setState(
                                            () {
                                              pickedDate = value;
                                            },
                                          );
                                        }
                                      },
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/icons/calendar.png',
                                        width: 30,
                                      ),
                                      const VerticalDivider(),
                                      Text(formatter.formatDate(pickedDate)),
                                    ],
                                  ),
                                ),
                                const Divider(),
                                GestureDetector(
                                  onTap: () {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then(
                                      (value) {
                                        if (value != null) {
                                          setState(() {
                                            pickedTime = value;
                                          });
                                        }
                                      },
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/icons/clock.png',
                                        width: 30,
                                      ),
                                      const VerticalDivider(),
                                      Text(formatter.formatTime(pickedTime)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            });
          },
        );
      },
      label: const Text('Add reminder'),
      icon: const Icon(Icons.lock_clock),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < constraints.maxHeight) {
        return Column(
          children: [
            _buildCalendar,
            const Divider(),
            Expanded(
              child: Scaffold(
                body: _getReminders(),
                floatingActionButton: addReminder
                    ? _buildAddReminderFloatingActionButton()
                    : _buildRemoveRemindersFloatingActionButton(),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
              ),
            ),
          ],
        );
      } else {
        return Row(
          children: [
            Expanded(
              child: _buildCalendar,
            ),
            Flexible(
              child: Scaffold(
                body: _getReminders(),
                floatingActionButton: addReminder
                    ? _buildAddReminderFloatingActionButton()
                    : _buildRemoveRemindersFloatingActionButton(),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
              ),
            ),
          ],
        );
      }
    });
  }
}
