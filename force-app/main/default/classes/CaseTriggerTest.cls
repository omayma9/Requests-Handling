/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-01-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class CaseTriggerTest {  

        @isTest
        public static void caseWithoutAccount(){
            // Given
    
            Case request = (Case)TestDataFactory.createSObject('Case', new Map<String,Object> {
                'Origin' => 'Phone',
                'Subject' => 'Event Booking',
                'Description' => 'Book Spots'
            },false);

            Database.SaveResult result;
            DmlException unexpectedException;
            // When 
            Test.startTest();
                result = Database.insert(request, false);
            Test.stopTest();
            // Then
            System.assert(!result.isSuccess(),'You cannot create a request without attaching an account');
            System.assert(result.getErrors().size() > 0,'The error message is triggered');
            System.assertEquals(System.Label.Case_Without_Account,
            result.getErrors()[0].getMessage(),'The case should have an account');
        }
        
        @isTest
        public static void accountCaseWithoutContacts(){
            // Given
            Account company = (Account)TestDataFactory.createSObject('Account', new Map<String,Object> {
                'Name' => 'Salesforce'
            },true);
            Case request = (Case)TestDataFactory.createSObject('Case', new Map<String,Object> {
                'Origin' => 'Phone',
                'Subject' => 'Event Booking',
                'Description' => 'Book Spots',
                'AccountId' =>company.Id
            },false);
            // When 
            Test.startTest();
            Database.SaveResult result = Database.insert(request, false);
            Test.stopTest();
            // Then
            System.assert(!result.isSuccess(),'You cannot create a request without attaching contacts to the account');
            System.assert(result.getErrors().size() > 0,'The error message is triggered');
            System.assertEquals(System.Label.Accounts_Without_Contacts,
            result.getErrors()[0].getMessage(), 'the account should had have contacts');
        }


        @isTest
        public static void validateWebOriginContacts(){
            // Given
            Account company = (Account)TestDataFactory.createSObject('Account', new Map<String,Object> {
                'Name' => 'Salesforce'
            },true);
            Contact contact1 = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object> {
                'LastName' => 'Contact 1',
                'AccountId'=> company.Id
            },true);
            Contact contact2 = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object> {
                'LastName' => 'Contact 2',
                'AccountId'=> company.Id
            },true);
          
        
            Case request = (Case)TestDataFactory.createSObject('Case', new Map<String,Object> {
                'Origin' => 'Web',
                'Subject' => 'Event Booking',
                'Description' => 'Book Spots for Company A1 & their 4 employees',
                'AccountId' =>company.Id
            },false);


            // When 

            Test.startTest();

            Database.SaveResult result = Database.insert(request, false);

            Test.stopTest();

            // Then
            //Web
            System.assert(!result.isSuccess(),'The web origin case should have only 1 contact');
            System.assert(result.getErrors().size() > 0,'The error message is triggered');
            System.assertEquals(System.Label.Web_Case_Attendee,
            result.getErrors()[0].getMessage(),'We should have only 1 contact');
        }

        @isTest
        public static void validatePhoneOriginContacts(){
            // Given
            Account company = (Account)TestDataFactory.createSObject('Account', new Map<String,Object> {
                'Name' => 'Salesforce'
            },true);
            Contact contact1 = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object> {
                'LastName' => 'Contact 1',
                'AccountId'=> company.Id
            },true);
            Contact contact2 = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object> {
                'LastName' => 'Contact 2',
                'AccountId'=> company.Id
            },true);
            Contact contact3 = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object> {
                'LastName' => 'Contact 3',
                'AccountId'=> company.Id
            },true);
            Contact contact4 = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object> {
                'LastName' => 'Contact 4',
                'AccountId'=> company.Id
            },true);

            Case request = (Case)TestDataFactory.createSObject('Case', new Map<String,Object> {
                'Origin' => 'Phone',
                'Subject' => 'Event Booking',
                'Description' => 'Book Spots for Company A1 & their 4 employees',
                'AccountId' =>company.Id
            },false);

           
    
            // When 

            Test.startTest();

            Database.SaveResult result = Database.insert(request, false);

            Test.stopTest();

            // Then
        
            //Phone
            System.assert(!result.isSuccess(),'The phone origin case should have only 3 contacts');
            System.assert(result.getErrors().size() > 0,'The error message is triggered');
            System.assertEquals(System.Label.Phone_Case_Attendees,
            result.getErrors()[0].getMessage(),'We should have only 3 contacts');

        }

       


        
     
            
        // @isTest
        // public static void refuseEventBookingWhenNumberOfAttendeesIsMoreThanOneForWebCases(){
        //     // Given
            
        //     Account a1 = new Account(Name = 'Salesforce');
        //     insert a1;
            
        //     Contact c1 = new Contact(LastName = 'Contact 1', AccountId = a1.ID);
        //     insert c1;
    
        //     Contact c2 = new Contact(LastName = 'Contact 2', AccountId = a1.ID);
        //     insert c2;
    
        //     Contact c3 = new Contact(LastName = 'Contact 3', AccountId = a1.ID);
        //     insert c3;
    
        //     Case request = new Case(Origin = 'Web',Subject = 'Event Booking', Description = 'Book Spots for Company A1 & their 3 employees', AccountId = a1.ID);
            
        //     // When 

        //     Test.startTest();

        //     Database.SaveResult result = Database.insert(request, false);

        //     Test.stopTest();

        //     // Then

        //     // System.assert(!result.isSuccess());
        //     // System.assert(result.getErrors().size() > 0);
        //     // System.assertEquals('Web request are only allowed to have one attendee',
        //     // result.getErrors()[0].getMessage());

                
        // } 
    
    
}
