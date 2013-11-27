
void setup() {
  Serial.begin(9600);
  pinMode(2,OUTPUT);
  digitalWrite(2, LOW);
}

volatile unsigned int do_capture=0;
volatile unsigned int do_focus=0;

void loop() {
  int v0=0,v1=128;
  while(Serial.available()>0){
  //  v0=Serial.parseInt();
    switch(Serial.read()){
      case 'v': v1=Serial.parseInt(); break;
      case 't': 
      digitalWrite(2, HIGH);
      delay(1);
      digitalWrite(2, LOW); break;
      break;
      case 'c': do_capture = Serial.parseInt(); do_focus =0; break;
      case 'C': do_capture = 0; break;
      case 'f': do_focus = Serial.parseInt(); break;
    }
    
    
      
    if(Serial.read()=='\n'){
      Serial.print("got data:");
      analogWrite(DAC1,v1);
      Serial.println(v1,DEC);
      Serial.print("focus: ");
      Serial.println(do_focus,DEC);
    }
  }
  
  if (do_focus){
    delay(10);
    digitalWrite(2, HIGH);
    delay(1);
    digitalWrite(2, LOW);
  }
  
  if (do_capture){
    analogWrite(DAC1,do_capture);
    Serial.print("capture slice:");
    Serial.println(do_capture,DEC);
    do_capture--;
    delay(20);
    digitalWrite(2, HIGH);
    delay(1);
    digitalWrite(2, LOW);
  } 
}
