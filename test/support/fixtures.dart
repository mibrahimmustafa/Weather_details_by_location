/// Recorded API payloads used by the unit tests.
///
/// They are trimmed-down but structurally identical to the live responses from
/// Open-Meteo, NASA EONET and GDACS.
library;

const int kBaseEpoch = 1700000000; // 2023-11-14T22:13:20Z

Map<String, dynamic> forecastFixture() => {
  'timezone': 'Africa/Cairo',
  'utc_offset_seconds': 7200,
  'current': {
    'time': kBaseEpoch,
    'temperature_2m': 31.4,
    'relative_humidity_2m': 40,
    'apparent_temperature': 34.2,
    'is_day': 1,
    'precipitation': 0.0,
    'rain': 0.0,
    'showers': 0.0,
    'snowfall': 0.0,
    'weather_code': 1,
    'cloud_cover': 12,
    'pressure_msl': 1012.5,
    'wind_speed_10m': 14.0,
    'wind_direction_10m': 315,
    'wind_gusts_10m': 27.0,
  },
  'hourly': {
    'time': [kBaseEpoch, kBaseEpoch + 3600, kBaseEpoch + 7200],
    'temperature_2m': [31.4, 32.1, 33.0],
    'precipitation_probability': [0, 10, 55],
    'precipitation': [0.0, 0.0, 1.4],
    'weather_code': [1, 1, 61],
    'wind_speed_10m': [14.0, 16.0, 18.0],
    'visibility': [24000.0, 18000.0, 9000.0],
  },
  'daily': {
    'time': [kBaseEpoch, kBaseEpoch + 86400, kBaseEpoch + 172800],
    'weather_code': [1, 61, 0],
    'temperature_2m_max': [33.0, 31.0, 34.0],
    'temperature_2m_min': [22.0, 21.0, 23.0],
    'sunrise': [kBaseEpoch - 21600, kBaseEpoch + 64800, kBaseEpoch + 151200],
    'sunset': [kBaseEpoch + 21600, kBaseEpoch + 108000, kBaseEpoch + 194400],
    'uv_index_max': [7.5, 5.0, 8.0],
    'precipitation_sum': [0.0, 2.4, 0.0],
    'precipitation_probability_max': [10, 60, 5],
    'wind_speed_10m_max': [24.0, 30.0, 20.0],
  },
};

Map<String, dynamic> airQualityFixture() => {
  'current': {
    'pm10': 45.5,
    'pm2_5': 22.1,
    'dust': 62.0,
    'us_aqi': 82,
    'european_aqi': 55,
    'uv_index': 6.2,
  },
  'hourly': {
    'time': [kBaseEpoch, kBaseEpoch + 3600],
    'dust': [62.0, 71.0],
    'pm10': [45.5, 51.0],
  },
};

Map<String, dynamic> eonetWrapper() => {
  'source': 'eonet',
  'payload': {
    'events': [
      {
        'id': 'EONET_100',
        'title': 'Tropical Storm Ajwaa',
        'geometry': [
          {
            'date': '2026-10-01T00:00:00Z',
            'coordinates': [55.0, 20.0],
            'magnitudeValue': 55,
            'magnitudeUnit': 'knots',
          },
          {
            'date': '2026-10-03T00:00:00Z',
            'coordinates': [56.5, 21.5],
            'magnitudeValue': 80,
            'magnitudeUnit': 'knots',
          },
        ],
        'sources': [
          {'id': 'JTWC', 'url': 'https://example.com/eonet-storm'},
        ],
      },
    ],
  },
};

Map<String, dynamic> geocodingFixture() => {
  'results': [
    {
      'id': 2643743,
      'name': 'London',
      'latitude': 51.50853,
      'longitude': -0.12574,
      'country': 'United Kingdom',
      'admin1': 'England',
      'country_code': 'GB',
      'timezone': 'Europe/London',
    },
    {
      'id': 2800866,
      'name': 'Brussels',
      'latitude': 50.85045,
      'longitude': 4.34878,
      'country': 'Belgium',
      'admin1': 'Brussels Capital',
      'country_code': 'BE',
      'timezone': 'Europe/Brussels',
    },
  ],
};

Map<String, dynamic> reverseGeocodeFixture() => {
  'city': 'Cairo',
  'locality': 'Cairo',
  'principalSubdivision': 'Cairo Governorate',
  'countryName': 'Egypt',
  'countryCode': 'EG',
  'localityInfo': {
    'informative': [
      {'name': 'Egypt'},
      {'name': 'Africa/Cairo'},
    ],
  },
};

Map<String, dynamic> gdacsWrapper() => {
  'source': 'gdacs',
  'payload': {
    'features': [
      {
        'geometry': {
          'coordinates': [100.0, 15.0],
        },
        'properties': {
          'iscurrent': 'true',
          'eventid': 7,
          'episodeid': 3,
          'eventname': 'Cyclone GDACS',
          'alertlevel': 'orange',
          'country': 'Testland',
          'severitydata': {'severity': 90.0},
          'fromdate': '2026-10-01T00:00:00Z',
          'todate': '2026-10-04T00:00:00Z',
          'source': 'GDACS',
          'url': {'report': 'https://example.com/gdacs-storm'},
        },
      },
      {
        'geometry': {
          'coordinates': [101.0, 16.0],
        },
        'properties': {
          'iscurrent': 'false',
          'eventid': 8,
          'episodeid': 1,
          'eventname': 'Old storm',
          'alertlevel': 'green',
        },
      },
    ],
  },
};
