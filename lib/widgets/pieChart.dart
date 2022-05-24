import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Chart {
  Widget generateChart(chartData) {
    return SfCircularChart(
        legend: Legend(isVisible: true, orientation: LegendItemOrientation.horizontal, position: LegendPosition.top, alignment: ChartAlignment.center, offset: Offset(0, 0), ),
        series: <CircularSeries>[
          PieSeries<ChartData, String>(
              dataLabelSettings: DataLabelSettings(
                labelPosition: ChartDataLabelPosition.outside,
                useSeriesColor: true,
                  isVisible: true),
              dataSource: chartData,
              pointColorMapper: (ChartData data, _) => data.color,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y)
        ]);
  }
}

class ChartData {
  ChartData(this.x, this.y, [this.color]);
  final String x;
  final int y;
  final Color? color;

  static List<ChartData> generateChartData(Map<String, dynamic> chartData){
    List<ChartData> chartDataList = [];
    
    for(final data in chartData.entries){
      print(data.key);
      print(data.value);
      chartDataList.add(ChartData(data.key, data.value));
    }

    return chartDataList;
}}