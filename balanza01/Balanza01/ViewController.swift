//
//  ViewController.swift
//  Balanza01
//
//  Created by Alvar Arias on 21/01/18.
//  Copyright © 2018 Alvar Arias. All rights reserved.
//

import UIKit
import CoreBluetooth

let WeightServiceCBUUID = CBUUID(string: "0x181B")
let Body_Composition_Feature_CharacteristicCBUUID = CBUUID(string: "2A9B")
let Body_Composition_Measurement_CharacteristicCBUUID = CBUUID(string: "2A9C")
//let Body_Composition_Measurement_CharacteristicCBUUID = CBUUID(string: "00001532-0000-3512-2118-0009AF100700")

let Characteristic_CBUUID_00001542 = CBUUID(string: "00001542-0000-3512-2118-0009AF100700")

let Characteristic_CBUUID_00001543 = CBUUID(string: "00001543-0000-3512-2118-0009AF100700")


class ViewController: UIViewController, CBCentralManagerDelegate {

    // Información
    @IBOutlet weak var labelPeso: UILabel!
    
    // Boton grabar
    @IBOutlet weak var botonGrabar: UIButton!
    
    
    //Variables
    var centralManager:CBCentralManager!
    var weightPeripheral: CBPeripheral!
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
            case .unknown:
            print("central.state is .unknown")
            case .resetting:
            print("central.state is .resetting")
            case .unsupported:
            print("central.state is .unsupported")
            case .unauthorized:
            print("central.state is .unauthorized")
            case .poweredOff:
            print("central.state is .poweredOff")
            case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: [WeightServiceCBUUID])
            }
        }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        
        print(peripheral)
        weightPeripheral = peripheral
        weightPeripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(weightPeripheral)
    
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        weightPeripheral.discoverServices(nil)
        weightPeripheral.discoverServices([WeightServiceCBUUID])
        
        func peripheralManager(
            peripheral: CBPeripheralManager,
            central: CBCentral,
            didSubscribeToCharacteristic characteristic: CBCharacteristic)
        {
            print("subscribed centrals: \( characteristic.value)")
        }
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        centralManager = CBCentralManager()
        centralManager.delegate = self

        
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: CBPeripheralDelegate {
    
// Descubre servicios
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        guard let services = peripheral.services else { return }
        
        for service in services {
            //print(service)
            print(service.characteristics ?? "characteristics are nil")
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
        
    }

// Descubre características
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
    
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
            
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            
            
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            
            }
            
            if characteristic.properties.contains(.indicate) {
                print("\(characteristic.uuid): properties contains .Indicate")
            peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    // Updatera valor de la característica
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        switch characteristic.uuid {
            
        case Body_Composition_Feature_CharacteristicCBUUID:
            print(characteristic.value ?? "no value")
        case Body_Composition_Measurement_CharacteristicCBUUID:
            let peso = WeightInfo(from: characteristic)
            print("\(peso.description) Largo array 2A9C")
            labelPeso.text = String(peso)
            weightPeripheral.setNotifyValue(true, for: characteristic)
            print("notification activa")
       
        case Characteristic_CBUUID_00001542:
            //let peso = WeightInfo(from: characteristic)
            //print("\(peso) Largo array 001542")
            print("Test 001542")
            
        case Characteristic_CBUUID_00001543:
            //let peso = WeightInfo(from: characteristic)
            //print("\(peso) Largo array 001543")
            print("Test 001543")
            
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
}
   // recive el resultado de start/stop notification
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        
        if let error = error {
            print("\(error) error")
        }
        else {
            print("isNotifying: \(characteristic.isNotifying)")
            
        }
                }
    }
    
    private func WeightInfo(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
let byteArray = [UInt8](characteristicData)
        
        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            print("mide en kilos")
            //return Int(byteArray[0])
            let pesoTest = Int((UInt16(byteArray[11] & 255)))
            let pesoTest2 = Int(byteArray[12])
           
            //let steps = (UInt16(buffer[1] & 255) | (UInt16(buffer[2] & 255) << 8))
             //return (Int(byteArray[10]) << 8) + Int(byteArray[11])
             //return Int((UInt16(byteArray[11] & 255))<<8)
            //return Int(byteArray[11])
            return (Int.init(pesoTest2) << 8)
            
        } else {
            print("mide en libras")
            return Int(byteArray[1])
        }

    }

