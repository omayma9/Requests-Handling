/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-01-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class CaseTriggerHandler extends TriggerHandler{
    
    private List<Case> oldCaseList;
    private List<Case> newCaseList;
    private Map<Id, Case> oldCaseMap;
    private Map<Id, Case> newCaseMap;
   
    public CaseTriggerHandler() {
        this.setMaxLoopCount(1);
        oldCaseList = (List<Case>) Trigger.old;
        newCaseList = (List<Case>) Trigger.new;
        oldCaseMap = (Map<Id, Case>) Trigger.oldMap;
        newCaseMap = (Map<Id, Case>) Trigger.newMap;
    }

    protected override void beforeInsert() {
        CaseTriggerHelper.validateAccessibility(newCaseList);
     }
     protected override void beforeUpdate() {
        AccountTriggerHelper.notifyExternalSystem(newCaseMap);
     }


}
