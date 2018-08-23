//A project by Szymon Piotr Krasuski
//Warsaw, 2016
long sensors[]={0, 0, 0, 0, 0, 0, 0};
int position, positionKal[50], temp;
int sensors_sum;
long sensors_average;
int safety;
int set_point = 3908;
double kp, ki, kd;
int proportional, integral, derivative, last_proportional, error_value;
int motor1=6, motor2=5, motor1rev=10, motor2rev=9, CalButton=3;
int minSpeed = 100, PWMSpeed1 = 50, PWMSpeed2 = 100;
int mode, cmd;

void setup() {
  pinMode(A0, INPUT); //OPTO 1 <--right
  pinMode(A1, INPUT); //OPTO 2
  pinMode(A2, INPUT); //OPTO 3
  pinMode(A3, INPUT); //OPTO 4
  pinMode(A4, INPUT); //OPTO 5
  pinMode(A5, INPUT); //OPTO 6
  pinMode(A6, INPUT); //OPTO 7 <--left
  pinMode(motor1,OUTPUT); //Control of right motor in forward direction
  pinMode(motor2,OUTPUT); //Control of left motor in reverse direction
  pinMode(motor1rev,OUTPUT);
  pinMode(motor2rev,OUTPUT); 
  pinMode(CalButton, INPUT);
 
  safety = 0;
  kp=60;
  ki=0.3;
  kd=0;

//PID values reset
  proportional=0;
  integral=0;
  derivative=0;
  last_proportional=0;

  mode =1;
 //Serial begin and information for user
  Serial.begin(9600);
  Serial.println("Robot ready to go");

//reset all motor pinouts to LOW
  digitalWrite(motor1, HIGH);
  digitalWrite(motor2, HIGH);
  digitalWrite(motor1rev, HIGH);
  digitalWrite(motor2rev, HIGH);
  }

void loop() {
  if(digitalRead(CalButton)==HIGH){kalibruj();}

  if(Serial.available()>0){
  
      cmd=Serial.read();

      switch(cmd) {
        case '1':
        if(mode==1){goStraight();}
        break;

        case '2':
        if(mode==1){goBack();}
        break;

        case '3':
        if(mode==1){adjustLeft();}
        break;

        case '4':
        if(mode==1){adjustRight();}
        break;

        case '5':
        if(mode==1){stopMove();}
        break;

        case '6':
        kalibruj();
        break;

        case '7':
        mode = 2;
        break;

        case '8':
        mode = 1;
        break;

        case 'r' :
        RevRight();
        break;

        case 'l' :
        RevLeft();
        break;

        case 'P':
        kp= Serial.readStringUntil('?').toFloat();
        stopMove();
        Serial.print("Kp");
        Serial.println(kp);
        delay(1000);
        break;

        case 'I':
        ki= Serial.readStringUntil('?').toFloat();
        stopMove();
        Serial.print("Ki");
        Serial.println(ki);
        delay(1000);
        break;

        case 'D':
        kd= Serial.readStringUntil('?').toFloat();
        stopMove();
        Serial.print("Kd");
        Serial.println(kd);
        delay(1000);
        break;

        case 'R':
        PWMSpeed1 = Serial.readStringUntil('?').toFloat();
        Serial.print("RMOTOR: ");
        Serial.println(PWMSpeed1);
        break;

        case 'L':
        PWMSpeed2 = Serial.readStringUntil('?').toFloat();
        Serial.print("LMOTOR: ");
        Serial.println(PWMSpeed2);
        break;
        
        default:
        stopMove();
        break;
      }
  }
      
  if(mode==2){
  optoReader(); //Function reads analog inputs and performs PID
 //Open PID function

 pid_control();
 fitAction(); //Function fits motors action based on PID's error_value
  }
  

}

void optoReader(){
  
  //reset of sum and average values
  sensors_sum=0;
  sensors_average=0;
  //for loop that reads analog inputs and perform math on sum and average
 for (int i=0; i<7; i++){
  sensors[i]=analogRead(i);
  sensors_average += sensors[i]*(i+1)*1000;
  sensors_sum += int(sensors[i]); 
 }
 
}

void pid_control(){
  //Write position value
 position = int(sensors_average / sensors_sum);
 //Serial.print("Position: "); Serial.println(position);
 //delay(1000);
 //Set PID values

proportional = position - set_point;
integral = integral + proportional;
derivative=proportional-last_proportional;
last_proportional = proportional;
error_value = kp*proportional + ki*integral + kd*derivative;
//Serial.print("Error: ");Serial.println(error_value);
  
}


void fitAction (){
 if(error_value<-256){error_value=-256;}
 if(error_value>256){error_value=256;}
//if error_value is different than 0 then go to appriopiate function for motors
 if(error_value<0){adjustLeft();} 
 else if(error_value>0){adjustRight();}
 else {goStraight();}
  
}

void goStraight(){
  //Function that makes robot go straight
  //Serial.println("Straight");
  
  analogWrite(motor1, minSpeed-PWMSpeed1);
  analogWrite(motor2, minSpeed-PWMSpeed2);
  digitalWrite(motor1rev, HIGH);
  digitalWrite(motor2rev, HIGH);
 }

void adjustLeft(){
  //Function that adjust robot move when line is on the LEFT side of center.
   //Serial.println("Left");
  digitalWrite(motor1, HIGH);
  analogWrite(motor2, minSpeed-PWMSpeed2);
 digitalWrite(motor1rev, HIGH);
  digitalWrite(motor2rev, HIGH);
     
}

void adjustRight() {
 //Function that adjust robot move when line is on the RIGHT side of center. 
 //Serial.println("Right");

 analogWrite(motor1, minSpeed-PWMSpeed1);
  digitalWrite(motor2, HIGH);
digitalWrite(motor1rev, HIGH);
  digitalWrite(motor2rev, HIGH);
  
  
}

void stopMove(){
  digitalWrite(motor1, HIGH);
  digitalWrite(motor2, HIGH);
  digitalWrite(motor1rev, HIGH);
  digitalWrite(motor2rev, HIGH);
   //Stop everything
   //Serial.println("STOP! ERROR!"); 
  //safety = 1;
}

void goBack(){
digitalWrite(motor1, HIGH);
  digitalWrite(motor2, HIGH);
   digitalWrite(motor1rev, LOW);
  digitalWrite(motor2rev, LOW);
  
}

void RevRight(){
 analogWrite(motor1rev, 50);
  digitalWrite(motor2rev, HIGH);
digitalWrite(motor1, HIGH);
  digitalWrite(motor2, HIGH);
}

void RevLeft(){
digitalWrite(motor1rev, HIGH);
  digitalWrite(motor2rev, LOW);
 digitalWrite(motor1, HIGH);
  digitalWrite(motor2, HIGH);
}


void kalibruj(){
   digitalWrite(motor1, HIGH);
  digitalWrite(motor2, HIGH);
  digitalWrite(motor1rev, HIGH);
  digitalWrite(motor2rev, HIGH);
  Serial.println("Kalibracja...");
  delay(2000);
  
  
  
for(int i=0;i<50;i++){  
  optoReader();
  positionKal[i] = int(sensors_average / sensors_sum);
  }
for(int i=0;i<50;i++){
  for(int j=0;j<50;j++){
  if(positionKal[j+1]>positionKal[j]){
    temp = positionKal[j];
    positionKal[j]=positionKal[j+1];
    positionKal[j+1]=temp;
    }
  }
  }
  //PID values reset
  proportional=0;
  integral=0;
  derivative=0;
  last_proportional=0;
  set_point = positionKal[24]-500;
Serial.print("Pozycja 0: ");
  Serial.println(set_point);
  delay(2000);
  
}


