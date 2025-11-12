/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: DetectDevice.cls
 * CLASS: DetectDevice     
 */
 
public with sharing class DetectDevice {
    public String getPhoneGapJS() { 
        return '{!$Resource.Cordova}';
    }



}