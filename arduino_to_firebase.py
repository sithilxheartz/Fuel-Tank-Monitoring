import serial
import re
import firebase_admin
from firebase_admin import credentials, db

# Firebase setup
cred = credentials.Certificate("real-time-database-65dc5-firebase-adminsdk-fbsvc-3b5af15508.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://real-time-database-65dc5-default-rtdb.asia-southeast1.firebasedatabase.app/'
})

# Connect to ESP32
arduino = serial.Serial('COM9', 115200)  # Update this if needed

# Regex to capture all three values
pattern = re.compile(
    r"Temperature:\s*([-+]?\d*\.\d+|\d+)\s*°C\s*\|\s*MQ-135 Voltage:\s*([-+]?\d*\.\d+|\d+)\s*V\s*\|\s*Raw:\s*(\d+)"
)

while True:
    line = arduino.readline().decode().strip()
    match = pattern.search(line)
    if match:
        temperature = float(match.group(1))
        mq_voltage = float(match.group(2))
        mq_raw = int(match.group(3))

        print(f"Temp: {temperature} °C | Voltage: {mq_voltage} V | Raw: {mq_raw}")

        db.reference('esp32/temperature').set(temperature)
        db.reference('esp32/mq135_voltage').set(mq_voltage)
        db.reference('esp32/mq135_raw').set(mq_raw)
    else:
        print(f"Ignored line: {line}")
