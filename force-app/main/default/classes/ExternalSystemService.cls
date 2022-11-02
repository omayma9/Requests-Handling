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
        List<Messaging.SingleEmailMessage> lstSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
        List<String> toAddresses = new List<String>();
        for (Contact newContact : contacts) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            toAddresses.add(newContact.Email);
            email.setSubject('New reservation Created!');
            email.setToAddresses(toAddresses);
            email.setHTMLBody('The reservation for the account : ' + Account.Name + ' was registered successfully!');
            lstSingleEmailMessage.add(email);    
        }
        Messaging.SendEmailResult[] r = Messaging.sendEmail(lstSingleEmailMessage);

    }

}
