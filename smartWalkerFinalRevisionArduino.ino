
#include <Arduino.h>


#if defined(ESP32) || defined(ARDUINO_RASPBERRY_PI_PICO_W)
#include <WiFi.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#elif __has_include(<WiFiNINA.h>)
#include <WiFiNINA.h>
#elif __has_include(<WiFi101.h>)
#include <WiFi101.h>
#elif __has_include(<WiFiS3.h>)
#include <WiFiS3.h>
#endif

#include <Firebase_ESP_Client.h>
#include <WiFi.h>
#include <WiFiNINA.h>
// Provide the token generation process info.
#include <addons/TokenHelper.h>

/* 1. Define the WiFi credentials */
#define WIFI_SSID "iPhone (23)" //1224 Spring #5
#define WIFI_PASSWORD "smartWalkerHotspot" //doesnotexist

/* 2. Define the API Key */
#define API_KEY "AIzaSyCbNeHuC-QVVm3mW1Lsi4B9YUkXkz6wXJE"

/* 3. Define the project ID */
#define FIREBASE_PROJECT_ID "smartwalker-753cd"

/* 4. Define the user Email and password that alreadey registerd or added in your project */
#define USER_EMAIL "nikhil.chandra2021@gmail.com"
#define USER_PASSWORD "smartWalkerTeam"

// Define Firebase Data object
FirebaseData fbdo;

FirebaseAuth auth;
FirebaseConfig config;

bool taskCompleted = false;

#if defined(ARDUINO_RASPBERRY_PI_PICO_W)
WiFiMulti multi;
#endif


#include <HX711_ADC.h>
#if defined(ESP8266)|| defined(ESP32) || defined(AVR)
#include <EEPROM.h>
#endif

//pins:
const int HX711_dout = 4; //mcu > HX711 dout pin
const int HX711_sck = 5; //mcu > HX711 sck pin
const int inputPin = 3; //hall effect sensor digital read pin

unsigned long time1 = millis();
float circumference = 0.39628;
float numberOfMagnets = 5.0;
float distanceBetweenMagnets = 0.0; //calculated in setup
float calibrationValue = -286.72; //run calibration to retrieve
float pressureValue = 0.0;
float speed = 0.0;
float totalDistanceTraveled = 0.0;
float speedMaxThreshold = 10; 
unsigned long lastMagnetTime = millis();
bool justSensed = false;

//HX711 constructor:
HX711_ADC LoadCell(HX711_dout, HX711_sck);

const int calVal_eepromAdress = 0;
unsigned long t = 0;


void setup()
{

    Serial.begin(115200);

#if defined(ARDUINO_RASPBERRY_PI_PICO_W)
    multi.addAP(WIFI_SSID, WIFI_PASSWORD);
    multi.run();
#else
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
#endif

    Serial.print("Connecting to Wi-Fi");
    unsigned long ms = millis();
    while (WiFi.status() != WL_CONNECTED)
    {
        Serial.print(".");
        delay(300);
#if defined(ARDUINO_RASPBERRY_PI_PICO_W)
        if (millis() - ms > 10000)
            break;
#endif
    }
    Serial.println();
    Serial.print("Connected with IP: ");
    Serial.println(WiFi.localIP());
    Serial.println();

    Serial.print("Firebase Client v%s\n\n");
    Serial.print(FIREBASE_CLIENT_VERSION);

    /* Assign the api key (required) */
    config.api_key = API_KEY;

    /* Assign the user sign in credentials */
    auth.user.email = USER_EMAIL;
    auth.user.password = USER_PASSWORD;

    // The WiFi credentials are required for Pico W
    // due to it does not have reconnect feature.
#if defined(ARDUINO_RASPBERRY_PI_PICO_W)
    config.wifi.clearAP();
    config.wifi.addAP(WIFI_SSID, WIFI_PASSWORD);
#endif

    /* Assign the callback function for the long running token generation task */
    config.token_status_callback = tokenStatusCallback; // see addons/TokenHelper.h

    // Comment or pass false value when WiFi reconnection will control by your code or third party library e.g. WiFiManager
    Firebase.reconnectNetwork(true);

    // Since v4.4.x, BearSSL engine was used, the SSL buffer need to be set.
    // Large data transmission may require larger RX buffer, otherwise connection issue or data read time out can be occurred.
    fbdo.setBSSLBufferSize(4096 /* Rx buffer size in bytes from 512 - 16384 */, 1024 /* Tx buffer size in bytes from 512 - 16384 */);

    // Limit the size of response payload to be collected in FirebaseData
    fbdo.setResponseSize(2048);

    Firebase.begin(&config, &auth);

    // You can use TCP KeepAlive in FirebaseData object and tracking the server connection status, please read this for detail.
    // https://github.com/mobizt/Firebase-ESP-Client#about-firebasedata-object
    // fbdo.keepAlive(5, 5, 1);

  Serial.println();
  Serial.println("Starting...");
  
  pinMode(inputPin, INPUT);

  distanceBetweenMagnets = (circumference/numberOfMagnets);
  
  LoadCell.begin();
  //LoadCell.setReverseOutput(); //uncomment to turn a negative output value to positive
  unsigned long stabilizingtime = 2000; // preciscion right after power-up can be improved by adding a few seconds of stabilizing time
  boolean _tare = true; //set this to false if you don't want tare to be performed in the next step
  LoadCell.start(stabilizingtime, _tare);
  if (LoadCell.getTareTimeoutFlag() || LoadCell.getSignalTimeoutFlag()) {
    Serial.println("Timeout, check MCU>HX711 wiring and pin designations");
    while (1);
  }
  else {
    LoadCell.setCalFactor(calibrationValue); // user set calibration value (float), initial value 1.0 may be used for this sketch
    Serial.println("Startup is complete");
  }
  while (!LoadCell.update());
  //calibrate(); //start calibration procedure
  lastMagnetTime = millis();

}

void loop() {


    //speed and distance
  
  int magnetPresence = digitalRead(inputPin);
  if (magnetPresence == HIGH) {
    justSensed = false;
  }
  if (!justSensed) {
      if (magnetPresence == LOW) { //magnet just passed by
      Serial.println("Magnet Sensed.");

      unsigned long timeDiff = ((millis() - lastMagnetTime)/500.0);

      if ((distanceBetweenMagnets/timeDiff) < speedMaxThreshold) { //not a fluke
        speed = (distanceBetweenMagnets/timeDiff);
        lastMagnetTime = millis();
        totalDistanceTraveled = (totalDistanceTraveled + distanceBetweenMagnets);
        Serial.print("Speed: ");
        Serial.println(speed);
        Serial.print("Distance: ");
        Serial.println(totalDistanceTraveled);
        justSensed = true;
      }

      
    }
  }
  
  //if (totalDistanceTraveled > 200000.0) { //resets the number if it gets too high
    //totalDistanceTraveled = 0.0;
  //}


  //pressure
  
  static boolean newDataReady = 0;
  // check for new data/start next conversion:
  if (LoadCell.update()) newDataReady = true;
  if (newDataReady) {
   
      pressureValue = LoadCell.getData();
      Serial.print("Load_cell output val: ");
      Serial.println(pressureValue);
      newDataReady = 0;
 
  }

    
    if ((millis() - time1) > 1000.0) {
      Serial.println("Beginning append to firebase");
      if (Firebase.ready() && !taskCompleted)
    {
        taskCompleted = true;

        // For the usage of FirebaseJson, see examples/FirebaseJson/BasicUsage/Create_Edit_Parse/Create_Edit_Parse.ino
        FirebaseJson content;

        // aa is the collection id, bb is the document id in collection aa.
        String documentPath = "smartWalker/realTimeData";

        // If the document path contains space e.g. "a b c/d e f"
        // It should encode the space as %20 then the path will be "a%20b%20c/d%20e%20f"

        content.set("fields/speed/doubleValue", String(speed,6));
        content.set("fields/distance/doubleValue", String(totalDistanceTraveled,6));
        content.set("fields/pressure/doubleValue", String(pressureValue, 6));
        Serial.print("Delete a document... ");

        if (Firebase.Firestore.deleteDocument(&fbdo, FIREBASE_PROJECT_ID, "" /* databaseId can be (default) or empty */, documentPath.c_str())) {
            Serial.print("ok\n%s\n\n");
            Serial.print(fbdo.payload().c_str());
        } 
        else {
          Serial.println(fbdo.errorReason());
        }
        

        Serial.print("Create a document... ");

        if (Firebase.Firestore.createDocument(&fbdo, FIREBASE_PROJECT_ID, "" /* databaseId can be (default) or empty */, documentPath.c_str(), content.raw())) {
          Serial.print("ok\n%s\n\n");
          Serial.print(fbdo.payload().c_str());
        }
            
        else {
            Serial.println(fbdo.errorReason());
        }
        taskCompleted = false;

    }
      
      time1 = millis();

    }

    //send all data
    // Firebase.ready() should be called repeatedly to handle authentication tasks.

    

    delay(100);
}
