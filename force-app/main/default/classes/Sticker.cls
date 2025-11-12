/**************************************************************************
 * Author     : Reynald Ocampo
 * Description: Sticker CRUD
 **************************************************************************/ 
public with sharing class Sticker {

    // create records of stickers
    public static List<leankor__Sticker__c> createStickers(List<leankor__Sticker__c> stickers) {
        StickerBehavior stickerBehavior = new StickerBehavior();
        if (!stickerBehavior.isCreateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        try {
            insert stickers;
        } catch(DMLException e){
            throw e;
        }
        return stickers;
    }


    // all stickers
    public static List<leankor__Sticker__c> readStickers(List<leankor__Sticker__c> stickers) {
        return
            [Select 
                    Id, 
                    leankor__ValueStream__c 
                From leankor__Sticker__c 
                Where Id In :stickers
                    And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                With Security_Enforced
                Limit 50000];
    }


    // get board stickers (local and global) using board ids
    public static List<leankor__Sticker__c> readStickers(List<leankor__ValueStream__c> valueStreams) {
        return
            [Select 
                    Id,
                    Name,
                    leankor__ValueStream__c
                From leankor__Sticker__c 
                Where (leankor__ValueStream__c = null
                    Or leankor__ValueStream__c In :valueStreams)
                    And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                With Security_Enforced
                Limit 50000];
    }
}