/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-02-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class CaseTriggerTest {  

    @TestSetup
    static void makeData(){
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
        Case request1 = (Case)TestDataFactory.createSObject('Case', new Map<String,Object> {
            'Subject' => 'Event Booking',
            'Description' => 'Book Spots for Company A1 & their 4 employees',
            'AccountId'   => company.id
        },true);
        Case request2 = (Case)TestDataFactory.createSObject('Case', new Map<String,Object> {
            'Subject' => 'Event Booking',
            'Description' => 'Book Spots for Company A1 & their 4 employees',
            'AccountId'   => company.id
        },true);
    }

    @isTest
    public static void caseWithoutAccountTest(){
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
    public static void accountCaseWithoutContactsTest(){
        // Given
        Account company = [SELECT id from Account limit 1];
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
    public static void validateWebOriginContactsTest(){
        
        Account company = [SELECT id, (SELECT id from Contacts) from Account  limit 1];
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
    public static void validatePhoneOriginContactsTest(){
        // Given
        Account company = [SELECT id, (SELECT id from Contacts) from Account  limit 1];
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


    @isTest
    public static void getInfoFromExternalSystemTest(){
        Contact contact1 = [SELECT id, accountId, Name, Email from Contact limit 1];
        // Set mock callout class 
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HTTPResponse response = ExternalSystemService.getInfoFromExternalSystem(contact1.Name, contact1.Email);
        Test.stopTest();
        //Verify response received contains fake values
        String contentType = response.getHeader('Content-Type');
        System.assert(contentType == 'application/json;charset=UTF-8','We should have the same content type');
        String actualValue = response.getBody();
        String expectedValue = '{"animals":["majestic badger","fluffy bunny","scary bear","chicken"]}';
        System.assertEquals(actualValue, expectedValue,'We should have the exact response body');
        System.assertEquals(200, response.getStatusCode(),'We should have the exact response body 200');
    
    }


    @isTest
    public static void notifyExternalSystemTest(){

        Map<Id,Case> caseList = new Map<Id,Case>([Select id, accountId from case limit 2]);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        ExternalSystemService.notifyExternalSystem(caseList.keySet());
        Test.stopTest();
    }


    @isTest
    public static void notifyExternalSystemErrorTest(){
        Map<Id,Case> caseList = new Map<Id,Case>([Select id, accountId from case limit 2]);
        // Set mock callout class 
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorError());
        ExternalSystemService.notifyExternalSystem(caseList.keySet());
        Test.stopTest();
        //Verify response received contains fake values
        //System.assertEquals(205, response.getStatusCode(),'We should have the exact response body 205');
    
    }

}

