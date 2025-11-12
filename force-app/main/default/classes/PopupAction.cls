/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  PopupAction.cls
* CLASS: PopupAction
* USAGE: manages to Create Card .
*/
Global with sharing class PopupAction{
    @InvocableMethod
    Global static List<popUpResult> PopupProcess(List<PopUpRequest> requests){
        for(PopUpRequest request : requests){
            if (String.isNotBlank(request.CardID) && Util.getSObjectName(request.CardID) != 'leankor__KanbanCard__c') {
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        List<popUpResult> returnlist = new List<popUpResult>();
        for(PopUpRequest inputlog:requests){
            inputlog.YES = (inputlog.YES==null ? '':inputlog.YES);
            inputlog.Buttonflag = (inputlog.Buttonflag== null ? false :inputlog.Buttonflag);
            popUpResult rst = PopUpAction(inputlog);
            returnlist.add(rst);
        }
        return returnlist;
    }


    public static popUpResult popUpAction(PopUpRequest request){

        Map<Id, leankor__KanbanCard__c> kanbanCardMap = new Map<Id, leankor__KanbanCard__c>([Select Id, 
														                                            Name,
                                                                                                    leankor__Valuestream__c
                                                                                                From leankor__Kanbancard__c
                                                                                                Where Id = :request.cardID
                                                                                                    And leankor__IsRecordDeleted__c = false
                                                                                                With Security_Enforced]);
       
        popUpResult popupResult = new popUpResult();
            
        if(kanbanCardMap.containsKey(request.cardID)) {
            leankor.KanbanController.PopUp pu = new leankor.KanbanController.PopUp();
            pu.CardID = request.CardID;
            pu.YES= request.YES;
            //pu.sessionID = zKALogs[0].leankor__sessionID__c;
            pu.sessionID = UserInfo.getSessionId();
            pu.NO = request.NO;
            pu.Buttonflag = request.Buttonflag;
            pu.customMessage = request.customMessage; 
            pu.ForceUndo = request.ForceUndo;
            pu.flowWithGS = true;
            pu.ValueStream =  kanbanCardMap.get(request.cardID).leankor__ValueStream__c;          
            String someJSONData = JSON.Serialize(pu);          
            leankor.RealTimeController.KanbanStateChange(kanbanCardMap.get(request.cardID).leankor__ValueStream__c, 'PopUp', request.sessionID, someJSONData);
            popupResult.Result = someJSONData;
        }
        return popupResult;
    }

    Global class PopUpRequest{
        @invocableVariable(label='Kanban CardID' description='CardID on for we have to perform popup' required=true)
            Global String CardID;
        @invocableVariable(label='Label On YES Button ?' description='Please provide label for YES button')
            Global String YES;
        @invocableVariable(label='Label On No Button ?' description='Please provide label for No button')
            Global String NO;
        @invocableVariable(label='ForceUndo' description='If this field is true, then only undo occur')
            Global Boolean ForceUndo = false;    
        @invocableVariable(label='Show one button' description='If true then only show "Yes" button label ')
            Global Boolean Buttonflag;
            Global String sessionID ;
        @invocableVariable(label='Message on PopUp ?' description='Please provide custom Message to display on popup.' required=true)
            Global String customMessage;
    }
    Global class popUpResult{   
        @invocableVariable(label='Result' description='Is broadcast success or failed ')
            Global String Result;
    }
}