public with sharing class MaintenanceRequestHelper {
    public static void updateWorkOrders(List<Case> cases) {
        List<Id> caseIds = MaintenanceRequestHelper.generateIds(cases);
        List<Work_Part__c> parts = [SELECT Id, Equipment__r.Id, Equipment__r.Maintenance_Cycle__c
                                        FROM Work_Part__c 
                                        WHERE Maintenance_Request__c IN :caseIds]; 
        List<Case> newCases = new List<Case>();
        
        for(Case cs : cases) {
            if (cs.Status == 'Closed') {
                List<Work_Part__c> csParts = MaintenanceRequestHelper.getCsParts(cs, parts);
                Date nextCycle = MaintenanceRequestHelper.getTheNextCycle(csParts);

                Case newCase = new Case(
                    Vehicle__c = cs.Vehicle__c,
                    Equipment__c = cs.Equipment__c,
                    Subject= 'Routine Maintenance',
                    Date_Reported__c = System.today().date(),
                    Type = 'Routine Maintenance',
                    Date_Due__c = nextCycle
                );

                newCases.add(newCase);
            }
        }

        insert newCases;
    }

    public static List<Id> generateIds(List<SObject> objects) {
        List<Id> ids = new List<Id>();
        for(SObject obj : objects) {
            ids.add(obj.Id);
        }
        
        return ids;
    }

    public static List<Work_Part__c> getCsParts(Case cs, List<Work_Part__c> parts) {
        List<Work_Part__c> csParts = new List<Work_Part__c>();
        for (Work_Part__c part : parts) {
            if (part.Maintenance_Request__c == cs.Id) {
                csParts.add(part);
            }
        }

        return csParts;
    }

    public static Date getTheNextCycle(List<Work_Part__c> parts) {
        if (parts.size() > 0) {
            Integer cycle = (Integer) parts[0].Equipment__r.Maintenance_Cycle__c;
            for (Work_Part__c wp : parts) {
                Integer newCycle = (Integer) wp.Equipment__r.Maintenance_Cycle__c;
                if (newCycle < cycle) {
                    cycle = newCycle;
                }
            }

            return System.now().addDays(cycle).date();
        } else {
            return null;
        }
    }
}