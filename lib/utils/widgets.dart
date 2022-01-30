import 'package:flutter/material.dart';

List<Color> colors = [
  Color(0xFFFFFFFF),
  Color(0xFFCF8E8A),
  Color(0xFFE2D86A),
  Color(0xFFB5E282),
  Color(0xFF92DBCA),
];

List<Color> colorsDark = [
  Color(0xff303030),
  Color(0xffAD7672),
  Color(0xFF807A3B),
  Color(0xFF658047),
  Color(0xFF548075),
];

class ColorPicker extends StatefulWidget {
  final Function(int) onTap;
  final int selectedIndex;
  ColorPicker({this.onTap, this.selectedIndex});

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  int selectedIndex;

  @override
  Widget build(BuildContext context) {
    if (selectedIndex == null) {
      selectedIndex = widget.selectedIndex;
    }
    double width = MediaQuery.of(context).size.width;
    final brightness = Theme.of(context).brightness;
    bool isDarkMode = brightness == Brightness.dark;
    return SizedBox(
      width: width,
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: isDarkMode ? colorsDark.length : colors.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
              widget.onTap(index);
            },
            child: Container(
              padding: EdgeInsets.all(8.0),
              width: 50,
              height: 50,
              child: Container(
                child: Center(
                    child: selectedIndex == index
                        ? Icon(Icons.done)
                        : Container()),
                decoration: BoxDecoration(
                    color: isDarkMode ? colorsDark[index] : colors[index],
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 1,
                      color: isDarkMode ? Colors.white : Colors.black,
                    )),
              ),
            ),
          );
        },
      ),
    );
  }
}
