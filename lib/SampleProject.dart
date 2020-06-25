import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'dart:developer';

void main() => runApp(DateTimePicker());

class DateTimePicker extends StatefulWidget {
  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: 'Sarabun'
      ),
      home: Scaffold(
          appBar: AppBar(
            title: Text('ทดสอบสร้างฟอร์ม'),
          ),
          backgroundColor: Colors.white,
          body: HomeScreen()
      )
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class CustomPicker extends DatePickerModel {
  CustomPicker({DateTime currentTime, DateTime maxTime, DateTime minTime, LocaleType locale})
      : super(locale: locale) {
    this.currentTime = currentTime ?? DateTime.now();
    this.maxTime = maxTime ?? this.currentTime;
    this.minTime = minTime ?? DateTime(2500, 1, 1);
    _fillLeftLists();
    _fillRightLists();
    this.setLeftIndex(this.currentTime.year - this.minTime.year);
  }

  @override
  String leftDivider() {
    // TODO: implement leftDivider
    return "|";
  }

  @override
  String rightDivider() {
    // TODO: implement rightDivider
    return "|";
  }

  @override
  List<int> layoutProportions() {
    // TODO: implement layoutProportions
    return [1, 2, 1];
  }

  void _fillLeftLists() {
    this.leftList = List.generate(maxTime.year - minTime.year + 1, (int index) {
      return '${minTime.year + index}';
    });
  }

  List<int> _leapYearMonths = const <int>[1, 3, 5, 7, 8, 10, 12];

  int calcDateCount(int year, int month) {
    year -= 543;
    if (_leapYearMonths.contains(month)) {
      return 31;
    } else if (month == 2) {
      if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
        return 29;
      }
      return 28;
    }
    return 30;
  }

  int _maxDayOfCurrentMonth() {
    int dayCount = calcDateCount(currentTime.year, currentTime.month);
    return currentTime.year == maxTime.year && currentTime.month == maxTime.month
        ? maxTime.day
        : dayCount;
  }

  int _minDayOfCurrentMonth() {
    return currentTime.year == minTime.year && currentTime.month == minTime.month ? minTime.day : 1;
  }

  void _fillRightLists() {
    int maxDay = _maxDayOfCurrentMonth();
    int minDay = _minDayOfCurrentMonth();
    this.rightList = List.generate(maxDay - minDay + 1, (int index) {
      return '${minDay + index}';
    });
  }

  int _minMonthOfCurrentYear() {
    return currentTime.year == minTime.year ? minTime.month : 1;
  }

  @override
  void setMiddleIndex(int index) {
    super.setMiddleIndex(index);
    int minMonth = _minMonthOfCurrentYear();
    int destMonth = minMonth + index;
    DateTime newTime;
    //change date time
    int dayCount = calcDateCount(currentTime.year, destMonth);
    newTime = currentTime.isUtc
        ? DateTime.utc(
      currentTime.year,
      destMonth,
      currentTime.day <= dayCount ? currentTime.day : dayCount,
    )
        : DateTime(
      currentTime.year,
      destMonth,
      currentTime.day <= dayCount ? currentTime.day : dayCount,
    );
    //min/max check
    if (newTime.isAfter(maxTime)) {
      currentTime = maxTime;
    } else if (newTime.isBefore(minTime)) {
      currentTime = minTime;
    } else {
      currentTime = newTime;
    }

    _fillRightLists();
    int minDay = _minDayOfCurrentMonth();
    this.setRightIndex(currentTime.day - minDay);
  }

}

String digits(int value, int length) {
  return '$value'.padLeft(length, "0");
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  var _fullname = TextEditingController(text: 'ราชวิทย์ ศรีทองดี');
  var _date = TextEditingController(text: '${digits(DateTime.now().day, 2)}-${digits(DateTime.now().month, 2)}-${DateTime.now().year + 543}');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child:  Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('ชื่อ-นามสกุล')
                      ],
                    ),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: _fullname,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'กรุณากรอกชื่อและนามสกุล';
                        }
                        return null;
                      },
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                      ],
                      keyboardType: TextInputType.text,
                      decoration: new InputDecoration(
                        contentPadding: EdgeInsets.all(10.0),
                        isDense: true,
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.teal)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('วัน-เดือน-ปีเกิด')
                        ],
                      ),
                      SizedBox(height: 5),
                      GestureDetector(
                          onTap: () {
                            DatePicker.showPicker(context, showTitleActions: true,
                                theme: DatePickerTheme(
                                    containerHeight: 210.0,
                                    itemStyle: TextStyle(fontSize: 18, fontFamily: 'Sarabun'),
                                    cancelStyle: TextStyle(fontSize: 16, fontFamily: 'Sarabun'),
                                    doneStyle: TextStyle(fontSize: 16, fontFamily: 'Sarabun')
                                ),
                                locale: LocaleType.th,
                                onChanged: (date) {
                                }, onConfirm: (date) {
                                  _date.text = '${digits(date.day, 2)}-${digits(date.month, 2)}-${date.year}';
                                  setState(() {});
                                }, pickerModel: CustomPicker(currentTime: DateTime(DateTime.now().year + 543, DateTime.now().month, DateTime.now().day), locale: LocaleType.th));
                          },
                          child:AbsorbPointer(
                            child: TextFormField(
                              controller: _date,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                              ],
                              keyboardType: TextInputType.text,
                              decoration: new InputDecoration(
                                prefixIcon: Icon(Icons.calendar_today),
                                contentPadding: EdgeInsets.all(10.0),
                                isDense: true,
                                border: new OutlineInputBorder(
                                    borderSide: new BorderSide(color: Colors.teal)
                                ),
                              ),
                            ),
                          )
                      ),
                      SizedBox(height: 5),
                      RaisedButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            Scaffold.of(context)
                                .showSnackBar(SnackBar(content: Text('กำลังโหลดข้อมูล')));
                          }
                        },
                        child: Text('บันทีก'),
                      )
                    ],
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}