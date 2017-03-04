//
//  FirstViewController.swift
//  Pochi
//
//  Created by nori on 2017/03/04.
//  Copyright © 2017年 comexample. All rights reserved.
//

import UIKit
import ExternalAccessory
import Firebase

let robotConnection = RobotConnection()

class RobotConnection: Ev3ConnectionChangedDelegate {
    var connection: Ev3Connection?
    var brick: Ev3Brick?
    

    
    func setup() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(accessoryConnected), name: EAAccessoryDidConnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(accessoryDisconnected), name: EAAccessoryDidDisconnectNotification, object: nil)
        EAAccessoryManager.sharedAccessoryManager().registerForLocalNotifications()
        print(EAAccessoryManager.sharedAccessoryManager().connectedAccessories.count)
        
        let accessory = getEv3Accessory()
        if let a = accessory {
            connect(a)
        } else {
            print("Not Connected.")
        }
    }
    
    private func getEv3Accessory() -> EAAccessory? {
        let man = EAAccessoryManager.sharedAccessoryManager()
        let connected = man.connectedAccessories
        
        for tmpAccessory in connected{
            if Ev3Connection.supportsEv3Protocol(tmpAccessory){
                return tmpAccessory
            }
        }
        return nil
    }
    
    func ev3ConnectionChanged(connected: Bool) {
        print(connected)
    }
    
    @objc func accessoryConnected(notification: NSNotification) {
        print("EAController::accessoryConnected")
        
        let connectedAccessory = notification.userInfo![EAAccessoryKey] as! EAAccessory
        
        // check if the device is a ev3
        if !Ev3Connection.supportsEv3Protocol(connectedAccessory) {
            return
        }
        
        connect(connectedAccessory)
    }
    
    private func connect(accessory: EAAccessory){
        connection = Ev3Connection(accessory: accessory)
        connection?.connectionChangedDelegates.append(self)
        brick = Ev3Brick(connection: connection!)
        connection?.open()
    }
    
    @objc func accessoryDisconnected(notification: NSNotification) {
        print(#function)
    }
    
    // MARK: - Hieh Layer
    
    let defaultPower: Int = 50
    
    func goStraight() {
        moveWheel(.All, power: defaultPower)
    }
    
    func stop() {
        robotConnection.brick?.directCommand.stopMotor(onPorts: .All, withBrake: true)
    }
    
    func goBackForward() {
        moveWheel(.All, power: -defaultPower)
        
    }

    func turnAround() {
        turnLeft(defaultPower)
        turnRight(-defaultPower)
        
    }
    
    func bark() {
        robotConnection.brick?.directCommand.playSound(100, filename: "../prjs/EV3Sound/dog")
        
    }
    
    // MARK: - Middle Layer

    func turnLeft(power: Int) {
        moveWheel(.B, power: power)
    }
    
    func turnRight(power: Int) {
        moveWheel(.C, power: power)
    }
    
    // MARK: - Low Layer
    
    func moveWheel(port: OutputPort, power: Int) {
        robotConnection.brick?.directCommand.turnMotorAtSpeed(onPorts: port, withSpeed: Int16(power))
        robotConnection.brick?.directCommand.turnMotorAtSpeedForTime(port,
                                                                     speed: Int16(power),
                                                                     milliseconds: 2000,
                                                                     brake: true)
    }
}

class FirstViewController: UIViewController {
    
    var action: String?
    
    var actionArray: [AnyObject] = []
    
    var ref: FIRDatabaseReference!
    
    @IBAction func batteryLevel(sender: AnyObject) {
        robotConnection.brick?.directCommand.getBatteryLevel{ [weak self] (level) in
            
            let controller = UIAlertController(title: "Battery Level", message: "\(level)", preferredStyle: UIAlertControllerStyle.Alert)
            controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self?.presentViewController(controller, animated: true, completion: {})
        }
    }

    @IBAction func goStraight(sender: AnyObject) {
        robotConnection.goStraight()
        actionArray.append("goStraight")
    }
    
    @IBAction func turnAroundTapped(sender: AnyObject) {
        robotConnection.turnAround()
        actionArray.append("turnAround")
    }
    
    @IBAction func stopTapped(sender: AnyObject) {
        robotConnection.stop()
        actionArray.append("stop")
    }
    
    @IBAction func backForwardTapped(sender: AnyObject) {
        robotConnection.goBackForward()
        actionArray.append("goBackForward")
    }

    @IBAction func barkTapped(sender: AnyObject) {
        robotConnection.bark()
        actionArray.append("bark")
    }
    
    @IBAction func saveToFirebase(sender: AnyObject) {
         self.ref.child("pochi-test").setValue(actionArray)
    }
    
    @IBAction func repeatAction(sender: AnyObject) {
        ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if !snapshot.exists() { return }
            
            let child = snapshot.childSnapshotForPath("pochi-test")
            guard let actions = child.value as? [String] else { return }

            for i in actions {
                if i == "goStraight" {
                    robotConnection.goStraight()
                } else if i == "turnAround" {
                    robotConnection.turnAround()
                } else if i == "stop" {
                    robotConnection.stop()
                } else if i == "goBackForword" {
                    robotConnection.goBackForward()
                } else if i == "bark" {
                    robotConnection.bark()
                }
            }
        })
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
    }
}

