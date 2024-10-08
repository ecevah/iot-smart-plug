# IoT Smart Plug Project - ESP32 & STM32

<img src="./images/cards.jpg" alt="Smart Plug ESP32 and STM32" width="300"/>

## Overview

This **IoT Smart Plug** project integrates an **ESP32** and **STM32** microcontroller to create a smart plug controlled through a **Flutter** mobile application. The ESP32 connects to the local network via the mobile app and communicates with the STM32 through UART. Real-time data, such as amperage, voltage, and temperature, is read from the STM32 and transmitted to the mobile app over WebSocket. The ESP32 also supports **Over-The-Air (OTA)** updates, allowing for remote firmware upgrades directly from the mobile app.

## Key Features

- **Local Network Connection**: The ESP32 connects to the local Wi-Fi network using a Flutter mobile app.
  
- **WebSocket Data Transfer**: Real-time data is sent from the ESP32 to the mobile app via WebSocket, ensuring instant updates of parameters like amperage, voltage, and temperature.

- **Command Transfer**: Commands from the mobile app are sent to the ESP32 over WebSocket, which then relays the commands to the STM32 for device control via UART.

- **OTA Updates**: The ESP32 can be updated remotely through the mobile app using Over-The-Air (OTA) functionality.

## Workflow

1. **Network Setup**: The ESP32 is connected to the local Wi-Fi network using a Flutter mobile app interface.

2. **Real-time Data Transfer**: The STM32 reads data from the smart plug (amperage, voltage, temperature) and sends it via UART to the ESP32, which forwards the data to the mobile app using WebSocket.

3. **Command Execution**: Users can send commands from the mobile app to control the plug through WebSocket, which are passed from ESP32 to STM32 via UART.

4. **Firmware Update**: The ESP32's firmware can be updated via OTA through the mobile app.

---

## Contact

For more information or collaboration inquiries, feel free to get in touch!

---

Thank you for exploring the **IoT Smart Plug Project**!

---
---
---

# IoT Akıllı Priz Projesi - ESP32 & STM32

<img src="./images/cards.jpg" alt="Akıllı Priz ESP32 ve STM32" width="300"/>

## Genel Bakış

Bu **IoT Akıllı Priz** projesi, **ESP32** ve **STM32** mikrodenetleyicilerini kullanarak oluşturulmuştur ve bir **Flutter** mobil uygulaması üzerinden kontrol edilmektedir. ESP32, mobil uygulama aracılığıyla yerel ağa bağlanır ve STM32 ile UART üzerinden haberleşir. STM32'den amperaj, voltaj ve sıcaklık gibi gerçek zamanlı veriler okunarak WebSocket aracılığıyla mobil uygulamaya iletilir. Ayrıca, ESP32'nin **Over-The-Air (OTA)** özelliği sayesinde mobil uygulama üzerinden uzaktan yazılım güncellemesi yapılabilir.

## Temel Özellikler

- **Yerel Ağ Bağlantısı**: ESP32, Flutter mobil uygulaması kullanılarak yerel Wi-Fi ağına bağlanır.
  
- **WebSocket Veri Transferi**: ESP32'den mobil uygulamaya gerçek zamanlı veriler WebSocket üzerinden aktarılır. Bu sayede amperaj, voltaj ve sıcaklık gibi parametreler anlık olarak takip edilebilir.

- **Komut Aktarımı**: Mobil uygulamadan gelen komutlar WebSocket aracılığıyla ESP32'ye gönderilir ve UART üzerinden STM32'ye iletilerek cihaz kontrolü sağlanır.

- **OTA Güncellemeleri**: ESP32, mobil uygulama üzerinden uzaktan OTA güncellemesi yapılarak güncellenebilir.

## İş Akışı

1. **Ağ Kurulumu**: ESP32, Flutter mobil uygulaması arayüzü kullanılarak yerel Wi-Fi ağına bağlanır.

2. **Gerçek Zamanlı Veri Transferi**: STM32, akıllı prizden (amperaj, voltaj, sıcaklık) aldığı verileri UART üzerinden ESP32'ye gönderir ve ESP32 bu verileri WebSocket ile mobil uygulamaya iletir.

3. **Komut İletimi**: Kullanıcılar mobil uygulamadan gönderilen komutlarla prizi kontrol eder. Bu komutlar WebSocket ile ESP32'ye, ardından UART ile STM32'ye iletilir.

4. **Yazılım Güncellemesi**: ESP32'nin yazılımı mobil uygulama üzerinden OTA ile güncellenebilir.

---


## İletişim

Daha fazla bilgi veya işbirliği için bizimle iletişime geçebilirsiniz!

---

**IoT Akıllı Priz Projesi'ni** incelediğiniz için teşekkürler!
