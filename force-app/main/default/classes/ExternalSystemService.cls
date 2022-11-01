/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-01-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public  with sharing class ExternalSystemService {

    public void notifyExternalSystem(List<Case> casesList){
        List<Id> accountsIds;
        List<Contact> contacts;
        for(Case newCase: newCaseList){
            accountsIds.add(c.AccountId);
        }  
        List<Account> theAccounts= [SELECT id, (select id,name,email from contacts) FROM Account where id in :accountsIds WITH SECURITY_ENFORCED];
        
        for(Contact contact : theAccounts.contacts){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:heroku_animals');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Set the body as a JSON object
            request.setBody('{"name":"'+ contact.name + '-' + contact.email  +'\"}');
            HTTPResponse res = http.send(request);
             // Parse the JSON response
             if (response.getStatusCode() >= 200 && response.getStatusCode() <= 204) {
                // Everything went as expected.
                contacts.add(contact);
              
            } else {
                // System.debug('The status code returned was not expected: ' +
                // response.getStatusCode() + ' ' + response.getStatus());
                // Log error
                Log.error('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
            }
                
        }

        notifyContactByEmail(contacts); 
    }
        

    

    public void notifyContactByEmail(List<Contact> contacts){

        // roll back point    
        Savepoint sp = Database.setSavepoint();

        if(Schema.sObjectType.Task.isCreateable()
        && Schema.sObjectType.Task.fields.Subject.isUpdateable()
        && Schema.sObjectType.Task.fields.Status.isUpdateable()
        && Schema.sObjectType.Task.fields.Priority.isUpdateable()
        && Schema.sObjectType.Task.fields.WhatId.isUpdateable()){
            
            List<Task> taskList= new List<Task>();
            for(Contact contact: contacts){
                Task task = new Task();
                task.Subject = System.Label.Send_Email_To + account.name;
                task.Status = System.Label.Open_Status;
                task.Priority = System.Label.Normal_Priority;
                task.WhatId = account.ID;
                taskList.add(task);
            }
        
            try{
                Database.SaveResult[] srList = Database.insert(taskList, false);
                // Log errors
                Log.error(srList);
            }catch(DmlException e){
                err=e.getMessage();
                // rollback entire transaction
                Database.RollBack(sp);
            }
            
        }
     
    }

}
