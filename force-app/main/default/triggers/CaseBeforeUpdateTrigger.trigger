/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-31-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger CaseBeforeUpdateTrigger on Case (before update, after update) {

    Boolean requestSentToExternalSystem = false;
    Integer i=0;
    
    Case request = Trigger.new[0];

    Case r = [SELECT AccountId, Status FROM Case where id=:request.ID];
    if(r.Status == 'Closed'){
        ExternalSystemService service = new ExternalSystemService();
        service.registerAttendees(r);
    }
}