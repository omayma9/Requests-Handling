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
        
        //@isTest
        // public static void refuseCaseCreationWhenNoContactIsAttachedToAnAccount(){
        //     // Given
      
        //     Account a1 = new Account(Name = 'Salesforce');
        //     insert a1;

        //     Case request = new Case(Origin = 'Phone',Subject = 'Event Booking', Description = 'Book Spots', AccountId = a1.ID);
            
        //     // When 

        //     Test.startTest();

        //     Database.SaveResult result = Database.insert(request, false);

        //     Test.stopTest();

        //     // Then

        //     // System.assert(!result.isSuccess());
        //     // System.assert(result.getErrors().size() > 0);
        //     // System.assertEquals('You cannot create a request for accounts without contacts',
        //     // result.getErrors()[0].getMessage());
        // }
        
        // @isTest
        // public static void bookEventFromPhone(){
        //     // Given
            
        //     Account a1 = new Account(Name = 'Salesforce');
        //     insert a1;
            
        //     Contact c1 = new Contact(LastName = 'Contact 1', AccountId = a1.ID);
        //     insert c1;
    
        //     Contact c2 = new Contact(LastName = 'Contact 2', AccountId = a1.ID);
        //     insert c2;
    
        //     Contact c3 = new Contact(LastName = 'Contact 3', AccountId = a1.ID);
        //     insert c3;
    
        //     Case request = new Case(Origin = 'Phone',Subject = 'Event Booking', Description = 'Book Spots for Company A1 & their 3 employees', AccountId = a1.ID);
            
        //     // When 

        //     Test.startTest();

        //     Database.SaveResult result = Database.insert(request, false);
        //     Test.stopTest();

        //     // Then

        //     //System.assert(result.isSuccess());


        // }


        // @isTest
        // public static void refuseEventBookingWhenNumberOfAttendeesIsMoreThanThreeForPhoneCases(){
        //     // Given
            
        //     Account a1 = new Account(Name = 'Salesforce');
        //     insert a1;
            
        //     Contact c1 = new Contact(LastName = 'Contact 1', AccountId = a1.ID);
        //     insert c1;
    
        //     Contact c2 = new Contact(LastName = 'Contact 2', AccountId = a1.ID);
        //     insert c2;
    
        //     Contact c3 = new Contact(LastName = 'Contact 3', AccountId = a1.ID);
        //     insert c3;

        //     Contact c4 = new Contact(LastName = 'Contact 4', AccountId = a1.ID);
        //     insert c4;
    
        //     Case request = new Case(Origin = 'Phone',Subject = 'Event Booking', Description = 'Book Spots for Company A1 & their 4 employees', AccountId = a1.ID);
            
        //     // When 

        //     Test.startTest();

        //     Database.SaveResult result = Database.insert(request, false);

        //     Test.stopTest();

        //     // Then
        //     // System.assert(!result.isSuccess());
        //     // System.assert(result.getErrors().size() > 0);
        //     // System.assertEquals('Phone request are only allowed to have three attendee',
        //     // result.getErrors()[0].getMessage());

        // }
        
        // @isTest
        // public static void bookEventFromTheWeb(){
        //     // Given
            
        //     Account a1 = new Account(Name = 'Salesforce');
        //     insert a1;
                
                   
        //     Contact c1 = new Contact(LastName = 'Contact 1', AccountId = a1.ID);
        //     insert c1;
    
        //     Case request = new Case(Origin = 'Web',Subject = 'Event Booking', Description = 'Book One Spot for Company A1', AccountId = a1.ID);
            
        //     // When 

        //     Test.startTest();

        //     Database.SaveResult result = Database.insert(request, false);

        //     Test.stopTest();

        //     // Then

        //     //System.assert(result.isSuccess());

                
        // } 
            
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
