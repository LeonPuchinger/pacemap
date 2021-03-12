# pacemap

Rewrite of a project I did 2 years ago.

## About

pacemap lets you live-track athletes on a map using gpx-data of the track.

## Building

1. Add Google-Maps API Key (required):

   Get a key at <https://cloud.google.com/maps-platform/>

   iOS:

   Create file ios/Runner/Keys.swift with the following contents:

   >let googleMapsApiKey = "YOUR KEY HERE"

   Android:

   ->todo

2. Build Flutter App:

   >flutter pub get

   >flutter run
