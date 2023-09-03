<h1 align="center">  Take Note!
 </h1> <br>
<p align="center">
    <img alt="Take Note" title="GitPoint" src="https://user-images.githubusercontent.com/97199759/191323720-adea0c92-52b7-48fb-9196-4b3b4d4908e9.png" width="450">
  </a>
</p>

[![Codemagic build status](https://api.codemagic.io/apps/6343ed3a720e3cd60e1f926b/6343ed3a720e3cd60e1f926a/status_badge.svg)](https://codemagic.io/apps/6343ed3a720e3cd60e1f926b/6343ed3a720e3cd60e1f926a/latest_build)

<p align="center">
  Take Notes
</p>

<!-- <p align="center">
  <a href="https://itunes.apple.com/us/app/gitpoint/id1251245162?mt=8">
    <img alt="Download on the App Store" title="App Store" src="http://i.imgur.com/0n2zqHD.png" width="140">
  </a>

  <a href="https://play.google.com/store/apps/details?id=com.gitpoint">
    <img alt="Get it on Google Play" title="Google Play" src="http://i.imgur.com/mtGRPuM.png" width="140">
  </a>
</p> -->



<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

## Table of Contents

A simple notes app, set colours for notes, share notes, temporarily delete notes & archive your notes.

<p align="center">
  <img src = "https://user-images.githubusercontent.com/97199759/191323905-2e765ea4-f305-4d1a-873d-636ac3fa35e5.jpg" width=700>
</p>

<p align="center">
  <img src = "https://user-images.githubusercontent.com/97199759/191290609-167db54a-01e5-4e22-a5a4-efe5fc692c65.png" width=700>
</p>

<p align="center">
  <img src = "https://user-images.githubusercontent.com/97199759/191290618-8a6641e7-5825-405d-9b4c-8bcd9662cc87.png" width=700>
</p>

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Features

- BLoC Architecture
- Firebase cloud integration
- Supports Android/iOS (iOS not published yet but works fine)
- List/grid view for notes
- Archive notes

## To-do

- [ ] Search notes
- [ ] Lock Notes - Local Auth
- [ ] Desktop Support
- [ ] Web Support
- [ ] Localization
- [ ] Fix Hard-coded / Non-DRY compliant code

## Platform

- Android
- iOS `not published`
- Desktop `work in progress`
- Linux `beta testing in progress`

### Android 
<a href='https://play.google.com/store/apps/details?id=com.atencia.takenote'><img alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png' width="200"/></a>

## Compiling the app

Before anything, be sure to have a working flutter sdk setup.If not installed, go to [Install - Flutter](https://docs.flutter.dev/get-started/install).

Be sure to disable signing on build.gradle or change keystore to sign the app.

For now the required flutter channel is master, so issue those two commands before starting building:

```
$ flutter channel master
```

```
$ flutter upgrade
```

After that, building is simple as this:

```
$ flutter pub get
```

```
$ flutter run
```

```
$ flutter build apk
```

## Contributing

Feel free to open a PR to suggest fixes, features or whatever you want, just remember that PRs are subjected to manual review so you gotta wait for actual people to look at your contributions.

## Acknowledgments

Thanks to [Vandahd](https://github.com/vandadnp) for creating such an awsome course and sharing his Dart & Flutter tips
