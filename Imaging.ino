#define DIRECTION_CCW 0
#define DIRECTION_CW 1
#define POSITION 3
#define DIRECTION 4
#define STEP_RESOLUTION 1
#define TOTAL_STEPS 400 // 360 degrees / (0.9 degrees / step)
#define NUM_SENSOR_READINGS 10

long sensor, analog, pwm, av;
char input;

void setup() 
{
  Serial.begin(9600);
  
  // Setup step and direction pins
  pinMode(POSITION,OUTPUT); 
  pinMode(DIRECTION,OUTPUT);
  
  // Sensor PWM input
  pinMode(6, INPUT); 

  // Delay at startup
  delay(5000);
}

void loop() 
{
   // Check for Bluetooth data on USART bus
   if(Serial.available() > 0)
   {
      input = Serial.read();
      switch (input)
      {
        case 'S':
          fullScan();
          break;
      }
   }
}

void fullScan()
{
  // Read 360 degrees of enviorment
  digitalWrite(DIRECTION, DIRECTION_CCW);
  for(int y = 1; y <= TOTAL_STEPS; y+=STEP_RESOLUTION)
  {
    turnMotor(1);
    readSensor();
  }

  // Rotate back to original location
  delay(1000);
  digitalWrite(DIRECTION, DIRECTION_CW);
  turnMotor(TOTAL_STEPS);
  delay(1000);
}

void readSensor()
{
  av = 0; // average distance in mm
  
  // Take readings from both analog and PWM interface
  for(int i = 0; i < NUM_SENSOR_READINGS; i++)
  {
    analog = analogRead(0)*5; // 10 bit ADC conversion
    pwm = pulseIn(6, HIGH)/10;
    av += (pwm);
    delay(10);
  }  

  // Average results and print result
  av = av/NUM_SENSOR_READINGS;
  int sendVal;
  if(av < 500)
  {
    sendVal = int(av);
    Serial.println(sendVal);
  }
}

void turnMotor(int steps)
{
    for(int x = 0; x < steps; x++) 
    {
      digitalWrite(POSITION,HIGH); 
      delayMicroseconds(500); 
      digitalWrite(POSITION,LOW); 
      delayMicroseconds(500); 
      delay(10);
    }  
}
