import SwiftUI
import WeatherKit
import CoreLocation
import Charts

struct ContentView: View {
  
  @State private var weather: Weather?
  
  var dailyForecast: [DayWeather] {
    weather?.dailyForecast.forecast ?? []
  }
  
  var body: some View {
    VStack {
      Text("Swift Charts & WeatherKit")
        .font(.title)
        .bold()
      
      Spacer()
        .frame(height: 50)
      
      Text("San Francisco's 10 Days Forecast")
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading)
        .font(.headline)
      
      Chart(dailyForecast, id: \.date) { forecast in
        LineMark(
          x: .value("Date", forecast.date, unit: .day),
          y: .value("High", forecast.highTemperature.value),
          series: .value("High", "High")
        )
        .lineStyle(StrokeStyle(lineWidth: 3))
        .interpolationMethod(.cardinal)
        .foregroundStyle(by: .value("High", forecast.highTemperature.value))
        
        PointMark(
          x: .value("Date", forecast.date, unit: .day),
          y: .value("High", forecast.highTemperature.value)
        )
        .foregroundStyle(by: .value("High", forecast.highTemperature.value))
        .annotation {
          Text(forecast.highTemperature.formatted(.measurement(width: .narrow)))
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        
        LineMark(
          x: .value("Date", forecast.date, unit: .day),
          y: .value("Low", forecast.lowTemperature.value),
          series: .value("Low", "Low")
        )
        .interpolationMethod(.cardinal)
        .lineStyle(StrokeStyle(lineWidth: 3))
        .foregroundStyle(by: .value("Low", forecast.lowTemperature.value))
        
        PointMark(
          x: .value("Date", forecast.date, unit: .day),
          y: .value("Low", forecast.lowTemperature.value)
        )
        .foregroundStyle(by: .value("Low", forecast.lowTemperature.value))
        .annotation {
          Text(forecast.lowTemperature.formatted(.measurement(width: .narrow)))
            .font(.footnote)
            .foregroundColor(.secondary)
        }
      }
      .chartYScale(
        domain: .automatic(includesZero: false),
        range: .plotDimension,
        type: nil
      )
      .chartXAxis {
        AxisMarks(position: .bottom, values: .stride(by: .day)) { value in
          AxisGridLine()
          AxisTick()
          AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
        }
      }
      .chartPlotStyle { plotArea in
        plotArea
          .frame(height: 350)
      }
      .padding(.horizontal)
    }
    .task {
      let location = CLLocation(latitude: 37.7749, longitude: 122.4194)
      do {
        let weather = try await WeatherService.shared.weather(for: location)
        self.weather = weather
      } catch {
        print(error)
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
