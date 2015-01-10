#!/bin/bash

# Project RetroRig: https://github.com/ProfessorKaos64/RetroRig
#
# This script detects a change of the amount of available PS3 controller. 
# If such a change was detected, it notifies XBMC.
#
# If enabled, it will start RetroRig automatically 
# for the first game controller being switched on.
#
# Author: Jens-Christian, aka  beaumanvienna/JC
# Author: Michael DeGuzis, aka  PK
#
# Revision: 20141030, JC, support for PS3 / USB and auto start XBMC function
# Revision: 20141229, PK, this will need overhauled for EmulationStation if need be

autostartES_PS3_USB=enabled
autostartES_PS3_BT=enabled

PS3_BT_controllerAvailable=`cat /proc/bus/input/devices | grep "PLAYSTATION(R)3 Controller ("`
PS3_USB_controllerAvailable=`lsusb | grep "PlayStation 3 Controller"`

while [ 0 ]
do
  oldPS3_BT_controllerAvailable=$PS3_BT_controllerAvailable
  oldPS3_USB_controllerAvailable=$PS3_USB_controllerAvailable  
  
  #check for PS3 / USB controller
  
  PS3_USB_controllerAvailable=`lsusb | grep "PlayStation 3 Controller"`
  if [ "$PS3_USB_controllerAvailable" != "$oldPS3_USB_controllerAvailable" ]; then
    echo "[begin:] PS3 / USB controller changed"
    
    #first attempt
    service xboxdrv stop
    killall -9 xboxdrv
    service xboxdrv start

    #second attempt
    service xboxdrv stop
    killall -9 xboxdrv
    service xboxdrv start
    
    #auto start xbmc for first controller being switched on
    if [ "$autostartES_PS3_USB" == "enabled" ]; then
      echo "auto start function"
      autostarted=false
      setup_running=`ps ax|grep retrorig-es-setup| grep -v grep`
      
      if [ -z "$setup_running" ]; then
        #retrorig-setup-es is not running
        echo "retrorig-setup-es is not running"
        
        if [ -z "$oldPS3_USB_controllerAvailable" ]; then
          #first controller was switched on
          echo "first controller was switched on"
          
          es_running=`ps ax|grep emulationstation |grep -v grep`
          if [ -z "$es_running" ]; then
            # ES not running yet
            echo "EmulationStation not running yet"
        
            # get user name
            user=`ps aux |grep "/bin/dbus-daemon --config-file"|grep -v grep|cut -f 1 -d " "`
        
            export export DISPLAY=:0.0
            echo "auto starting RetroRig-ES for user $user"
            sudo -u $user -g $user -s /usr/share/applications/startRetroES.sh &
            autostarted=true
            
          else
            echo "RetroRig-ES *not* started automatically: EmulationStation already running, xbmc_running="$es_running
          fi
        else
          echo "RetroRig-ES *not* started automatically: first controller not switched on, oldPS3_USB_controllerAvailable="$oldPS3_USB_controllerAvailable
        fi
      else
        echo "RetroRig-ES *not* started automatically: setup_running="$setup_running
      fi
    
      #diagnostic message
      sleep 2
      if [ "$autostarted" == "true" ]; then
        if [ -n "$(ps ax|grep emulationstation | grep -v grep)" ]; then
          echo "RetroRig-ES sucessfully started"
        else
          echo "attempt to start RetroRig-ES failed"
        fi
      fi
      
    else
      echo "auto start function disabled"
    fi
    
    #Avoid starting XBMC after USB is unplugged.
    #For some reasons the game controller connects via
    #BT after being unplugged from USB
    autostartES_PS3_BT=enabled
    echo "[end:] PS3 / USB controller changed"
  fi
  
  #check for PS3 / Bluetooth controller
  
  PS3_BT_controllerAvailable=`cat /proc/bus/input/devices | grep "PLAYSTATION(R)3 Controller ("`
  if [ "$PS3_BT_controllerAvailable" != "$oldPS3_BT_controllerAvailable" ]; then
    echo "[begin:] PS3 / Bluetooth controller changed"
  
    #auto start xbmc for first controller being switched on
    if [ "$autostartES_PS3_BT" == "enabled" ]; then
      echo "auto start function"
      autostarted=false
      setup_running=`ps ax|grep retrorig-es-setup| grep -v grep`
      
      if [ -z "$setup_running" ]; then
        #retrorig-setup is not running
        echo "retrorig-setup is not running"
        
        if [ -z "$oldPS3_BT_controllerAvailable" ]; then
          #first controller was switched on
          echo "first controller was switched on"
      
          es_running=`ps ax|grep emulationstation |grep -v grep`
          if [ -z "$es_running" ]; then
            # xbmc not running yet
            echo "EmulationStation not running yet"
        
            # get user name
            user=`ps aux |grep "/bin/dbus-daemon --config-file"|grep -v grep|cut -f 1 -d " "`
        
            export export DISPLAY=:0.0
            echo "auto starting RetroRig-ES for user $user"
            sudo -u $user -g $user -s /usr/share/applications/startRetroES.sh &
            autostarted=true
          else
            echo "RetroRig-ES *not* started automatically: XBMC already running, xbmc_running="$es_running
          fi
        else
          echo "RetroRig-ES *not* started automatically: first controller not switched on, oldPS3_BT_controllerAvailable="$oldPS3_BT_controllerAvailable
        fi
      else
        echo "RetroRig-ES *not* started automatically: setup_running="$setup_running
      fi
    
      #diagnostic message
      sleep 2
      if [ "$autostarted" == "true" ]; then
        if [ -n "$(ps ax| grep emulationstation |grep -v grep)" ]; then
          echo "RetroRig-ES sucessfully started"
        else
          echo "attempt to start RetroRig-ES failed"
        fi
      fi
      
    else
      echo "auto start function disabled"
    fi
    
    echo "[end:] PS3 / Bluetooth controller changed"
  fi
  sleep 1
done

