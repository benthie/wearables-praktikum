<img src="/docs/img/eyeDrops_logo.png" height="60"><br>
<i>     a project by Marlene Fiedler, Lorenz Miething and Benjamin Thiemann</i><br>
<br>
In the context of the lab course "Wearable Computing Systems", which started at the end of Oct 2016, we were asked to build our own wearable device. Our idea since then was to build a blink detection system that recognizes the user's lack of blinking when sitting in front of the computer. With a distance sensor that is monitoring the eye and a custom-built software the user of our wearable will be stimulated to blink by blurring the computer screen.

#Documentation

Now - at the end of the project - we proudly present our results. All the single bits and pieces of our project have been documented in order to deliver high reusability for anybody who wants to work on the project after the end of the semester the lab took place. This repository is mainly devided into the two sub parts hardware and software. The hardware itself consists of two different PCBs and the fixation parts to fix the PCBs to different kinds of glasses, as well as 3D printed glasses for users who usually do not wear any. All documenting files should enable you to rebuild the hardware such that you have a working system, which will be accepted by the software parts and then run without difficulty.<br>
<br>
The developed software has been published under the open source MIT License and is running as it is. It consists of two parts, namely an RFduino sketch and a Mac OS X Cocoa application. The sketch for the RFduino contains the blink detection algorithm and is able to communicate with the Cocoa app via Bluetooth Low Energy. For detailed information about the blink detection algorithm please see [here](#eye-blink-detection-algorithm). The Cocoa app's source code has both copious commenting and a [Doxygen documentation](https://benthie.github.io/wearables-praktikum/). The application's graphical user interface will be explained [below](#eyedrops-cocoa-application) and is additionally explained in a short [video](https://youtu.be/3qRnkdi4qJQ).


##Table of contents
- [Requirements](#requirements)
- [How to use](#how-to-use)
- [Hardware](#hardware)
  - [VCNL4020](#vcnl4020)
  - [RFduino](#rfduino)
  - [3D-printed parts](#3d-printed-parts)
- [Eye blink detection algorithm](#eye-blink-detection-algorithm)
- [eyeDrops Cocoa Application](#eyedrops-cocoa-application)
  - [Blur mode](#blur-mode)
  - [Bluetooth connection](#establishing-bluetooth-le-connection)
  - [User profile manager](#user-profile-manager)
  - [Preferences](#preferences)
  - [Calibration](#calibration)
  - [Ready to use](#ready-to-use)
  - [Executable File](#executable-file)
  - [Doxygen documentation](https://benthie.github.io/wearables-praktikum/)
- [Live Demo](#live-demo)
- [Credits](#credits)
- [License](#license)

###Requirements
- Arduino IDE ([Arduino software](https://www.arduino.cc/en/main/software)) 
- RFduino Package ([Link to the Git](https://github.com/RFduino/RFduino/blob/master/README.md))
- Mac OS X (sorry for that crucial restriction!)
- Bluetooth Low Energy (BLE - also called Bluetooth 4.0) capable Mac
- RFduino USB Shield ([RFD22121](http://www.rfduino.com/product/rfd22121-usb-shield-for-rfduino/index.html) or [RFD22124](http://www.rfduino.com/product/rfd22124-pcb-usb-shield-for-rfduino/index.html))
- CorePlot Framework ([Installation Guide](https://github.com/core-plot/core-plot/wiki/Using-Core-Plot-in-an-Application))

###How to use

So how to use our wearable? Simply grab the 3d-printed clips and the fitting slider, mount the electronics together with a battery pack on it, which then altogether forms the so called "<b>wearable</b>" and make sure that your Mac fullfills the above requirements. Plug the RFduino USB shield into your Mac and upload our [RFduino sketch](software/RFduino) to the wearable. After completing this step the last thing to do is to download the [Xcode project](software/cocoa-app), follow the [CorePlot library installation guide](https://github.com/core-plot/core-plot/wiki/Using-Core-Plot-in-an-Application) and start the eyeDrops application and have fun exploring.<br>
<br>
<i>Note:</i> If you want to use the compiled and built application (.app file) please follow the steps described in section [Executable File](#executable-file).

#Hardware

Our Hardware consits mainly of three parts: The sensor that is detecting the blinks, the microcontroller RFduino and our 3D-printed parts, used to hold the sensor and microcontroller in place.

##VCNL4020

The sensor used in our wearable is the VCNL4020 (http://www.vishay.com/docs/83476/vcnl4020.pdf). It is a proximity and ambient light sensor with a built-in infrared emitter and photo diode. The data obtained from the sensor vary, depending on how much light is reflected back to the sensor. Due to its high 16-bit-resolution and the operating range from 1 to 200 mm, it is possible to determine the difference of distance when pointing at an open or a closed eyelid. The data of the VCNL4020 can be transferred via an I²C Interface. Furthermore, interrupts can be sent. 

<p align="center">
<img src="https://github.com/benthie/wearables-praktikum/blob/master/docs/img/VCNL4020.png" alt="VCNL4020.png" width="400">
<br>Figure 1: Sensor VCNL4020.
</p>

A custom PCB was designed for the VCNL4020. The goal was to get a board that can be attached to a clip, mounted in the front of spectacles, worn by the user. In order to not disturb the user while working, the PCB should be as small as possible. The first design featured pull-up resistors for the data, clock and interrupt signals, decoupling capacitors and five header pins for power supply, the I²C interface and the interrupt signal. 

<p align="center">
<img src="https://github.com/benthie/wearables-praktikum/blob/master/docs/img/PCB-VCNL4020-large.png" alt="PCB-VCNL4020-large.png" width="400">
<br>Figure 2: First PCB design for VCNL4020.
</p>

However, the first PCB design had to be revised due to its size, by moving the pull-up resistors to the second PCB and using small pads instead of the header pins. The revised PCB features a size of only 11 mm times 12 mm. The schematics and layouts of both versions  can be found [here](https://github.com/benthie/wearables-praktikum/tree/master/hardware/eagle).

The revised PCB was milled, using a Cirqoid CNC mill (http://cirqoid.com/). Both the milled PCB without components and the populated PCB can be seen here:

<p align="center">
<img src="https://github.com/benthie/wearables-praktikum/blob/master/docs/img/PCB-VNCL.jpg" alt="PCB-VNCL.jpg" width=200>
<br>Figure 3: milled PCB for VCNL4020.
</p>

<p align="center">
<img src="https://github.com/benthie/wearables-praktikum/blob/master/docs/img/sensorboard_populated.jpg" alt="sensorboard_populated.jpg" width=200>
<br>Figure 4: populated PCB for VCNL4020.
</p>

A ribbon cable was attached to the pads, so that the PCB for the VCNL can be connected to the RFduino PCB, which will be described in the following chapter.

##RFduino

The microcontroller used in our project is an RFduino (http://www.rfduino.com/) which features a bluetooth low energy (BLE) compatible radio transceiver. It can be programmed using the Arduino IDE.

<p align="center">
<img src="https://github.com/benthie/wearables-praktikum/blob/master/docs/img/RFDuino.png" alt="RFDuino.png" width=400>
<br>Figure 5: RFduino
</p>

A custom PCB was made for the RFduino, featuring a 3.3 V voltage regulator, decoupling capacitors, a reset button, the mentioned pull-up resistors for the VCNL4020, header pins to connect to the ribbon cable leading to the VCNL4020 PCB, header pins for programming the RFduino and a screw terminal for the input voltage. The populated PCB can be seen here:

<p align="center">
<img src="https://github.com/benthie/wearables-praktikum/blob/master/docs/img/RFduino_board.jpg" alt="RFduino_board.jpg" width=400>
<br>Figure 6: PCB for RFduino 
</p>

The schematic and layout of the PCB can be found [here](https://github.com/benthie/wearables-praktikum/tree/master/hardware/eagle).

#Eye blink detection algorithm

The blink detection algorithm can be divided in a filtering and a processing stage. The logarithmically scaled incoming raw data of the sensor are converted into distances of arbitrary unit. Any offset is removed by computing the differences between the samples and an equally weighted moving average filter with a window size of 16 (experimentally determined) is applied to the derivative of the data. With that, the filtering stage is completed and the actual detection algorithm begins, which is applied to the last 200 samples.<br>
Instead of going through all samples within that window for every new sample, the characteristic values are kept in real time as the samples come in.<br>
In order to understand the algorithm more easily let’s first have a look at the pattern that has to be detected. Since the different eye blinks vary in duration and peak height as shown in figure 7, the algorithm has to accomodate for this dynamic behaviour. 
<p align="center">
<img src="https://github.com/benthie/wearables-praktikum/blob/master/docs/img/accumulated_blinks_clean.png" alt="Accumulated eye blinks" width=400>
<br>Figure 7: Accumulated eye blinks with varying durations from single person
</p>
Therefore, a simple pattern correlation would not perform very well. Instead, the algorithm looks for a certain dynamic pattern in the preprocessed data. It performs edge detection and zero crossing detection by comparing the current value with the previous one. The values are split into four areas: above positive threshold, between positive threshold and zero, between zero and negative threshold and below negative threshold. With this in mind six different crossings can be detected creating the following algorithm to detect the actual eye blink as shown in figure 8.
<p align="center">
<img src="https://github.com/benthie/wearables-praktikum/blob/master/docs/img/detailed_single_blink.png" alt="Step by step eye blink" width=400>
<br>Figure 8: Step by step blink detection
</p>
1. Zero has to be crossed from a positive to a negative value. This means that the measured distance is decreasing and the eye lid is closing. Zero was just cross for point 1.
2. The negative threshold is crossed downwards. This means that the measured distance decreases less significantly and the eye lid stops closing.
3. The negative threshold is crossed upwards. At this point the minimum value and its index between the two negative threshold crossings is determined from the sample buffer. If the sample number between the initial zero crossing and the determined minimum value is within a certain range and the minimim value is above a certain value. With that the first neces- sary condition is met and the blink level indicating the progress of the current eye blink to be detected is increased by one.
4. Zero is crossed upwards. This does not affect the algorithm and can happen multiple times with alter- nating downward zero crossings at this stage. The number of zero crossings is recorded for further anal- ysis at a later stage of the algorithm and refers to the duration the eye is closed during an eye blink.
5. The positive threshold is crossed upwards. This means that the eye lid is beginning to open again.
6. The positive threshold is crossed downwards. At this point the maximum value and its index between the two positive threshold crossings is determined. If the sample number between the last minimum value and the maximum value is within a certain range, the number of zero crossings does not exceed a certain limit, the maximum value itself does not exceed a certain value either, and the blink level has a value of 1 indicating a previes eye closing event, the blink level is increased again by one. This means the eye is stopping to open and therefore almost open again. It is now assumed, that an actual eye blink was detected for real time application.<br>If any of the above conditions is not met, the blink level is reset to zero.
7. Zero is crossed downwards. If the overall duration of the eye blink is within a certain range the blink detection is complete, the blink level is reset to zero and an eye blink is reported. This means that the eye is fully open again or at least the eye lid movement cannot be detected by the sensor anymore for the remaining eye opening procedure.

The actual threshold crossing detection is extended with a hysteresis procedure. In order to cross a threshold upwards the threshold plus a hysteresis value has to be crossed.
In order to cross it downwards, the threshold minus a hysteresis value has to be crossed. This ensures, that a small fluctuation in the data caused by noise does not mess up the steps of the algorithm. The hysteresis is shown as a gray area in figure 8.<br>
Testing this algorithm on multiple persons showed that it does not necessarily work out of the box for everybody but certain paramaters such as the thresholds, hysteresis and sample distances between the steps have to be adjusted. As shown in figure 7 the durations and peak values for only a single person differs from eye blink to eye blink. Looking at the data for different persons this varies even more.

##3D-printed parts

The 3D-printed parts include a clip and slider for the VCNL4020 PCB, a clip for the RFduino and spectacles for users who do not usually wear them. These parts were designed using the 3D CAD software Solidworks (http://www.solidworks.de/) and printed using the 3D-printer Makerbot Replicator 2X (https://store.makerbot.com/printers/replicator2x/). The used filament consists of ABS.

<p align="center">
<img src="https://images.makerbot.com/products/MP04952/MP04952_l_1.jpg" width=400>
<br>Figure 9: 3D-Printer Makerbot Replicator 2X
</p>

Since our product shall be usable with the users own spectacles, both clips were designed in three different sizes, so that they can be attached to temple arms of different widths. The clip for the VCNL4020 was made as small as possible and printed with transparent filament, in order to reduce the impact in the visual field of the user.

<p align="center">
<img src="https://github.com/benthie/wearables-praktikum/blob/master/docs/img/Clip-7.PNG" alt="Clip-7.png" width=400>
<br>Figure 10: Clip for VCNL4020 PCB
</p>

Due to different anatomies of different users, like smaller or bigger eyes, eyeballs located further in- or outside the head, etc., it should be possible to adjust the position of the VCNL4020 PCB. Therefore, the PCB is not directly attached to the clip, but instead attached to a slider, which is itself slided into the clip.

<p align="center">
<img src="https://github.com/benthie/wearables-praktikum/blob/master/docs/img/Slider-3.PNG" alt="Slider-3.png" width=400>
<br>Figure 11: Slider for VCNL4020 PCB
</p>

The slider was designed with different inclinations, so that the angle between the temple arms and the PCB can be adjusted. There are also sliders that lower the position of the PCB with respect to the height of the temple arms. These exchangable sliders allow adjustment to different anatomies.

<p align="center">
<img src="https://github.com/benthie/wearables-praktikum/blob/master/docs/img/Slider-3-lower.PNG" alt="Slider-3-lower.png" width=400>
<br>Figure 12: lower Slider for VCNL4020 PCB
</p>

In order to make adjustments easier, we designed further clips containing magnets. With these, it was possible to attach magnet-containing 3D-printed adapter that were stuck to the PCB. These adapters were also printed with different inclinations, so that, depending on the users anatomy, the sensor would always be well adjusted. However, very thin magnets were not strong enough to hold the adapter in place and thicker magnets were too thick, so that the PCB was encountered disturbing for the user.
Another approach was a 3D-printed ball joint, which could not be used neither, due to the low printing quality for very small round objects. <br>
<br>

In order to attach the RFduino PCB to the users spectacles, there is another clip. This clip is used without a slider. Instead the PCB is directly attached to the clip, held by two tappets. There is a cavity in the clip, so that the reset button of the PCB can be pressed easily.

<p align="center">
<img src="https://github.com/benthie/wearables-praktikum/blob/master/docs/img/Clip-RFDuino-Board-7.PNG" alt="Clip-RFDuino-Board-7.PNG" width=400>
<br>Figure 13: Clip for RFduino PCB
</p>

The 3D-printed spectacles with the attached clips can be seen in the following graphic:

<p align="center">
<img src="https://github.com/benthie/wearables-praktikum/blob/master/docs/img/Glasses-with-clips-for-poster.PNG" alt="Glasses-with-clips-for-poster.PNG" width=400>
<br>Figure 14: Spectacles with clips 
</p>

The SLDPRT-files as well as the 3D-printing-files for the described parts can be found [here](https://github.com/benthie/wearables-praktikum/tree/master/hardware/3dprinting).

#eyeDrops Cocoa application

The eyeDrops application is designed to offer a highly comfortable interface between the user and the wearable. The main task of the entire system is to detect a lack of blinking and then react correspondingly. Our implemented reaction to such a lack of blinking is a progressive blurring of the screen in order to enforce an eye blink. A blurred screen can be cleared by a simple blink, which was apparently long overdue. And since the app only needs to control the screen, it was designed as a pure menubar application, that is having no active window but just an icon in the menu bar.<br>
<br>
We chose Mac OS X as the target operating system after a long period of attemps (with a lot of effort) to deliver a platform independent software for our wearable. In the end it was a sum of facts that influenced our decision. The main problem, to begin with, was to build a software that is able to blur the complete screen. Here, Java was the first programming language we tried, but we could not achieve a working version. To do so, one would have to enter a very low level graphics programming since Java cannot make use of a window compositing manager. With Cocoa and Objective-C on the other hand, we could deliver a working blurring of the screen by simply using Quartz Compositor of OS X. In the following process we tried to stick to Java for the main program, but then there was no working BLE stack for Java around that would work on all desired platforms (Windows, Mac, Linux) and thus there was no need to stick to Java anymore. Since two third of the developers were using a Mac and we already had a working software for blurring the screen, it stood to reason that we write the complete software just for Mac. And that is what we did after all.<br>
<br>
To get the eyeDrops application running, download the source code from the [software folder](/software/cocoa-app) and launch `eyeDrops.xcodeproj` with Xcode. Make sure that you properly include the CorePlot framework as described [here](https://github.com/core-plot/core-plot/wiki/Using-Core-Plot-in-an-Application). The project is now ready to be built. The following documentation explains how to use the application you should be able to see now.


##Blur mode

<p align="center">
<img src="https://github.com/benthie/wearables-praktikum/blob/master/docs/img/menu_item_off.png" alt="menu_item_off.png">
<br>Figure 15: Application in off state.
</p>

As you can see in Figure 15, there is no active window but only a menubar icon which pops down a usual menu when you click on it. In the above image the icon is gray and not white, telling the user that blur mode is turned off.

<p align="center">
<img src="https://github.com/benthie/wearables-praktikum/blob/master/docs/img/menu_item_on.png" alt="menu_item_on.png">
<br>Figure 16: Application in on state.
</p>

In Figure 16, however, the icon is white and thus signalizing that blur mode is activated. To switch bewteen those two states simply <b>ctrl-click</b> on the menubar item. If blur mode is actived and in case that a device is connected, the screen would be blurred if the user did not blink in adjustable time interval. See the [settings](#preferences) section for more information about the allowed time interval without an eye blink.

##Establishing Bluetooth (LE) Connection<a name="establishing-bluetooth-le-connection" />

In order to establish a bluetooth connection with the wearable, which is the next necessary and logical step when setting up the system, the first thing to do is scanning for bluetooth nearby. This can be either done via the menuitem <i>Scan for devices</i> or automatically by the app. The latter way needs a setting in the <i>General</i> tab in the [Preferences Window](#preferences).<br>
<br>
After a successful scan all the available devices are listed in the submenu <i>Available Devices</i>. Connecting to the device can again be done either via selecting the corresponding menuitem or automatically by the app. The second way needs a setting in the <i>General</i> tab in the [Preferences Window](#preferences).<br>

<p align="center">
<img src="https://github.com/benthie/wearables-praktikum/blob/master/docs/img/menu_devices_2.png" alt="menu_devices_2.png">
<br>Figure 17: List of available devices.
</p>

A connected device is represented with a check mark next to its name. Another click on that same menuitem would then cancel the connection with the device. Selecting another device which is currently not the connected one would simply switch the connection to that device.<br>
<br>
In case that a connection was successfully established, the wearable now needs a user profile to work with. This user profile contains the paramerters used by the blink detection algorithm. Without a valid user the wearable will be idle.

##User profiles / profile manager<a name="user-profile-manager" />

In order to obtain a valid user profile either load an XML file containing one or more valid profiles or use the systems [calibration](#calibration) procedure to create a new profile.

<p align="center">
<img src="https://github.com/benthie/wearables-praktikum/blob/master/docs/img/preferences_profiles2.png" alt="preferences_profiles.png">
<br>Figure 18: Preferences - User profile manager.
</p>

The default directory the app is working in is `/Users/<CurrentUser>/eyeDrops` = `~/eyeDrops`, where `<CurrentUser>` is the name of the currently logged in user. This directory is created during the app's launching process and will of course not be overwritten if it already exists. You can put your XML file in this directory and restart the app, which will lead to an automatic reading of the profiles contained in XML file, or you click <i>Browse</i> in the <i>Profiles</i> tab in the Preferences Window (see Figure 18) and manually select your XML file there. After setting the new path, the profiles will be automatically read from the file and displayed in the TableView in the profile manager. Selecting a profile from that table will display the user profile's content in the TextView next to the table. It is also possible to delete a profile by clicking <i>Delete profile</i> or to create a new profile by clicking <i>Create new profile</i>, which will then open up the [calibration window](#calibration).

##Preferences

The system wide settings can be changed in the <i>General</i> tab in the Preferences Window (see Figure 19). When starting the eyeDrops app for the first time, this settings will be initialized with values we used during the development phase. When properly closing the app, all made changes will be stored in `settings.txt` in the default directory and reloaded at the next launching process. That way your settings do not get lost.

<p align="center">
<img src="https://github.com/benthie/wearables-praktikum/blob/master/docs/img/preferences_general.png" alt="preferences_profiles.png">
<br>Figure 19: Preferences - General settings.
</p>

###Blurring settings
- <b>Maximal Blur Radius:</b> determines how strong your screen gets finally blurred.
- <b>Blur Step:</b> determines the step increase while blurring (the smaller the value, the smoother the blurring).
- <b>Blur Speed:</b> determines the time delay between two steps (the smaller the value, the longer the blurring up to the maximal radius takes).
- <b>Allowed Time Without Blinking:</b> the time interval in which at least one blink has to occur.

###Bluetooth settings
- <b>Automatically scan:</b> determines whether the app automatically scans for devices.
- <b>Automatically connect:</b> determines whether the app automatically connects to the last known device.

###Battery Level
- This LevelIndicator shows the battery level of the wearable. The indication here is not really proportional to the battery voltage but to the voltage after the voltage regulator in the PCB. <!--For more information about this see the [report TODO](/docs/report.pdf).-->

##Calibration

As explained above, calibration is essential for having a properly working blink detection algorithm. Since every eye is unique, differing shapes, sizes and positions in the skull are what the sensor is facing. And due to those inequalities the measured distances to the eye vary from one user to the other. The implemented calibration procedure let's the user define his or her individual calibration parameters, which are then uploaded to the wearable as well as stored in a profile on the computer. More information about the calibration and the different parameters used to detect a blink is elaborately described [above](#eye-blink-detection-algorithm).

<p align="center">
<img src="https://github.com/benthie/wearables-praktikum/blob/master/docs/img/calibration_window.png" alt="calibration_window.png">
<br>Figure 20: Calibration window - On start-up.
</p>

Figure 20 shows the calibration window directly after start-up. Both eyeDrops app and wearable are now in calibration mode  where the RFduino can be triggered to continuously send data packages containing sensor raw data and information about whether a blink was detected or not until a stop message arrives.

<p align="center">
<img src="https://github.com/benthie/wearables-praktikum/blob/master/docs/img/animation.png" alt="animation.png">
<br>Figure 21: Calibration animation (two successive steps).
</p>

A custom-built animation (see Figure 21) is used to guide the user through the data acquisition phase of the calibration. This phase takes nine seconds and should contain four blinks (represented by the larger circles). It can be run testwise without receiving any data, just to get to know the procedure by clicking the button <i>Run Test</i>.<br>
<br>
The completion of the data acquisition will be announced by an pop-up alert with instructions for the next steps. Afterwards the data will be plotted in the two designated graphs.

<p align="center">
<img src="https://github.com/benthie/wearables-praktikum/blob/master/docs/img/calibration_window2.png" alt="calibration_window2.png">
<br>Figure 22: Calibration window - After receiving and plotting the sensor and blink data.
</p>

A completed data acquisition phase can be seen in Figure 22. The preset values on the right side of the calibration window turned out to make sense for most of test users and can be adopted for new profiles without being worried about bad performance. The only two values that are mandatory to be set by the user are the threshold values. These can be obtained by simply clicking on the sensor data graph (top). A red and a blue line will appear for negative resprectively positive threshold. Place the lines such that any noise lies between the threshold values. A good guiding value is to set the thresholds to half of it's max value. After setting the threshold values the user can either do another calibration with the newly gained values and check if the algorithm now detects (more) blinks or directly save the profile with the option to directly use the new profile.<br>

###Ready to use

Now that a valid profile has been created and uploaded to the wearable, the system is ready to use. Enable the [blur mode](#blur-mode) and enjoy the experience with the system.

###Using the Cocoa executable (.app file)<a name="executable-file" />

If you do not want to always launch the application out of Xcode, you can use an executable .app file. After running the app out of Xcode, an .app file has been automatically created there. In your project navigator in Xcode you can find it in the `Products` folder. Right-click on `eyeDrops.app` and select `Show in Finder`. The opened folder contains the app as well as two frameworks. Those frameworks must be copied into `/System/Library/Frameworks` to make the `eyeDrops.app` launchable.

##Live Demo

[Link to youtube video](https://www.youtube.com/embed/3qRnkdi4qJQ)

##Credits

<b>The Noun Project - Source for the used items:</b>
- <i>Rohit M S:</i> Creator of the main icon
- <i>Nicolas Morand:</i> Creator of the profiles icon
- <i>Guilhem:</i> Creator of the battery icon
- <i>Viktor Vorobyev:</i> Creator of the bluetooth icon

##License

This project has been published under the MIT License. 
