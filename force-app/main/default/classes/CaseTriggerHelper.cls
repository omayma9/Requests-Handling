/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-01-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class CaseTriggerHelper {


    public static void validateAccessibility(List<Case> newCaseList){
        if(Schema.sObjectType.Account.isAccessible()
        && Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Case.fields.AccountId.isAccessible()){
            contactValidationRules(newCaseList);
        }
        // else{
        //     newCase.addError(System.Label.Objects_Fields_Access);
        // }
    }

    public static void contactValidationRules(List<Case> newCaseList) {

        List<Id> accountsIds;
        for(Case newCase: newCaseList){  
            if(newCase.AccountId != null){    
                accountsIds.add(newCase.AccountId);
            } else {
                newCase.addError(System.Label.Case_Without_Account);
            }
        }           
        Map<Id,Account> casesAccountsMap=new Map<Id,Account>([SELECT ID, (select id from contacts) FROM Account where id in :accountsIds]);
        for(Case newCase: newCaseList){
            //ask about it   
            Integer contactsListSize = casesAccountsMap.get(newCase.AccountId).Contacts.size();
            if(contactsListSize ==0){
                newCase.addError(System.Label.Accounts_Without_Contacts);
            }   else {
                contactsNumberValidation(newCase,contactsListSize);                                  
            }       
            
        }        
    }

    public static void contactsNumberValidation(Case newCase, Integer contactsListSize){
        if(Schema.sObjectType.Case.fields.Origin.isUpdateable()){
            switch on newCase.Origin {
                when 'Web' {
                    if(contactsListSize >= 2 ){
                        newCase.addError(System.Label.Web_Case_Attendee);
                    }
                }
                when 'Phone' {
                    if(contactsListSize >= 4 ){
                        newCase.addError(System.Label.Phone_Case_Attendees);
                    }
                }
            }
        }else{
            //ask about it
            newCase.addError(System.Label.Origin_Field_Access);
        }       
    }

    public static void notifyExternalService(Map<Id,Case> newCaseMap){
        List<Case> newCaseList = [SELECT AccountId, Status FROM Case where id in :newCaseMap.keySet() WITH SECURITY_ENFORCED];
        for(Case newCase:newCaseList){
            if(newCase.Status == System.Label.Closed_Status){
                ExternalSystemService service = new ExternalSystemService();
                service.notifyExternalSystem(newCaseMap.values());
            }
        }      
    }


}
