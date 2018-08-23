/*
Bluetooth Controler for Line Follower Robot

by Szymon Piotr Krasuski
2017


Application reuqires:
>ControlP5 library added to library folder and imported in program.
>Update jpg image 40pxX40px in project folder named 'update.jpg'
*/


/*
Instruction to serial commands:
'1'-go forward
'2'-go back
'3'-go left
'4'-go right
'5'-stop
'6'-calibrate 0 position
'7'-set line mode
'8'-set manual mode
'l'-go left reversed
'r'-fo right reversed
'L'+$value+'?'-set $value as a speed of left motor
'R'+$value+'?'-set $value as a speed of right motor
'P'+$value+'?'-set $value as a value of Kp
'I'+$value+'?'-set $value as a value of Ki
'D'+$value+'?'-set $value as a value of Kd

Letter+$value+'?' is decoded in robot due to scheme:
1.Detect Letter
2.read string until '?'
3.set read string as float value
*/
import processing.serial.*; //Importing the Serial library.
import controlP5.*; //Importing library for PID values entry and motor sliders
import javax.swing.JOptionPane;

ControlP5 cp5; //Creating GUI object

Serial myPort; // Creating a port variable.
int r,g,b, ron, gon, bon, rof, bof, gof; // initializing colours.
//Definitions of text strings used in user interface
String T1= "FWD";
String T2= "LEFT";
String T3= "RIGHT";
String T4= "REV";
String T5 = "STOP";
String LINE = "Line";
String MAN = "Manual";
String Cal = "Calibrate";
String RLeft = "RLeft";
String RRight = "RRight";
String errorNumber = " ";
String submit = "Submit";
String sPort = "Select Port";
Double kp, ki, kd; //declaration of PID values viariables
int motor1, motor2; //declaration of motors speed level (0-100)
PImage update; //Declaration of update image
 String portName;
 
void setup()
{
 
  size(1000,600); // Creating the display window and defining its' size.
  PFont font = createFont("lucida sans", 30); //define font used in cp5 module
  update = loadImage("update.jpg"); //load update.jpgh image as image
  
  //Setting up ControlP5 user interface
  cp5 = new ControlP5(this);
  
  //Text entry for Kp value
   cp5.addTextfield("Kp")
    .setPosition(20, 100)
      .setSize(200, 40)
        .setFont(font)
          .setFocus(true)
            .setColor(color(255, 255, 255))
              ;
   //Text entry for Ki value           
   cp5.addTextfield("Ki")
    .setPosition(20, 170)
      .setSize(200, 40)
        .setFont(createFont("lucida sans", 30))
          .setAutoClear(false)
            ;
   //Text entry for Kd value
   cp5.addTextfield("Kd")
    .setPosition(20, 240)
      .setSize(200, 40)
        .setFont(createFont("lucida sans", 30))
          .setAutoClear(false)
            ;
   //Two sliders to set left and right motor speed (0-100 range)
  cp5.addSlider("left_motor").setPosition(260,120).setSize(40,250).setRange(0, 100);
  cp5.addSlider("right_motor").setPosition(340, 120).setSize(40, 250).setRange(0,100);
              
     
 //setting text font 
  textFont(font);
  
  
  r = 0; // Setting up the colours.
  g = 0;
  b = 0;
  //Setting up colours for Line/Manual mode buttons [ON-active mode, OFF-inactive mode]
  ron=0;
  gon=0;
  bon=204;
  
  rof=226;
  gof=230;
  bof=255;
  
 
  println(Serial.list()); // IMPORTANT: prints the availabe serial ports.
  //String portName = Serial.list()[4]; // change the 0 to a 1 or 2 etc, to match your port (Play with it until you find the one that works for you- It's probably 11!)
  //myPort = new Serial(this, portName, 9600); // Initializing the serial port.
  selectPort();
  myPort.write('8');//set manual mode
  myPort.write('5');//stop motors
}


void draw()
{
   
  background(91,192,235); // Setting up the background's colour- Blue.
  fill (255,255,255); // Painting the Arrows White.
  triangle(620, 180, 780, 180, 700, 20); // FWD triangle
  triangle(620, 420, 780,420 ,700 ,580 ); //BWD triangle
  triangle(820, 220, 820, 380, 980, 300); //RHT triangle
  triangle(580, 220, 580, 380, 420, 300); //LFT triangle
  triangle(580, 420, 580, 580, 420, 420); //BLeft
  triangle(820,420,820,580,980,420); //BRight
  rect(620, 220, 160, 160, 7); //STOP
  rect(120,480, 200, 100, 7); //Calibrate
  rect(20, 300, 100, 50, 7); //update PID
  rect(250, 400, 50, 50, 7); //update motor1
  rect(330, 400, 50, 50, 7);// update motor 2
  rect(20, 370, 100, 50, 7); //Select Port
  fill(rof, gof, bof); //set colour to OFF
  rect(20,20,200, 70, 7); //Line mode
  fill(ron, gon, bon); //set colour to ON
  rect(220, 20, 200, 70, 7); ////Manual modee
 

  textSize (40); // The arrow keys text size- 40
  fill (0,0,0); // painting it black.
  text(T1, 660, 160); //FORWARD
  text(T2, 460, 310);//RIGHT
  text(T3, 820, 310); //LEFT
  text(T4, 660, 460);//REVERSE
  text(T5, 650, 310);//STOP
  text(LINE, 80,70);//LINE mode
  text(MAN, 250,70); //MANUAL mode
  text(Cal, 140, 550); //CALIBRATE
  text(RLeft, 470, 470);//Reverse left
  text(RRight,820 ,460);//Reverse right
  textSize(17);
  text(sPort, 30, 400); //Select Port
  fill(255,0,0); //Set RED colour
  textSize(20);//Set text size 20
  text(errorNumber,140, 330); //Error Message ('' shows nothing,)
  fill(0,0,0);//Set BLACk colour
  text(submit,40,334); //Submit
  image(update,257,407);//Print update image
  image(update, 337, 407);//Print update image

  //While there is information on serial to read, read it and print.
  while (myPort.available() > 0){
    println(myPort.readString());
  }

}

//Function detecting pressed keys
void keyPressed()
{
 
 
  switch (keyCode) { //Switch case: Sending different signals and filling different arrows red according to which button was pressed.   
    
    case UP: //In case the UP button was pressed:
    myPort.write('1'); // Send the signal 1 -go forward
    println("UP!"); // + Print "UP!" (Debugging only) 
    fill(117,252,101); // + Fill the up triangle with green.
    triangle(620, 180, 780, 180, 700, 20); // FWD triangle
    break;
    
    case DOWN: //Down buton
    myPort.write('2'); //Write 2 - go back
    println("DOWN!"); //Print Down
    fill(117,252,101); // + Fill the up triangle with green.
    triangle(620, 420, 780,420 ,700 ,580 ); //BWD triangle
    break; 

    case LEFT: //Left button
    myPort.write('3'); //Write 3 to serial - go left
    println("LEFT!"); //print LEFT
    fill(117,252,101); //set colour green
    triangle(580, 220, 580, 380, 420, 300); //LFT triangle
    break;
  
    case RIGHT: //Right button
    myPort.write('4'); //Write 4 to serial -go right
    println("RIGHT!"); //print message
    fill(117,252,101); //set green coliur
    triangle(820, 220, 820, 380, 980, 300); //RHT triangle
    break;
  
    case ' ' : //Space button
    myPort.write ('5'); //write 5 to serial - stop!
    println("STOP!"); //write message
    fill(255,0,0); //set red colour
    rect(620, 220, 160, 160, 7); //STOP
    break; 

    case ']' : //] button
    myPort.write('r'); //write r to serial - reverse right move
    fill(117,252,101); //set grreen colour
    triangle(820,420,820,580,980,420); //BRight
    break;

    case '[' : //[ button
    myPort.write('l'); //write l to serial -reverse left move
    fill(117,252,101); //set green colour
    triangle(580, 420, 580, 580, 420, 420); //BLeft
    break;

    case 'Q' : //q button
    //Calibrate
    myPort.write('6'); //write 6 to serial -calibrate
    fill(117, 252, 101); //set green colour
    rect(120,400, 200, 100, 7); //calibrate
    println("Calibrate!"); //print message
    break;
    
    case 'L': //l button
    //Line
    myPort.write('5'); //write 5 - stop move
    myPort.write('7'); //write 7 - line mode
    //if the button is not selected already, switch colours (active mode will be dark blue
    if(ron==0){
      ron=ron-rof;
      rof=ron+rof;
      ron=rof-ron;
      gon=gon-gof;
      gof=gon+gof;
      gon=gof-gon;
      bon=bon-bof;
      bof=bon+bof;
      bon=bof-bon;
    }
    println("Line mode!");   
    break;
     
    case 'M'://m button
    //Manual
    myPort.write('8'); //write 8 - manual mode
    myPort.write('5'); //write 5 - stop
    //if button is not active already then change it's colour to dark blue
    if(ron!=0){
      ron=ron-rof;
      rof=ron+rof;
      ron=rof-ron;
      gon=gon-gof;
      gof=gon+gof;
      gon=gof-gon;
      bon=bon-bof;
      bof=bon+bof;
      bon=bof-bon;
    }
    println("Manual Mode");
    break;
   
   //default - do nothing
    default:
    break;
  }
}

//Function detecting when mouse is pressed
void mousePressed(){
 
  if(mouseX>=620 && mouseX<=780 && mouseY>=20 && mouseY<=180){
     //FORWARD
     myPort.write('1');
     fill(117,252,101); // + Fill the up triangle with red.
     triangle(620, 180, 780, 180, 700, 20); // FWD triangle
    } 
   
  if(mouseX>=620 && mouseX<=780 && mouseY>=220 && mouseY<=380){
     //STOP
     myPort.write('5');
     fill(255,0,0);
     rect(620, 220, 160, 160, 7); //STOP
   } 
   
  if(mouseX>=620 && mouseX<=780 && mouseY>=420 && mouseY<=580){
     //REVERSE
     myPort.write('2');
     fill(117,252,101); // + Fill the up triangle with red.
     triangle(620, 420, 780,420 ,700 ,580 ); //BWD triangle
   } 
   
  if(mouseX>=420 && mouseX<=580 && mouseY>=220 && mouseY<=380){
     //LEFT
     myPort.write('3');
     fill(117,252,101);
     triangle(580, 220, 580, 380, 420, 300); //LFT triangle 
   } 
   
  if(mouseX>=820 && mouseX<=980 && mouseY>=220 && mouseY<=380){
     //RIGHT
     myPort.write('4');
     fill(117,252,101);
     triangle(820, 220, 820, 380, 980, 300); //RHT triangle
   } 
   
  if(mouseX>=820 && mouseX<=980 && mouseY>=420 && mouseY<=580){
     //REVERSE RIGHT
     myPort.write('r');
     fill(117,252,101);
     triangle(820,420,820,580,980,420); //BRight
   }
  
  if(mouseX>=420 && mouseX<=580 && mouseY>=420 && mouseY<=580){
      //REVERSE LEFT
      myPort.write('l');
      fill(117,252,101);
      triangle(580, 420, 580, 580, 420, 420); //BLeft
   }
  
  if(mouseX>=120 && mouseX<=320 && mouseY>=480 && mouseY<=580){
      //Calibrate
      myPort.write('6');
      fill(117, 252, 101);
      rect(120,480, 200, 100, 7);
      println("Calibrate!");
   }
 
   if(mouseX>=20 && mouseX<=120 && mouseY>=370 && mouseY<=420){
     fill(117,252,101);
     rect(20, 370, 100, 50, 7); //Select Port 
     println("Port Selection");
     selectPort();
 }
   
  if(mouseX>=20 && mouseX<=120 && mouseY>=300 && mouseY<=350){
     //PID values change
     fill(117,252,101);
     rect(20, 300, 100, 50, 7); 
     errorNumber=" "; //Reset error message
      try{
         //Try reading PID values from user entry and if everything's fine, write it to serial
         kp = Double.parseDouble(cp5.get(Textfield.class,"Kp").getText());
         ki = Double.parseDouble(cp5.get(Textfield.class,"Ki").getText());
         kd = Double.parseDouble(cp5.get(Textfield.class,"Kd").getText());
         myPort.write("P" + kp + "?");
         myPort.write("I" + ki + "?");
         myPort.write("D" + kd + "?");       
      } catch (NumberFormatException e){
          errorNumber="Ups! Error!"; //In case of error set error message
      }
    //println(kp);
    //println(ki);
    //println(kd); 
   }
   
   if(mouseX>=250 && mouseX<=300 && mouseY>=400 && mouseY<=450){
     //Set MOTOR1 value
     fill(117,252,101);
     rect(250, 400, 50, 50, 7); 
     motor1=round(cp5.getController("left_motor").getValue()); 
     myPort.write("R"+motor1+"?");
     //println(motor1);
  }

   if(mouseX>=330 && mouseX<=380 && mouseY>=400 && mouseY<=450){
     //Set MOTOR2 value
     fill(117,252,101);
     rect(330, 400, 50, 50, 7);
     motor2 = round(cp5.getController("right_motor").getValue());
     myPort.write("L"+motor2+"?");
     //println(motor2);
   }
    
   if(mouseX>=20 && mouseX<=220 && mouseY>=20 && mouseY<=90){
      //Line
      myPort.write('5');
      myPort.write('7');
      if(ron==0){
        ron=ron-rof;
        rof=ron+rof;
        ron=rof-ron;
        gon=gon-gof;
        gof=gon+gof;
        gon=gof-gon;
        bon=bon-bof;
        bof=bon+bof;
        bon=bof-bon;
      }
      println("Line mode!");
   }
   
   if(mouseX>=220 && mouseX<=420 && mouseY>=20 && mouseY<=90){
      //Manual
      myPort.write('8');
      myPort.write('5');
      if(ron!=0){
        ron=ron-rof;
        rof=ron+rof;
        ron=rof-ron;
        gon=gon-gof;
        gof=gon+gof;
        gon=gof-gon;
        bon=bon-bof;
        bof=bon+bof;
        bon=bof-bon;
        }
    println("Manual Mode");
   }
   
}

void openSerialPort(){
   if (portName == null) return;
   if(myPort != null) myPort.stop();
  
   myPort = new Serial(this, portName, 9600);
   myPort.bufferUntil('\n');
  
}

//Function to select serial port from list
void selectPort(){
  String result = (String) JOptionPane.showInputDialog(frame,
  "Select the serial port that corresponds to your Arduino board.",
  "Select serial port",
  JOptionPane.QUESTION_MESSAGE,
  null,
  Serial.list(),
  0);
 
  if(result != null){
     portName = result;
     openSerialPort();
  }
}
