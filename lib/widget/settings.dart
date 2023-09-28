import 'package:flutter/material.dart';
import 'package:tunescape/core/state.dart';

class SettingsWidget extends StatefulWidget {
  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Color scheme'),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 12, // Number of colors per row
                childAspectRatio: 1, // Adjust this for item's width-to-height ratio
              ),
              itemCount: accentColors.length,
              itemBuilder: (context, index) {
                bool isSelected = index == themeManager.colorSchemeIndex;
                double radius = isSelected ? 40 : 30;

                TsColorScheme colors = accentColors[index];
                return GestureDetector(
                  onTap: () {
                    themeManager.setColorSchemeIndex(index);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: radius, // Adjust this for circle size
                        height: radius, // Adjust this for circle size
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == themeManager.colorSchemeIndex
                              ? colors.accent
                              : colors.accent.withOpacity(0.5),
                        ),
                      ), // Assuming `label` exists in `TsColorScheme`
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              themeManager.reset();
              preferences.reset();
            },
            child: Text("Clear and reset settings"),
          ),
        ],
      ),
    );
  }
}
