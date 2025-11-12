/* Copyright 2017 - 2017 Lucidsoft Inc.All rights reserved.
 * FILE : AbstractCRUDBehaviour.cls
 * CLASS : AbstractCRUDBehaviour
 * USAGE : This is the abstract class which implements CRUDBehaviour interface.
 *        Methods marked as abstract MUST override in the extended class.
 *        Methods marked with protected access modifier, is visible only to extended classes.
 */
public abstract class AbstractCRUDBehaviour implements CRUDBehaviour{
    
    //MUST override in extended class
    public abstract boolean isAccessible();
    
    //MUST override in extended class
    public abstract boolean isUpdateable();
    
    //MUST override in extended class
    public abstract boolean isCreateable();
    
    //MUST override in extended class
    public abstract boolean isDeletable();

    //CAN override in extended class
    public virtual boolean isAccessible(String [] accessibleFields) { return false;}

    //CAN override in extended class
    public virtual boolean isUpdateable(String [] updateablFields) { return false;}

    //CAN override in extended class
    public virtual boolean isCreateable(String [] createableFields) { return false;}
    
    // Get the community network Id. Later can be checked using user licence type
    private String isCommunityUser = Network.getNetworkId();

    // This Object are not accesible to the Community user
    private static Set<String> notAvailableObjectForCommunityUser = new Set<String> {'Opportunity', 'Campaign', 'Lead'};
    

    //visible to extended classes only
    protected boolean checkFieldsAccessible(Map<String, Schema.SObjectField> fieldMap) {
		// Ramanand : 26/05/2021 - Removing FLS because it will every time increase work for user if anyoned will add any custom setting.
        /*for (String fieldName : fieldMap.keySet()) {
            if (isCommunityUser != null && isObjectNotAvailableForCommunityUser(fieldMap, fieldName)) {
                continue;
            }

            if (fieldMap.get(fieldName).getDescribe().isCustom() && !fieldMap.get(fieldName).getDescribe().isAccessible()) {
                return false;
            }
        }*/

        return true;    
    }


    //overloaded method visible to extended classes only
    protected boolean checkFieldsAccessible(Map<String, Schema.SObjectField> fieldMap, String [] accessibleFields) {
		// Ramanand : 26/05/2021 - Removing FLS because it will every time increase work for user if anyoned will add any custom setting.
        /*for (String fieldName : accessibleFields) {
            if (isCommunityUser != null && isObjectNotAvailableForCommunityUser(fieldMap, fieldName)) {
                continue;
            }

            if (!fieldMap.get(fieldName).getDescribe().isAccessible()) {
                return false;
            }
        }*/

        return true;  
    }    
    
    //visible to extended classes only
    protected boolean checkFieldsUpdateable(Map<String, Schema.SObjectField> fieldMap) {
		// Ramanand : 26/05/2021 - Removing FLS because it will every time increase work for user if anyoned will add any custom setting.
        /*for (String fieldName : fieldMap.keySet()) {
            if (isCommunityUser != null && isObjectNotAvailableForCommunityUser(fieldMap, fieldName)) {
                continue;
            }

            if (fieldMap.get(fieldName).getDescribe().isCustom() && !fieldMap.get(fieldName).getDescribe().isUpdateable()
                && !fieldMap.get(fieldName).getDescribe().isCalculated()
                && !fieldMap.get(fieldName).getDescribe().isAutoNumber()) {
                return false;
            }
        }*/

        return true;    
    }


    //overloaded method visible to extended classes only
    protected boolean checkFieldsUpdateable(Map<String, Schema.SObjectField> fieldMap, String [] updateablFields) {
		// Ramanand : 26/05/2021 - Removing FLS because it will every time increase work for user if anyoned will add any custom setting.
        /*for (String fieldName : updateablFields) {
            if (isCommunityUser != null && isObjectNotAvailableForCommunityUser(fieldMap, fieldName)) {
                continue;
            }

            if (!fieldMap.get(fieldName).getDescribe().isUpdateable()) {
                return false;
            }
        }*/

        return true;  
    }   

    
    //visible to extended classes only
    protected boolean checkFieldsCreateable(Map<String, Schema.SObjectField> fieldMap) {
		// Ramanand : 26/05/2021 - Removing FLS because it will every time increase work for user if anyoned will add any custom setting.
        /*for (String fieldName : fieldMap.keySet()) {
            
            if (isCommunityUser != null && isObjectNotAvailableForCommunityUser(fieldMap, fieldName)) {
                continue;
            }

            if (fieldMap.get(fieldName).getDescribe().isCustom() && !fieldMap.get(fieldName).getDescribe().isCreateable()
                && !fieldMap.get(fieldName).getDescribe().isCalculated()
                && !fieldMap.get(fieldName).getDescribe().isAutoNumber()) {
                return false;
            }
        }*/

        return true;    
    }


    //overloaded method visible to extended classes only
    protected boolean checkFieldsCreateable(Map<String, Schema.SObjectField> fieldMap, String [] createableFields) {
		// Ramanand : 26/05/2021 - Removing FLS because it will every time increase work for user if anyoned will add any custom setting.
        /*for (String fieldName : createableFields) {
            

            if (isCommunityUser != null && isObjectNotAvailableForCommunityUser(fieldMap, fieldName)) {
                continue;
            }

            if (!fieldMap.get(fieldName).getDescribe().isCreateable()) {
                return false;
            }
        }*/

        return true;  
    }      
    
    
    private Boolean isObjectNotAvailableForCommunityUser(Map<String, Schema.SObjectField> fieldMap, String fieldName) {
        Boolean isAvailable = false;

        for (Schema.SObjectType reference : fieldMap.get(fieldName).getDescribe().getReferenceTo()) {
            if (notAvailableObjectForCommunityUser.contains(reference.getDescribe().getName())) {
                isAvailable = true;
                break;
            }
        }

        return isAvailable;
    }
}