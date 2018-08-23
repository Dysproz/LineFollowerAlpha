# Line Follower Alpha
## Arduino robot controlled over Bluetooth with line following feature
###### by Szymon Piotr Krasuski 
###### 2016, Warsaw

![Robot](https://github.com/Dysproz/LineFollowerAlpha/blob/master/Photos/robot1.jpg)

![Robot](https://github.com/Dysproz/LineFollowerAlpha/blob/master/Photos/robot3.jpg)

## Intro

This project implements quite a few technologies:

###### Transoptors

It's a simple element with built in LED and transistor.
LED gives constant light that reflect the surface under transoptor and returns. Depending on how much light comes back, transistor regulates voltage on a 10k resistor.

In this project I used 7 transoptors to determine position of a line under the robot (the more different is line's colour from surface's colour, the better robot detects this line).

Transoptors should be mounted close to the surface tto minimalize noise from daylight.

###### H-bridge

H-bridge is a well known circuit used in driving motors, generating PWM or generating 1Phase AC voltage.

In this project I use it to drive 2 DC motors.
Although, I use PWM to control the speed of motors with changing PWM's duty.

##### Bluetooth module HC-05

It's a simple module to connect arduino with computer via Processing app. It allows us to control robot with computer interface and change mode of work.

## Circuit
Circuit is pretty simple:
![Circuit](https://github.com/Dysproz/LineFollowerAlpha/blob/master/Photos/robot4.jpg)
![Circuit](https://github.com/Dysproz/LineFollowerAlpha/blob/master/Photos/schema.png)

## Code

To run this project you need code for arduino in your robot and processing app on your computer.

###### Arduino Code

Arduino is used to read values of voltage on transoptors, drive H-Bridge and communicate with Bluetooth module.

Code has a set_point variable with stored 0 position for line following mode.
set_point can be measured at any time with function kalibruj() that is initialized with physical button on robot or virtual button Calibrate on control panel.

Calibrating process:
1.Both motors stop.
2.Robot reads 50 times values of transoptors and then finds out average value (it's really sensitive and sometimes values may be too big or too small).
3.Every sensor has it's weight declared in program that in result generates single int value as position.
4.With new set_point we need to set PID controller again so values for P, I and D are resetted to 0.

P, I, D values can be set from control panel.
Robot reads values all the time and counts error from desired position and fits proper action.

In line following mode robot can perform 3 actions:
Go straight - both wheels work and with calibrated speed of both axis robot goes straight.
Go left - Left wheel stops and right wheel make rotary move to left
Go right - The same as Go left, but right wheel stops and left one moves

Manual mode adds 4 more actions:
Stop - both wheels stop
Reverse - both wheels spin in the other direction and robot goes backward
Go reverse left - left wheel is stopped and right wheel spins int he oposite direciton
Go reverse right - the same situation as with go reverse left, but right wheel is stopped

The speed of motors can be also controlled with PWM duty cycle.
It's useful, because construction is not ideal and bend sometimes.
From control panel it's possible to set speed of motors and calibrate both axis.

###### Processing Code

Processing code is based on this control panel:
![Robot](https://github.com/Dysproz/LineFollowerAlpha/blob/master/Photos/menu.PNG)

Right side of the panel is to control move in manual mode.
Calibrate button is for calibration
KP, KI and KD fields are to enter values for PID controller. Clicking the Submit button sets entered values.
In the left top corner is switch for manual and line following mode. Clicking Manual opens manual mode and clicking Line opens line following mode.
Sliders are to set speed of motors. Each slider has update button under it. Set speed value on slider and update it with button.

At the beginning of app you can choose bluetooth port to connect to arduino.
![Robot](https://github.com/Dysproz/LineFollowerAlpha/blob/master/Photos/port.PNG)

To run processing code you have to add libraries from Libs folder to processing libraries.

