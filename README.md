TODO
  - hardware nutzt sensor
  - icon copyrights
  - goals
  - icon does not change when menubar is not black

# wearables-praktikum

<b>eyeDrops</b><br>
<i>a project by Marlene Fiedler, Lorenz Miething and Benjamin Thiemann</i>

In the context of the Embedded Systems Lab "Wearables", which started at the end of Oct 2016, we were asked to build our own wearable device. Our idea since then is to build a blink detection system that recognizes the user's lack of blinking when e.g. sitting in front of the computer. With a custom-built software the user of our wearable will be stimulated to blink without even noticing that he has been doing so (as far as the theory is concerned).

##Documentation

Now - at the end of the project - we proudly present our results. All the single bits and pieces of our project have been documented in order to deliver high reusability for anybody who wants to work on the project after the end of the semester the lab took place. This repository is mainly devided into the two sub parts hardware and software. The hardware itself consists of the electronics and the fixation parts (clips), to fix the electronics to different kind of spectacles. All documenting files should enable you to rebuild the hardware such that you have a working system which will out of the box communicate with the software.<br>
<br>
The developed software has been published under an open source license and is running as it is. It also consists of two parts, namly an RFDuino sketch and a Mac OS X Cocoa Application. The sketch for the RFDuino contains the blink detection algorithm and is able to communicate with the Cocoa App via Bluetooth Low Energy. For detailed information about the blink detection algorithm please see [the final report (TODO)](docs/readme.md). The Cocoa App's source code has both copious commenting and a Doxygen documentation, which can be found [here (TODO)](docs/html/index.html). The application's graphical user interface will be explained [below](##eyeDrops Cocoa Application) and is additionally explained in a short video. [Link to the videos (TODO)](https://www.youtube.com/watch?v=wOwblaKmyVw).

###Requirements
- Arduino IDE ([Arduino software](https://www.arduino.cc/en/main/software)) 
- RFDuino Package ([Link to the Git](https://github.com/RFduino/RFduino/blob/master/README.md))
- Mac OS X (sorry for that crucial restriction!)
- RFDuino USB Shield ([RFD22121](http://www.rfduino.com/product/rfd22121-usb-shield-for-rfduino/index.html) or [RFD22124](http://www.rfduino.com/product/rfd22124-pcb-usb-shield-for-rfduino/index.html))

###How to use

So how to use our wearable? Simply grab the 3d-printed clips, mount the electronics together with a battery pack to it, which then altogether forms the so called "<b>wearable</b>" and make sure that your Mac fullfills the above requirements. Plug the RFDuino USB shield into your mac and upload our RFDuino sketch to the wearable. After completing this step the last thing to do is start the eyeDrops Application and have fun exploring.

##eyeDrops Cocoa Application

The eyeDrops Application is designed to offer a highly comfortable interface between the user and the wearable. Main task of the entire system is to detect a lack of blinking and then react correspondingly. The implemented reaction to such a lack of blinking is a progressive blurring of the screen in order to enforce an eye blink. A blurred screen can be cleared by a simple but long overdue blink. And since the app only needs to control the screen, it was designed as a pure menubar application, that is there is no active window but just an icon in the menu bar.

###Blur mode

<p align="center">
<img src="https://github.com/benthie/wearables-praktikum/blob/master/docs/img/menu_item_off.png" alt="menu_item_off.png">
<br>Figure 1: Application in off state
</p>

As you can see there is no active window but only a menubar icon which pops down a usual menu when you click on it. In the above image the icon is gray and not white, telling the user that blur mode is turned off.

<p align="center">
<img src="https://github.com/benthie/wearables-praktikum/blob/master/docs/img/menu_item_on.png" alt="menu_item_off.png">
<br>Figure 2: Application in on state
</p>

This time the icon is white and thus signalizing that blur mode is activated. To switch bewteen those two states simply <b>ctrl-click</b> on the menubar item. If blur mode is actived and in case that a device is connected, the screen would be blurred if the user did not blink in adjustable time interval. See the [settings](###Preferences) section for more information about the allowed time interval without an eye blink.
###Scanning for devices



###Establishing Bluetooth (LE) Connection

###Preferences

###User profiles

###Calibration

And with this mechanism working, we have a fucntioning system that also fullfills our initial goal.<br>
<br>



<br>
(Our initial goal, to be able to force the user to blink without him being aware that he did so, has not yet been verified.)<br>
<br>




Here the 

The main function of the system - to break it down - is detecting a lack of blinking and corresponding reaction to it. 

The blink detection is done in the RFDuino on the wearble and will be communicated to the Cocoa App, which is then able to recognize a lack of blinking. 


Several integrated features 
