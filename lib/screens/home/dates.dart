import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/models/reminder.dart';
import 'package:dima/services/app_data.dart';
import 'package:dima/services/database.dart';
import 'package:dima/shared/constants.dart';
import 'package:dima/shared/formatter.dart';
import 'package:dima/shared/themes.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:table_calendar/table_calendar.dart';

class Dates extends StatelessWidget {
  List remindersList;
  Dates({Key? key, required this.remindersList}) : super(key: key);
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  bool addReminder = true;
  final Map<DateTime, List<Reminder>> _reminders = {};
  final List<Reminder> _allReminders = [];
  final List<int> _selectedItems = [];
  final List _remindersInDate = [];
  late BuildContext context;

  Widget _getReminders(Function setState) {
    _remindersInDate.clear();
    for (var el in remindersList) {
      if (((el['dateTime']) as Timestamp).toDate().day == _focusedDay.day &&
          ((el['dateTime']) as Timestamp).toDate().month == _focusedDay.month &&
          ((el['dateTime']) as Timestamp).toDate().year == _focusedDay.year) {
        _remindersInDate.add(el);
      }
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 80),
      child: Scrollbar(
        child: ListView.separated(
          reverse: true,
          shrinkWrap: true,
          itemBuilder: (_, index) {
            DateTime date =
                (_remindersInDate[index]['dateTime'] as Timestamp).toDate();
            Reminder reminder = Reminder(
              title: _remindersInDate[index]['title'],
              dateTime:
                  (_remindersInDate[index]['dateTime'] as Timestamp).toDate(),
              creatorUid: _remindersInDate[index]['creator'],
            );
            _allReminders.add(reminder);
            if (_reminders[date] != null) {
              _reminders[date]!.add(reminder);
            } else {
              _reminders[date] = [reminder];
            }
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
                    color: colors[AppData()
                            .group
                            .getUserIndexFromId(reminder.creatorUid) %
                        colors.length],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: !_selectedItems.contains(index)
                      ? colors[AppData()
                                  .group
                                  .getUserIndexFromId(reminder.creatorUid) %
                              colors.length]
                          .withOpacity(0.6)
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
          itemCount: _remindersInDate.length,
        ),
      ),
    );
  }

  Widget _buildCalendar(Function setState) {
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
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
      ),
      calendarStyle: const CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: Colors.orangeAccent,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        markerDecoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.blueAccent,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        defaultDecoration: BoxDecoration(),
        outsideDecoration: BoxDecoration(),
        weekendDecoration: BoxDecoration(),
      ),
      eventLoader: (day) {
        List temp = [];
        for (var el in remindersList) {
          if (((el['dateTime']) as Timestamp).toDate().day == day.day &&
          ((el['dateTime']) as Timestamp).toDate().month == day.month &&
          ((el['dateTime']) as Timestamp).toDate().year == day.year) {
            temp.add(el);
          }
        }
        return temp;
      },
      calendarFormat: CalendarFormat.month,
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
                    ? const Color(0xff1e314d)
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
                            _selectedItems.clear();
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
    DateTime pickedDate = _focusedDay;
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
                          decoration: BoxDecoration(
                              color: ThemeProvider().isDarkMode
                                  ? const Color(0xff000624)
                                  : Colors.white,
                              borderRadius: const BorderRadius.only(
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
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: const CircleBorder(),
                                      ),
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
                                          Reminder reminder = Reminder(
                                              title: titleController.text,
                                              dateTime: dateTime,
                                              creatorUid:
                                                  AppData().user.getUid());
                                          db.addReminder(reminder,
                                              AppData().user.getGroupId());
                                          Navigator.of(context).pop();
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: 'Set a title');
                                        }
                                      },
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.black,
                                      ),
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
                                      initialDate: _focusedDay,
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
    this.context = context;
    return StatefulBuilder(builder: (context, setState) {
      return LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < constraints.maxHeight) {
          return Column(
            children: [
              _buildCalendar(setState),
              const Divider(),
              Expanded(
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: _getReminders(setState),
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
                child: _buildCalendar(setState),
              ),
              Flexible(
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: _getReminders(setState),
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
    });
  }
}
