---
layout: article
title: Building a real cross-platform app including continuous delivery
date: 2021-06-30 12:00:00
published: true
categories: [iOS,android,app]
comments: false
share: true
description: Cross platform app
usemathjax: false
author: oleg_hein
image:
  teaser: 2021_06_30/teaser.png
  feature: 2021_06_30/comtravo_cross-platform_app_architecture.png

---

### Introduction

At Comtravo, we have been working on a huge Angular application for more than 4 years now. By the end of 2019 we managed to make every part of the application fully optimized for mobile devices as well as desktop devices. After investing only 2 additional weeks in development, we have been able to ship the same application on the Google Play Store as well as on the iOS App Store. And no, we did not have to build up two new development teams including backend developers, designers, release managers, and product managers. It was all possible by simply packaging our mobile-optimized web application into a [TWA](https://developer.chrome.com/docs/android/trusted-web-activity/overview/) for android and a [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview) for iOS. That way we even keep the biggest advantage of the web: “Continuous Delivery“.

![Cross Platform Rendering](/images/2021_06_30/comtravo_cross-platform_app_architecture.png){: width="35%" }

## Seriously? Container Apps? Is that still a thing?

What about all these nicely advertised frameworks like [Flutter](https://flutter.dev), [NativeScript](https://nativescript.org/), [Ionic](https://ionicframework.com/), [React Native](https://reactnative.dev)? Is full native development not the best way to go anyways?

Well, as always: _it depends_. More specifically, it depends on three major aspects that need to be consider before choosing an appropriate framework or architecture:

1. How much does look and feel really matter?
2. What content does your app require and where does it get it from?
3. Are there other dependencies related to your business case?

(To make this not too long to read, I will only compare native applications with web container applications since all of the frameworks are mostly sharing the same pros and cons as native applications do.)

### Does the look and feel matter?

The argument that native apps just look and feel better than websites is probably the most used argument for building a fully native application. This clearly depends on the business you are in and the values you want to deliver through your app. Yes, native applications have more capabilities in handling all kinds of touch gestures to make your app respond better to any user interaction. They can also leverage the devices' hardware better to render buttery smooth, jaw-dropping animations. But this also comes with a price tag. Great design and interactive animations need a lot of testing and polishing that will in any case take longer than you would have expected. You will probably have a native developer and UI-designer working closely together full-time on this to get it right in the end. And since these efforts will be written in “native“ code, they will be specific to one platform only and need to be built and tested the same way again for any other platform.

The question here really is how much your customers will notice and care about these efforts. If top-notch design and animations are part of your business, then you should go with a fully native application. If you just want to deliver a certain service or information, then a mobile-optimized website will make your customers equally happy.

At Comtravo, our customers were already satisfied with the design of our mobile website. So there was no need to improve anything there. Moreover, customers appreciated that our app covers all features that the website has and they would not need to learn a new user interface.

Just by looking at the screenshots above, could you tell if it is a native app or a web container?

## Type of Content

Or, in other words, where does your App get the content from that it needs to get its job done? If that content is included and bundled within the application or is created by its users while they use the app then it is also probably a good choice to build a fully native app. It starts when your app requires dynamic data that is loaded from a backend server or you need to upload and share data created by the app. In that case, the backend will quickly become the biggest time and resource consumer. And if you build your App around an already existing backend, you will most likely have to build a custom backend in between that prepares and optimizes data necessary for your app to run. There are tools like realm.io that streamline most of the common tasks but building a data aggregation layer can get really complex and time-consuming. Just think of user authorization, API model changes, and data migration. Since a new version of your native application needs to be built, uploaded, approved, and then downloaded by your customers, you need to carefully version your backend services as well. You never know what version of your app will reach out to your backend.

If you run a web application inside your app you can continuously deliver new versions of your backend and application and do not have to worry about data migration or versioning of the backend at all. Since both can be updated at the same time, this will save you weeks if not months of planning and release coordination (not to mention the release managers which would become redundant in that case).

Another advantage: our web application does a lot of backend requests and additionally it also executes a lot of business logic and data transformation itself. Things like properly displaying prices, dates or pluralisation in two languages would have needed to be rewritten from scratch on each platform when going with a native app approach.

## Other Dependencies

This could be anything. For example, if your app is mostly about interacting and finding locations on a map, then a native solution could also work better since a good user interaction for maps is hard to build for the web and much easier on native. Or maybe you need to execute performance-hungry algorithms on the device like end-to-end data encryption which would only be available in a native application as well.

Outside dependencies might also be other customer channels that already exist and offer the same or similar services as your app. For example, when there is a website for your service already, customers will naturally compare the features between your app and the website. If the website offers any feature beyond the features of your app (may it be a reset password function), you will be in constant competition with the website's features. And releasing new versions of a native app can take time. Just look at the [release section of NativeScript](https://docs.nativescript.org/releasing.html).

The Comtravo app is all about booking everything you need for your business trip as well as managing those bookings wherever you are. Therefore we do not depend on any native only features since we can build all we need in the web. To sum it up, here is a brief comparison of the pros and cons:

* Native Applications

  ✅ leverage the maximum device performance for flawless animations or complex algorithms

  ✅ can access platform-specific features like biometric authentication, cloud storage, and others

  🚫 build platform-specific (need to be built, tested, and distributed for each platform individually)

  🚫 require a tailor-made and versioned backend

  🚫 can only be updated through App Store distribution therefore

  🚫 require proper release planning and coordination
  
* Web-Container Applications

  ✅ after the first app distribution, it can be updated across platforms in no time

  ✅ backend services do not need to be versioned since all users run the latest app version

  ✅ users do not need to update the app manually

  ✅ maximum shared codebase, one language, all platforms

  🚫 user interaction and design capabilities are limited to the web

  🚫 using platform-specific features will require a hybrid code architecture

For us at Comtravo the possibility to continuously deliver new features without going through the App Store submission every time was crucial. Beyond that, the fact that we do not have to care about versioning our APIs and always run on the latest version made this a no-brainer. So we took our existing Angular application and packaged it in two AppContainers. Here is how:

## Building a Container-App on iOS

To distribute your app through the App Store you will need to sign up for an [Apple Developer Program](https://developer.apple.com/programs/) first.
Then, of course, you need a mobile-optimized website that you can access to make some changes.

If you have that in place, let's start up [Xcode](https://developer.apple.com/xcode/) and create a new iOS app.
All you basically need to do is to display a WKWebView that uses the full size of the screen. By the time of writing this article, the best way to do so is by using UIKit storyboards (SwiftUi hasn't implemented WKWeb yet). There are plenty of tutorials on how to do that already, [like this one](https://www.hackingwithswift.com/articles/112/the-ultimate-guide-to-wkwebview), but in general it just requires a few lines of code and you are good to go. Besides the feature of passing and loading a URL, the WKWebView also comes with other handy methods that will give you more control over the displayed content. For example, you can implement the `decidePolicyFor` method to decide what URLs are allowed to navigate to. You can also observe the `estimatedProgress` property to show a custom loading bar and only make the View visible when it's fully loaded.

Another feature that you might want to implement is whenever users tab on a link that would usually lead them to the website, they should be landing inside your app instead. This can be done by setting up universal links.
What you basically have to do is to place a file by the name of `apple-app-site-association` on the root level of your website. So it can be accessed like this: `www.your-website.com/apple-app-site-association`
Find out more about the formation and required content of this file [here](https://developer.apple.com/library/archive/documentation/General/Conceptual/AppSearch/UniversalLinks.html).

This will also give you nice features like autocompletion of login credentials in your app and will show a banner on top of your website when it gets opened in Safari.  

That's about it for the coding part! You could continue to polish the WebView rendering and maybe add more native layers to handle loading states or failure. You can also implement a communication layer between the native and javascript code to send data from one to another. But the key parts are already in place by now.

### Upload to iOS App Store

In order to upload your app to the iOS App Store, you need to create an app with the same identifier you used in Xcode on [App Store Connect](https://appstoreconnect.apple.com/login). Here you also need to have your App Store Screenshots, the AppIcon, Description as well as privacy policy in place to be able to submit your App for approval (luckily, this only has to be done once).

When completed, you can upload your build using Xcode and then hit that submit button on App Store Connect.  

And now it's complete, you created and published your Container App to the iOS App Store.

## Building a Container App on Android

On Android, this is even easier than on iOS. Since Google introduced a feature called [Trusted Web Activity](https://developer.chrome.com/docs/android/trusted-web-activity/overview/) you don't even have to write native code here.

You basically only need to prepare two things on your Website. First, you need to properly set up and host your website’s `manifest.json` at the root level of your domain. This will tell your Android App what AppIcon, AppName, or loading screen to use. You can find out more about the specific properties [here](https://developer.mozilla.org/en-US/docs/Web/Manifest).
Second, you need to add a file by the name of `assetlinks.json` to your website so it can be accessed like this: `www.your-website.com/.well-known/assetlinks.json`. To find out more about these files and the App creation flow you can follow this handy [Quick Start Guide provided by Google](https://developer.chrome.com/docs/android/trusted-web-activity/quick-start/). After following the steps you should have your signed APK in place that can be uploaded later to the Google Play Store. Straight forward, isn't it?

### Upload to Google Play Store

Now, similar to what we have done on App Store Connect, we need to create an App on the [Google Play Console](https://play.google.com/console). Fill in all the necessary information for your app and create a release track that holds your previously build APK (again, this also has to be done only once).

Once your App is approved and you tested it on a real device, you can hit the release button to make it public on the Google Play Store.

## Wrapping It Up

And there you have it! You just released a web application on two platforms that are entirely using the same business logic and content. Everything you would have needed to implement twice is already there. Just think of the time it takes to implement multilingual content, user authorization, and backend communication. Now, whenever you update your web application, it will automatically be updated on both platforms the same as on the web.

For us at Comtravo it took only two weeks effectively developing the container apps so they were ready to be shipped to App Stores. The overall planning and preparing of content for the App Stores took us roundabout one month. By choosing this architecture, we were able to save enormous efforts in planning and coordinating a parallel development of two native applications.

Even as I was writing this article we delivered two updates to our application that, you guessed it, got instantly available to all our customers on all platforms.

I hope you enjoyed reading this article and maybe you could take away some information that helps you choose the right architecture for your project.
