/*********************************************************************************
* Company     : Leankor
* Description : Showing the Popup Message 
*********************************************************************************/ 
global with sharing class PopupSFAction {

    global class PopUpRequest{
        @invocableVariable(label='Kanban CardID' description='CardID on for we have to perform popup' required=true)
            global String CardID;
        @invocableVariable(label='Label On YES Button ?' description='Please provide label for YES button')
            global String YES;
        @invocableVariable(label='Label On No Button ?' description='Please provide label for No button')
            global String NO;
        @invocableVariable(label='ForceUndo' description='If this field is true, then only undo occur')
            global Boolean ForceUndo = false;    
        @invocableVariable(label='Show one button' description='If true then only show "Yes" button label ')
            global Boolean Buttonflag;
            global String sessionID ;
        @invocableVariable(label='Message on PopUp ?' description='Please provide custom Message to display on popup.' required=true)
            global String customMessage;
    }

    @InvocableMethod
    global static List<PopUpRequest> PopupProcess(List<PopUpRequest> remoteRequest){

        List<Leankor.PopupAction.PopUpRequest> allRequest = new List<Leankor.PopupAction.PopUpRequest>();
        for(PopupSFAction.PopUpRequest singleRequest : remoteRequest){
            Leankor.PopupAction.PopUpRequest request = new Leankor.PopupAction.PopUpRequest();
            request.CardID = singleRequest.CardID;
            request.YES = singleRequest.YES;
            request.NO = singleRequest.NO;
            request.ForceUndo = singleRequest.ForceUndo;
            request.Buttonflag = singleRequest.Buttonflag;
            request.sessionID = singleRequest.sessionID;
            request.customMessage = singleRequest.customMessage;
            allRequest.add(request);
        }
        Leankor.PopupAction.PopupProcess(allRequest);
        return remoteRequest;

    }
}