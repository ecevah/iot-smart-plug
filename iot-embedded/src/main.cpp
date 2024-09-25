#include <WiFi.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include <ArduinoJson.h>
#include <EEPROM.h>
#include <Update.h>
#include <ModbusMaster.h>
#include <iostream>
#include <random>

const char* password = "123456789";

boolean wifiConnected = false;

const int ledPin = 4;
const int ledPin2 = 22;
const int ledPin3 = 23;

const int EEPROM_SIZE = 512;
const int SSID_ADDRESS = 0;
const int PASSWORD_ADDRESS = 32;

int iotDevice_Status;
int lineVoltage;
int current;
int freq;
int activePower;
int energyWatt;
int energyKW;
int temperatureMcu;
int enDisEventFlag = 0;
int enDisStatus;
int ResetDelayTimeButtonEventFlag = 0;
int ResetDelayTimeButtonStatus;

int errorStatus;
int isWaitDelayActive;
int mainsVoltageError;
int freqError;
int polarityError;
int earthError;
int temperatureError;
int relayError;

int enDisEventFlag_3 = 0;                      
int enDisStatus_3;
int staticWaitDelay;  
int staticWaitDelay_EvetFlag = 0;
int dynamicWaitDelay_3;
int ResetDelayTimeButtonEventFlag_3 = 0;
int ResetDelayTimeButtonStatus_3;
int mcuTick_;
int resetEventFlag = 0;                           
int resetStatus;
int iotDevice_SW_Version;

int lineVoltage_4;
int LineVoltage_calib;    
int LineVoltage_calib_EvetFlag = 0;
int current_4;
int LowCurrent_calib;     
int LowCurrent_calib_EvetFlag = 0;
int HighCurrent_calib;    
int HighCurrent_calib_EvetFlag = 0;
int LowCurrentZero_calib;    
int LowCurrentZero_calib_EvetFlag = 0;
int HighCurrentZero_calib;    
int HighCurrentZero_calib_EvetFlag = 0;
int freq_4;
int Freq_calib;           
int Freq_calib_EvetFlag = 0;
int loadVoltage_4;
int loadVoltage_calib;    
int loadVoltage_calib_EvetFlag = 0;
int earthVoltage_4;
int earthVoltage_calib;   
int earthVoltage_calib_EvetFlag = 0;
int temperatureMcu_4;
int temperatureMcu_calib; 
int temperatureMcu_calib_EvetFlag = 0;

String eeprom_ssid;
String eeprom_password;

bool scan_flag = false;
int numNetworks = 0;
uint32_t prev_millis = 0;
StaticJsonDocument<512> jsonDoc;
JsonArray networks = jsonDoc.to<JsonArray>();

AsyncWebServer server(80);
AsyncWebSocket ws("/ws");

int latestRandomValues[3] = {0, 0, 0}; 

void sendInitialMessage(AsyncWebSocketClient *client) {
  StaticJsonDocument<512> doc;
  doc["lineVoltage"] = 0;
  doc["current"] = 0;
  doc["freqBuffer"] = "0.0 Hz";
  doc["activePower"] = 0;
  doc["energyWatt"] = 0;
  doc["energyKW"] = 0;
  doc["temperature"] = 0;
  doc["staticWaitDelay"] = 0;
  doc["dynamicWaitDelay"] = 0;
  doc["mcuTick"] = 0;
  doc["iotDeviceSwVersion"] = 0;
  doc["endisStatus"] = 0;
  doc["endisStatusThree"] = 0;
  doc["resetDelayTimeButtonStatus"] = 0;
  doc["earthVoltage"] = 0;
  doc["loadVoltage"] = 0;
  doc["lineVoltageCalib"] = 0;
  doc["lowCurrentCalib"] = 0;
  doc["hightCurrentCalib"] = 0;
  doc["hightCurrentZeroCalib"] = 0;
  doc["freqCalib"] = "No Error";
  doc["loadVoltageCalib"] = 0;
  doc["earthVoltageCalib"] = 0;
  doc["tempeatureMcuCalib"] = 0;

  char buffer[512];
  size_t len = serializeJson(doc, buffer);
  client->text(buffer, len);
}


void onWebSocketEvent(AsyncWebSocket *server, AsyncWebSocketClient *client, AwsEventType type, void *arg, uint8_t *data, size_t len) {
  if (type == WS_EVT_CONNECT) {
    Serial.println("Client connected");
    sendInitialMessage(client);
  } else if (type == WS_EVT_DISCONNECT) {
    Serial.println("Client disconnected");
  }
}

void sendRandomValues() {
  
  for (int i = 0; i < 3; i++) {
    latestRandomValues[i] = random(0, 100);
  }
}

String readEEPROMString(int start, int maxLen) {
  String result;
  for (int i = start; i < start + maxLen; ++i) {
    char c = EEPROM.read(i);
    if (c == '\0') break; 
    result += c;
  }
  return result;
}

void clearEEPROM() {
  for (int i = 0; i < EEPROM_SIZE; i++) {
    EEPROM.write(i, 0);
  }
  EEPROM.commit();
}

void writeEEPROMString(int start, String data) {
  int i;
  for (i = 0; i < data.length(); i++) {
    EEPROM.write(start + i, data[i]);
  }
  EEPROM.write(start + i, '\0');
  EEPROM.commit();
}

void handleCheck(AsyncWebServerRequest *request) {
  uint8_t mac[6];
  esp_read_mac(mac, ESP_MAC_WIFI_STA);
  char macAddress[18];
  sprintf(macAddress, "%02x:%02x:%02x:%02x:%02x:%02x", mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
  String response = "{\"status\":\"true\" ,\"message\":\"iotDevice Connection\",\"macAddress\":\"" + String(macAddress) + "\"}";
  request->send(200, "application/json", response);
}

void handleScan(AsyncWebServerRequest *request) {
  String response;
  serializeJson(jsonDoc, response);

  request->send(200, "application/json", "{\"status\":\"true\",\"message\":\"Find Complated\", \"data\":" + response +"}" );
}

void handleDelete(AsyncWebServerRequest *request) {
  clearEEPROM();
  Serial.println("Saved network credentials deleted. Device now in AP+STA mode.");
  delay(1000);
  WiFi.disconnect(); 
  request->send(200, "application/json", "{\"status\":\"true\",\"message\":\"Network credentials deleted, device reset to AP+STA mode.\"}");
  delay(1000);
  ESP.restart();
}


ModbusMaster mbMaster;

void setup() 
{
  Serial.begin(115200);
  EEPROM.begin(512);
  mbMaster.begin(1,Serial);
  pinMode(ledPin, OUTPUT);
  pinMode(ledPin2, OUTPUT);


  uint8_t mac[6];
  esp_read_mac(mac, ESP_MAC_WIFI_STA);

  String macAddress = String(mac[0], HEX) + String(mac[1], HEX) +  String(mac[2], HEX) + String(mac[3], HEX) + String(mac[4], HEX) + String(mac[5], HEX);
  macAddress.toUpperCase();
  String ssid = "iotDevice-" + macAddress;

  eeprom_ssid = readEEPROMString(0, 32); 
  int passwordStart = eeprom_ssid.length() + 1; 
  eeprom_password = readEEPROMString(passwordStart, 64 - passwordStart); 
  
  Serial.println(eeprom_ssid + eeprom_password);

  if (!eeprom_ssid.isEmpty() && !eeprom_password.isEmpty()) {
    WiFi.mode(WIFI_AP_STA); 
    delay(1000);
    WiFi.begin(eeprom_ssid.c_str(), eeprom_password.c_str());
    delay(3000);
    Serial.println(WiFi.status());

    if (WiFi.status() == WL_CONNECTED) {
      Serial.println("WiFi connection successful!");
      Serial.println(WiFi.status());
      Serial.println(WiFi.localIP());
      WiFi.mode(WIFI_STA);
      wifiConnected = true;
    }
  } else if (!wifiConnected) {

      WiFi.softAP(ssid, "");
      Serial.println("WiFi network started in SoftAP mode.");
      Serial.println(WiFi.softAPIP());
      wifiConnected = true;
  }
  
  server.on("/", HTTP_GET, handleCheck);

  server.on("/scan", HTTP_GET, handleScan);

  server.on("/delete", HTTP_DELETE, handleDelete);

  server.on("/connect", HTTP_POST, [](AsyncWebServerRequest *request){}, NULL, [](AsyncWebServerRequest *request, uint8_t *data, size_t len, size_t index, size_t total) {
    DynamicJsonDocument doc(1024);
    deserializeJson(doc, data);
    const char* ssid = doc["ssid"];
    const char* password = doc["password"];

    uint8_t mac[6];
    esp_read_mac(mac, ESP_MAC_WIFI_STA);
    char macAddress[18];
    sprintf(macAddress, "%02x:%02x:%02x:%02x:%02x:%02x", mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);

    Serial.print("Connected SSID: ");
    Serial.println(ssid);
    Serial.print("Password: ");
    Serial.println(password);

    WiFi.begin(ssid, password);
    for(int i = 0; i < 20 && WiFi.status() != WL_CONNECTED; i++){
      Serial.print(".");
      delay(100);
    }
    Serial.print(WiFi.status() == WL_CONNECTED);
    if (WiFi.status() == WL_CONNECTED) {
      Serial.println("Connected!");
      Serial.print(WiFi.localIP().toString());
      clearEEPROM();
      writeEEPROMString(0, ssid);
      int passwordStart = strlen(ssid) + 1;
      writeEEPROMString(passwordStart, password);
      request->send(200, "application/json", "{\"status\": \"true\",\"message\": \"Connection Successful.\",\"ip\": \"" + WiFi.localIP().toString() + "\",\"macAddress\": \"" + String(macAddress) + "\"}");
      delay(1000);
      WiFi.mode(WIFI_MODE_STA);

    } else {
      request->send(500, "application/json", "{\"status\":\"false\",\"error\":\"Connection failed.\"}");
      WiFi.disconnect();
    }
  });

  server.on("/toggle/led", HTTP_GET, [](AsyncWebServerRequest *request) {
    if (request->hasParam("pin") && request->hasParam("state")) {
      String pinStr = request->getParam("pin")->value();
      String stateStr = request->getParam("state")->value();

      int pin = pinStr.toInt();
      bool state = stateStr == "true" ? true : false;

      switch (pin)
      {
        case 1:
          digitalWrite(ledPin, state ? HIGH : LOW);
          break;
        case 2:
          digitalWrite(ledPin2, state ? HIGH : LOW);
          break;
        case 3:
          digitalWrite(ledPin3, state ? HIGH : LOW);
          break;
      }
    }

    request->send(200, "application/json", "{\"status\":\"true\",\"message\":\"Toggle Led\"}");
  });

  server.on("/update", HTTP_POST, [](AsyncWebServerRequest *request) {

    if ( Update.hasError() ) {
      request->send(500, "text/plain", "{\"status\":\"false\",\"message\":\"Update Failed!\"}");
    }
    else {
      request->send(200, "text/plain", "{\"status\":\"true\",\"message\":\"Update Successful! Restarting...\"}");
    }
    
    delay(1000);
    ESP.restart();
  }, [](AsyncWebServerRequest *request, String filename, size_t index, uint8_t *data, size_t len, bool final) {
    
    if (!index){
      Serial.printf("Starting Update: %s\n", filename.c_str());
      if (!Update.begin(UPDATE_SIZE_UNKNOWN)) { 
        Update.printError(Serial);
      }
    }
    
    if (!Update.write(data, len)) {
      Update.printError(Serial);
    }
    if (final) {
      if (Update.end(true)) { 
        Serial.printf("Update Completed: %uB\n", index + len);
      } else {
        Update.printError(Serial);
      }
    }
  });

  ws.onEvent(onWebSocketEvent);
  server.addHandler(&ws);
  server.begin();
}


int G_modbus_single_register_read(uint16_t Reg_Add)
{
  int time_out_cnt;
  static int isSuccessful = mbMaster.ku8MBIllegalDataAddress;
  int return_value;

  time_out_cnt=0;
  isSuccessful = mbMaster.ku8MBIllegalDataAddress;

  while((isSuccessful != mbMaster.ku8MBSuccess))
  {
    isSuccessful = mbMaster.readHoldingRegisters(Reg_Add, 1);
    delay(3);
    time_out_cnt++;
    if(time_out_cnt>10)
    {
      break;
    }
  }

  return_value = mbMaster.getResponseBuffer(0);
  mbMaster.clearResponseBuffer();

  return return_value;
}

void G_modbus_single_register_write(uint16_t Reg_Add, uint16_t write_data )
{
  int time_out_cnt;
  static int isSuccessful = mbMaster.ku8MBIllegalDataAddress;


  isSuccessful = mbMaster.ku8MBIllegalDataAddress;
  mbMaster.clearTransmitBuffer();
  while((isSuccessful != mbMaster.ku8MBSuccess))
  {
    isSuccessful = mbMaster.writeSingleRegister(Reg_Add, write_data); 
    delay(3);
  }
  mbMaster.clearTransmitBuffer();

}


void loop() 
{
  if(!WiFi.isConnected() &&  scan_flag == false){
    if(millis() - prev_millis >10000 || prev_millis == 0){
      prev_millis = millis();
      Serial.println("Scanning Wi-Fi networks...");
      numNetworks = WiFi.scanNetworks();

      while(WiFi.scanComplete() == WIFI_SCAN_RUNNING) {
        delay(100);
      }

      if (WiFi.scanComplete() ==  WIFI_SCAN_FAILED) {
        Serial.println("Wifi scan is not completed");
      }

      networks.clear();

      for (int i = 0; i < numNetworks; i++) {
        Serial.println(WiFi.SSID(i));
        JsonObject network = networks.createNestedObject();
        network["ssid"] = WiFi.SSID(i);
        network["rssi"] = WiFi.RSSI(i);
      }

      WiFi.scanDelete();
    }
    if (!eeprom_ssid.isEmpty() && !eeprom_password.isEmpty()) {

      Serial.println(eeprom_password);
      Serial.println(eeprom_ssid);
      WiFi.begin(eeprom_ssid.c_str(), eeprom_password.c_str());
      delay(3000);
      Serial.println(WiFi.status());
      Serial.println(WiFi.localIP());
      WiFi.mode(WIFI_STA);
      if(!WiFi.isConnected()){
        WiFi.disconnect();
      }
    }
  }
   mbMaster.clearResponseBuffer();
   mbMaster.clearTransmitBuffer();
   static int isSuccessful = mbMaster.ku8MBIllegalDataAddress;  
   isSuccessful = mbMaster.ku8MBIllegalDataAddress;

  lineVoltage=G_modbus_single_register_read(40001);
  current=G_modbus_single_register_read(40002);


  freq=G_modbus_single_register_read(40003);
  int freq_dot = freq % 10;
  char freq_buffer[8];
  freq = freq/10;
  sprintf(freq_buffer,"%d.%d Hz",freq,freq_dot);
  
  activePower=G_modbus_single_register_read(40004);
  
  energyWatt=G_modbus_single_register_read(40005);

  energyKW=G_modbus_single_register_read(40006);  
  
  temperatureMcu=G_modbus_single_register_read(40014); 
  
  int temp_Wait_time;
  temp_Wait_time=G_modbus_single_register_read(40022); 
  if(temp_Wait_time !=staticWaitDelay)
  {
    if(staticWaitDelay_EvetFlag ==1)
    {
      G_modbus_single_register_write(22,staticWaitDelay);
    }
    else  
    {
      staticWaitDelay=temp_Wait_time;
    }
  }

  dynamicWaitDelay_3=G_modbus_single_register_read(23); 

  mcuTick_=G_modbus_single_register_read(40100); 
  
  iotDevice_SW_Version=G_modbus_single_register_read(40098); 

  iotDevice_Status=G_modbus_single_register_read(40024);
  int relayStatus;
  int buttonStatus;
  int errorStatus_f;
  int temp;
  int error_recovery;
  String errorStatusResponse;
  String iotDeviceStatus;
  String waitDelayActive;


  relayStatus = (iotDevice_Status % 2);
  buttonStatus = ((iotDevice_Status>>1) % 2); 
  errorStatus_f = ((iotDevice_Status>>2) % 2);
  isWaitDelayActive = ((iotDevice_Status>>3) % 2);
  error_recovery = ((iotDevice_Status>>4) % 2);
  if(errorStatus_f == 1)
  {
    if(error_recovery==1)
    {
      errorStatusResponse = "Wait Error Recovery Time";
      iotDeviceStatus = "Wait Error Recovery Time";
    }
    else
    {
      errorStatusResponse = "Error Available";
      iotDeviceStatus = "Error Available";
    }

  }
  else
  {
    errorStatusResponse = "No Error";

    if(isWaitDelayActive == 1)
    {
      iotDeviceStatus = "Wait Delay Time";
    }
    else
    {
      if(relayStatus == 1 )
      {
        iotDeviceStatus = "On Load";
      }
    }
  }

  
  if(isWaitDelayActive == 1)
  {
    waitDelayActive ="Delay Time not Elapsed";
  }
  else
  {
    waitDelayActive ="Delay Time Elapsed";
  }

  
  
  errorStatus=G_modbus_single_register_read(40025);
  String voltageErrorResponse;
  mainsVoltageError = (errorStatus % 2);
  if(mainsVoltageError == 1)
  {
    voltageErrorResponse = "Error!!";
  }
  else
  {
    voltageErrorResponse = "No Error";
  }

  freqError = ((errorStatus>>1) % 2);
  String fleqErrorResponse;
  if(freqError == 1)
  {
    fleqErrorResponse = "Error!!";
  }
  else
  {
    fleqErrorResponse = "No Error";
  }


  polarityError = ((errorStatus>>2) % 2);
  String polarityErrorResponse;
  if(polarityError == 1)
  {
    polarityErrorResponse = "Error!!";
  }
  else{
    polarityErrorResponse = "No Error";
  }

  earthError = ((errorStatus>>3) % 2);
  String earthErrorResponse;
  if(earthError == 1)
  {
    earthErrorResponse = "Error!!";
  }
  else{
      earthErrorResponse = "No Error";
  }

  temperatureError = ((errorStatus>>4) % 2);
  String temperatureErrorResponse;
  if(temperatureError == 1)
  {
    temperatureErrorResponse = "Error!!";
  }
  else
  {
    temperatureErrorResponse = "No Error";
  }

  relayError = ((errorStatus>>5) % 2);
  String relayErrorResponse;
  if(relayError == 1)
  {
    relayErrorResponse = "Error!!";
  }
  else
  {
    relayErrorResponse = "No Error";
  }


int ESP_Permissions;
ESP_Permissions= G_modbus_single_register_read(40026);
String endisButtonResponse;
String endisButton_3;
  int iotDeviceEnabled;
  iotDeviceEnabled = (ESP_Permissions % 2);

  if(iotDeviceEnabled != enDisStatus)
  {
    if((enDisEventFlag == 0)||(enDisEventFlag_3 == 0))
    {
      enDisStatus=iotDeviceEnabled;
      enDisStatus_3=iotDeviceEnabled;

      endisButtonResponse = iotDeviceEnabled;
      endisButton_3 = iotDeviceEnabled;
    }
  }


  if((enDisEventFlag == 1)||(enDisEventFlag_3 == 1))
  {
    if(enDisEventFlag == 1)
    {
      enDisStatus_3 = enDisStatus;
    }
    else
    {
      enDisStatus = enDisStatus_3;
    }

    enDisEventFlag = 0;
    enDisEventFlag_3 = 0;

    if(enDisStatus == 1)
    { 
      G_modbus_single_register_write(40034,0);

    }
    else
    {
      
      G_modbus_single_register_write(40034,1);
    }

    G_modbus_single_register_write(40026,enDisStatus);

  }


  if((ResetDelayTimeButtonEventFlag == 1 ) || (ResetDelayTimeButtonEventFlag_3 == 1 ))
  {
    if(ResetDelayTimeButtonEventFlag == 1 )
    {
      ResetDelayTimeButtonStatus_3=ResetDelayTimeButtonStatus;
    }
    else
    {
      ResetDelayTimeButtonStatus=ResetDelayTimeButtonStatus_3;
    }

    ResetDelayTimeButtonEventFlag =0;
    ResetDelayTimeButtonEventFlag_3=0;

    if(ResetDelayTimeButtonStatus ==1)
    {
      if(dynamicWaitDelay_3>0)
      {
        dynamicWaitDelay_3 =0;
        G_modbus_single_register_write(40023,dynamicWaitDelay_3);

      }
      
    }

  }

  if(dynamicWaitDelay_3 > 0)
  {
    if(ResetDelayTimeButtonStatus == 1)
    {
      ResetDelayTimeButtonStatus=0;
      ResetDelayTimeButtonStatus_3=0;
    }
  }
  else
  {
    if(ResetDelayTimeButtonStatus == 0 )
    {
      ResetDelayTimeButtonStatus=1;
      ResetDelayTimeButtonStatus_3=1;
    }
  }

  earthVoltage_4=G_modbus_single_register_read(40012); 
  
  loadVoltage_4=G_modbus_single_register_read(40013); 
  

  int temp_LineVoltage_calib;
  temp_LineVoltage_calib=G_modbus_single_register_read(40027); 

  if(temp_LineVoltage_calib !=LineVoltage_calib)
  {
    if(LineVoltage_calib_EvetFlag ==1)
    {
      G_modbus_single_register_write(40027,LineVoltage_calib);
    }
    else  
    {
      LineVoltage_calib=temp_LineVoltage_calib;
    }
  }

  
  int temp_LowCurrent_calib;
  temp_LowCurrent_calib=G_modbus_single_register_read(40028); 

  if(temp_LowCurrent_calib !=LowCurrent_calib)
  {
    if(LowCurrent_calib_EvetFlag ==1)
    {
      G_modbus_single_register_write(40028,LowCurrent_calib);
    }
    else  
    {
      LowCurrent_calib=temp_LowCurrent_calib;
    }
  }

    

  int temp_HighCurrent_calib;
  temp_HighCurrent_calib=G_modbus_single_register_read(40033); 

  if(temp_HighCurrent_calib !=HighCurrent_calib)
  {
    if(HighCurrent_calib_EvetFlag ==1)
    {
      G_modbus_single_register_write(40033,HighCurrent_calib);
    }
    else  
    {
      HighCurrent_calib=temp_HighCurrent_calib;
    }
  }

  
  int temp_LowCurrentZero_calib;
  temp_LowCurrentZero_calib=G_modbus_single_register_read(40036); 

  if(temp_LowCurrentZero_calib !=LowCurrentZero_calib)
  {
    if(LowCurrentZero_calib_EvetFlag ==1)
    {
      G_modbus_single_register_write(40036,LowCurrentZero_calib);
    }
    else  
    {
      LowCurrentZero_calib=temp_LowCurrentZero_calib;
    }
  }

  

  int temp_HighCurrentZero_calib;
  temp_HighCurrentZero_calib=G_modbus_single_register_read(40037); 

  if(temp_HighCurrentZero_calib !=HighCurrentZero_calib)
  {
    if(HighCurrentZero_calib_EvetFlag ==1)
    {
      G_modbus_single_register_write(40037,HighCurrentZero_calib);
    }
    else  
    {
      HighCurrentZero_calib=temp_HighCurrentZero_calib;
    }
  }


    

  int temp_Freq_calib;
  temp_Freq_calib=G_modbus_single_register_read(40029); 

  if(temp_Freq_calib !=Freq_calib)
  {
    if(Freq_calib_EvetFlag ==1)
    {
      G_modbus_single_register_write(40029,Freq_calib);
    }
    else  
    {
      Freq_calib=temp_Freq_calib;
    }
  }

    

  int temp_loadVoltage_calib;
  temp_loadVoltage_calib=G_modbus_single_register_read(40030); 

  if(temp_loadVoltage_calib !=loadVoltage_calib)
  {
    if(loadVoltage_calib_EvetFlag ==1)
    {
      G_modbus_single_register_write(40030,loadVoltage_calib);
    }
    else  
    {
      loadVoltage_calib=temp_loadVoltage_calib;
    }
  }

    

  int temp_earthVoltage_calib;
  temp_earthVoltage_calib=G_modbus_single_register_read(40031); 

  if(temp_earthVoltage_calib !=earthVoltage_calib)
  {
    if(earthVoltage_calib_EvetFlag ==1)
    {
      G_modbus_single_register_write(40031,earthVoltage_calib);
    }
    else  
    {
      earthVoltage_calib=temp_earthVoltage_calib;
    }
  }

    

  int temp_temperatureMcu_calib;
  temp_temperatureMcu_calib= G_modbus_single_register_read(40032); 

  if(temp_temperatureMcu_calib !=temperatureMcu_calib)
  {
    if(temperatureMcu_calib_EvetFlag ==1)
    {
      G_modbus_single_register_write(40032,temperatureMcu_calib);
    }
    else  
    {
      temperatureMcu_calib=temp_temperatureMcu_calib;
    }
  }

  Serial.println("{\"lineVoltage\": " + String(lineVoltage/100) + ",\"current\": " +  String(current*10) + ",\"freqBuffer\": " + String(  freq_buffer)+ ",\"activePower\":" + String(activePower/10)+ ",\"energyWatt\": " + String( energyWatt)+ ",\"energyKw\": " + String( energyKW)+ ",\"temperature\": " + String( temperatureMcu)+ ",\"staticWaitDelay\": " + String( staticWaitDelay)+ ",\"dynamicWaitDelay\": " + String( dynamicWaitDelay_3)+ ",\"mcuTick\": " + String( mcuTick_)+ ",\"iotDeviceSwVersion\": " + String( iotDevice_SW_Version)+ ",\"endisStatus\": " + String( enDisStatus)+ ",\"endisStatusThree\": " + String( endisButton_3)+ ",\"resetDelayTimeButtonStatus\": " + String( ResetDelayTimeButtonStatus)+ ",\"earthVoltage\": " + String( earthVoltage_4/100)+ ",\"loadVoltage\": " + String( loadVoltage_4/100)+ ",\"lineVoltageCalib\": " + String( LineVoltage_calib)+ ",\"lowCurrentCalib\": " + String( LowCurrent_calib)+ ",\"hightCurrentCalib\": " + String( HighCurrent_calib)+ ",\"hightCurrentZeroCalib\": " + String( HighCurrent_calib_EvetFlag)+ ",\"freqCalib\": " + String( fleqErrorResponse)+ ",\"loadVoltageCalib\": " + String( loadVoltage_calib)+ ",\"earthVoltageCalib\": " + String( earthVoltage_calib)+ ",\"tempeatureMcuCalib\": " + String( temp_earthVoltage_calib) + "}");


  ws.textAll("{\"lineVoltage\": \" " + String(lineVoltage/100) + " \",\"current\": \" " +  String(current*10) + " \",\"freqBuffer\": \" " + String(  freq_buffer)+ " \",\"activePower\": \"" + String(activePower/10)+ " \",\"energyWatt\": \" " + String( energyWatt)+ " \",\"energyKw\": \" " + String( energyKW)+ " \",\"temperature\": \" " + String( temperatureMcu)+ " \",\"staticWaitDelay\": \" " + String( staticWaitDelay)+ " \",\"dynamicWaitDelay\": \" " + String( dynamicWaitDelay_3)+ " \",\"mcuTick\": \" " + String( mcuTick_)+ " \",\"iotDeviceSwVersion\": \" " + String( iotDevice_SW_Version)+ " \",\"endisStatus\": \" " + String( enDisStatus)+ " \",\"endisStatusThree\": \" " + String( endisButton_3)+ " \",\"resetDelayTimeButtonStatus\": \" " + String( ResetDelayTimeButtonStatus)+ " \",\"earthVoltage\": \" " + String( earthVoltage_4/100)+ " \",\"loadVoltage\": \" " + String( loadVoltage_4/100)+ " \",\"lineVoltageCalib\": \" " + String( LineVoltage_calib)+ " \",\"lowCurrentCalib\": \" " + String( LowCurrent_calib)+ " \",\"hightCurrentCalib\": \" " + String( HighCurrent_calib)+ " \",\"hightCurrentZeroCalib\": \" " + String( HighCurrent_calib_EvetFlag)+ " \",\"freqCalib\": \" " + String( fleqErrorResponse)+ " \",\"loadVoltageCalib\": \" " + String( loadVoltage_calib)+ " \",\"earthVoltageCalib\": \" " + String( earthVoltage_calib)+ " \",\"tempeatureMcuCalib\": \" " + String( temp_earthVoltage_calib) + "\"}"); 
}