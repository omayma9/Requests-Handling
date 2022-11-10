/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-10-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private with sharing class CaseTriggerTest {  

    @TestSetup
    static void makeData(){
        Account companyWithoutAttendies = (Account)TestDataFactory.createSObject('Account', new Map<String,Object> {
            'Name' => 'companyWithoutAttendies'
        },true);
        Account companyWithAttendies = (Account)TestDataFactory.createSObject('Account', new Map<String,Object> {
            'Name' => 'companyWithAttendies'
        },true);
        Contact contact1 = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object> {
            'LastName' => 'Contact 1',
            'AccountId'=> companyWithAttendies.Id ,
            'Email'    => 'contact1@gmail.com'
        },true);
        Contact contact2 = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object> {
            'LastName' => 'Contact 2',
            'AccountId'=> companyWithAttendies.Id ,
            'Email'    => 'contact2@gmail.com'
        },true);
        Contact contact3 = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object> {
            'LastName' => 'Contact 3',
            'AccountId'=> companyWithAttendies.Id ,
            'Email'    => 'contact3@gmail.com'
        },true);
        Contact contact4 = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object> {
            'LastName' => 'Contact 4',
            'AccountId'=> companyWithAttendies.Id ,
            'Email'    => 'contact4@gmail.com'
        },true);
        Case request1 = (Case)TestDataFactory.createSObject('Case', new Map<String,Object> {
            'Subject' => 'Event Booking',
            'Description' => 'Book Spots for Company A1 & their 4 employees',
            'AccountId'   => companyWithAttendies.id,
            'Status'      => 'New'
        },true);
        Case request2 = (Case)TestDataFactory.createSObject('Case', new Map<String,Object> {
            'Subject' => 'Event Booking',
            'Description' => 'Book Spots for Company A1 & their 4 employees',
            'AccountId'   => companyWithAttendies.id,
            'Status'      => 'New'
        },true);
        Case request3 = (Case)TestDataFactory.createSObject('Case', new Map<String,Object> {
            'Subject' => 'Event Booking',
            'Description' => 'Book Spots for Company A1 & their 4 employees',
            'AccountId'   => companyWithAttendies.id,
            'Status'      => 'Closed'
        },true);
        Case request4 = (Case)TestDataFactory.createSObject('Case', new Map<String,Object> {
            'Subject' => 'Event Booking',
            'Description' => 'Book Spots for Company A1 & their 4 employees',
            'AccountId'   => companyWithAttendies.id,
            'Status'      => 'Closed'
        },true);
    }

    @isTest
    private static void caseWithoutAccountTest(){
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
    private static void accountCaseWithoutContactsTest(){
        // Given
        Account company = [SELECT id from Account where name = 'companyWithoutAttendies' limit 1];
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
        result.getErrors()[0].getMessage(), 'the account should have contacts');
    }

    @isTest
    private static void validateContactsWebOriginTest(){
        Account company = [SELECT id, (SELECT id from Contacts) from Account where name = 'companyWithAttendies' limit 1];
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
    private static void validateContactsPhoneOriginTest(){
        // Given
        Account company = [SELECT id, (SELECT id from Contacts) from Account where name = 'companyWithAttendies'  limit 1];
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
    private static void getInfoFromExternalSystemTest(){
        Contact contact1 = [SELECT id, accountId, Name, Email from Contact limit 1];
        Test.startTest(); 
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200));
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
    private static void notifyExternalSystemTest(){
        List<Case> caseList = new List<Case>([Select id, accountId from case where status='Closed' limit 2]);
        List<Contact> contact1 = [SELECT id, accountId, Name, Email, Account.Name  from Contact limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200));
        //CaseTriggerHelper.notifyExternalService(caseMap);
        ExternalSystemService.notifyContactByEmail(contact1);
        update caseList[0];
        Integer l = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(0, l, 'Email should be sent');
    }

    @isTest
    private static void notifyExternalSystemErrorTest(){
        Map<Id,Case> caseList = new Map<Id,Case>([Select id, accountId from case where status='Closed' limit 2]);   
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(205));
        ExternalSystemService.notifyExternalSystem(caseList.keySet());
        Integer l = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(0, l, 'Email shouldn\'t be sent');

    }

}

