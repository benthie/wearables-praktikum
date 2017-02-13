# wearables-praktikum

<b>EyeDrops</b><br>
<i>a project by Marlene Fiedler, Lorenz Miething and Benjamin Thiemann</i>

In the context of the Embedded Systems Lab "Wearables", which started at the end of Oct 2016, we were asked to build our own wearable device. Our idea since then is to build a blinking detection system that recognizes the user's lack of blinking when e.g. sitting in front of the computer screen. With a custom-built software the user of our device will be stimulated to blink without even noticing that he has been doing so.

##Documentation

All the single bits and pieces of our project have been documented in order to deliver high reusability for anybody who wants to work on the project after the end of the semester the lab took place. This repository is mainly devided into the two sub parts hardware and software. The hardware itself consists of the electronics and the fixation parts (clips), to fix the electronics to different kind of spectacles. All documenting files should enable you to rebuild the hardware such that you have a working system which will out of the box communicate with the software.
<p>
The developed software has been published under an open source license and is running as it is. It also consists of two parts, namly an RFDuino sketch and a Mac OS X Cocoa Application. The sketch for the RFDuino contains the blink detection algorithm and is able to communicate with the Cocoa App via Bluetooth Low Energy. For detailed information about the blink detection algorithm please see [the final report (TODO)](docs/readme.md). The Cocoa App's source code is both amply commented and Doxygen documented. The Doxygen documentation can be found [here (TODO)](docs/html/index.html). The application's graphical user interface will be explained in the following and is additionally explained in a short video. [Link to the videos (TODO)](https://www.youtube.com/watch?v=wOwblaKmyVw).

###How to use

So how to use our wearable? Simply get your glasses, grab the clips with the mounted electronics and a battery pack, which altogether forms the so called "<b>wearable</b>" and start the software on both the RFDuino and your Macintosh (sorry for that crucial restriction!).


Requirements
Arduino IDE ([Arduino software](https://www.arduino.cc/en/main/software)) 
Mac OS X

- Hardware
- Software


Learn more about the developed MacOS X Cocoa Application.
