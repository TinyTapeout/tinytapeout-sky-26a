# Ultra Low Power Pedometer ASIC

## Description
656nW pedometer ASIC using SPI accelerometer input with Alpha-Max Beta-Min magnitude estimation, 8-tap moving average filter and gait regularity filter.

## How it works
Receives 48-bit SPI frames (16-bit X, Y, Z) from MEMS accelerometer (ADXL345). Computes magnitude using Alpha-Max Beta-Min algorithm. Detects steps using threshold crossing with hysteresis and gait regularity filter.

## How to test
Connect ADXL345 accelerometer via SPI. Read step count via uo_out using byte_sel pin.

## External hardware
ADXL345 or MPU6050 MEMS accelerometer
