/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-01-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public  with sharing class ExternalSystemService {

    public void notifyExternalSystem(List<Case> caseList){
        List<Id> accountsIds;
        List<Contact> contacts;
        for(Case newCase: caseList){
            accountsIds.add(newCase.AccountId);
        }  
        contacts= [SELECT id,name,email,accountId, account.Name FROM Contact where accountId in :accountsIds WITH SECURITY_ENFORCED];
        for(Contact newContact : contacts){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:heroku_animals');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Set the body as a JSON object
            request.setBody('{"name":"'+ newContact.name + '-' + newContact.email  +'\"}');
            HTTPResponse response = http.send(request);
             // Parse the JSON response
             if (response.getStatusCode() >= 200 && response.getStatusCode() <= 204) {
                // Everything went as expected.
                contacts.add(newContact);
              
            } else {
                // Log error
                Log.error(System.Label.Response_Status +
                response.getStatusCode() + ' ' + response.getStatus());
            }
                
        }

        notifyContactByEmail(contacts); 
    }
        

    

    public void notifyContactByEmail(List<Contact> contacts){

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
