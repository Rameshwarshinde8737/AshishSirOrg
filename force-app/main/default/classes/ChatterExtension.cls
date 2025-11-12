/*---------------------------------------------------------------
Copyright 2012-2017 Leankor. All rights reserved
Author:         Narendra Wadkar 
Company:        Leankor
Description:    Extension class for chatter
-----------------------------------------------------------------*/

global with sharing class ChatterExtension{
       
    global static boolean showClassic{get;set;}      
    global static boolean showLex{get;set;}      
      
    global ChatterExtension (ApexPages.StandardController controller){  
   
      string isLex = ApexPages.currentPage().getParameters().get('isLightning') != null ? EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('isLightning'),'UTF-8'): null;
    string chatterUI = leankor__LeanConstants__c.getInstance().leankor__ChatterUI__c;
    if(chatterUI != null ){
     showClassic= (chatterUI.equalsIgnoreCase('ClassicChatter') || chatterUI.equalsIgnoreCase('Auto') && isLex == null) ? true: false;
     showLex = (chatterUI.equalsIgnoreCase('LightningChatter') || chatterUI.equalsIgnoreCase('Auto') && isLex != null) ? true: false;
    }else {
     showClassic = true; 
    }
   
    //Default will be classic if both condition doesn't satisfy 
    if(showClassic == false && showLex == false){
       showClassic = true; 
    }
  }
  
}