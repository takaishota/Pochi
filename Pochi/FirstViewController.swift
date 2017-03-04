//
//  FirstViewController.swift
//  Pochi
//
//  Created by nori on 2017/03/04.
//  Copyright © 2017年 comexample. All rights reserved.
//

import UIKit
import ExternalAccessory

class FirstViewController: UIViewController {
    
    var connection: Ev3Connection?
    var brick: Ev3Brick?
    
    func setup() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(accessoryConnected), name: EAAccessoryDidConnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(accessoryDisconnected), name: EAAccessoryDidDisconnectNotification, object: nil)
        EAAccessoryManager.sharedAccessoryManager().registerForLocalNotifications()
        print(EAAccessoryManager.sharedAccessoryManager().connectedAccessories.count)
    }
    
    func accessoryConnected(notification: NSNotification) {
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
        brick = Ev3Brick(connection: connection!)
        connection?.open()
    }
    
    func accessoryDisconnected(notification: NSNotification) {
        print(#function)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setup()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

