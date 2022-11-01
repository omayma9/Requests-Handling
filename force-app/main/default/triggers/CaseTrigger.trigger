/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-01-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger CaseTrigger on Case (
    before insert
    , before update
    , before delete
    , after insert
    , after update
    , after delete
    , after undelete) {
        new CaseTriggerHandler().run();
    
}