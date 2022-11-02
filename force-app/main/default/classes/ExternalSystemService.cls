/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-02-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public  with sharing class ExternalSystemService {

    
    @future(callout = true)
    public static void notifyExternalSystem(Set<Id> caseIds){
        List<Case> caseList=new List<Case>([SELECT id, AccountId from case where id in :caseIds]);
        List<Id> accountsIds=new List<Id>();
        List<Contact> contacts = new List<Contact>();
        List<Contact> contactstoNotify = new List<Contact>();
        for(Case newCase: caseList){
            accountsIds.add(newCase.AccountId);
        }  
        contacts= [SELECT id,name,email,accountId, account.Name FROM Contact where accountId in :accountsIds WITH SECURITY_ENFORCED];
        for(Contact newContact : contacts){
            HTTPResponse response = getInfoFromExternalSystem(newContact.Name, newContact.Email);
             // Parse the JSON response
             if (response.getStatusCode() >= 200 && response.getStatusCode() <= 204) {
                // Everything went as expected.
                contactstoNotify.add(newContact);
              
            } else {
                // Log error
                Log.error(System.Label.Response_Status +
                response.getStatusCode() + ' ' + response.getStatus());
            }
                
        }

        notifyContactByEmail(contactstoNotify); 
    }
        
    
    public static HttpResponse getInfoFromExternalSystem(String contactName, String contactEmail) {
        //List<String> contactdata = contactsInfo.get(contactId);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        //request.setEndpoint('callout:heroku_animals');
        request.setEndpoint('callout:heroku_animals');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Set the body as a JSON object
        request.setBody('{"name":"'+ contactName + '-' + contactEmail +'\"}');
        HTTPResponse response = http.send(request);
        return response;
    }


    public static void notifyContactByEmail(List<Contact> contacts){

        if(Schema.sObjectType.Task.isCreateable()
        && Schema.sObjectType.Task.fields.Subject.isUpdateable()
        && Schema.sObjectType.Task.fields.Status.isUpdateable()
        && Schema.sObjectType.Task.fields.Priority.isUpdateable()
        && Schema.sObjectType.Task.fields.WhatId.isUpdateable()){
            List<Task> taskList= new List<Task>();
            for(Contact newContact: contacts){
                Task newTask = new Task();
                newTask.Subject = System.Label.Send_Email_To + account.Name;
                newTask.Status = System.Label.Open_Status;
                newTask.Priority = System.Label.Normal_Priority;
                newTask.WhatId = newContact.AccountId;
                taskList.add(newTask);
            }
            Database.SaveResult[] srList = Database.insert(taskList, false);
            //log Errors
            Log.error(srList);
            
        }
     
    }

}
