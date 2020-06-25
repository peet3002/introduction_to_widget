import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

void main() => runApp(new MyApp());

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
    print('${this.middleList} | ${this.rightList}') ;
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


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Datetime Picker'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            FlatButton(
                onPressed: () {
                  DatePicker.showPicker(context, showTitleActions: true,
                      theme: DatePickerTheme(
                          itemStyle: TextStyle(fontSize: 18, fontFamily: 'Sarabun'),
                          doneStyle: TextStyle(fontSize: 18, fontFamily: 'Sarabun')
                      ),
                      locale: LocaleType.th,
                      onChanged: (date) {
                        print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                      }, onConfirm: (date) {

                      }, pickerModel: CustomPicker(currentTime: DateTime(DateTime.now().year + 543, DateTime.now().month , DateTime.now().day), locale: LocaleType.th));
                },
                child: Text(
                  'show custom time picker,\nyou can custom picker model like this',
                  style: TextStyle(color: Colors.blue),
                )),
          ],
        ),
      ),
    );
  }
}
