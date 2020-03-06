trigger MaintenanceRequest on Case (after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {

        } else if (Trigger.isUpdate) {
            MaintenanceRequestHelper.updateWorkOrders(Trigger.New);            
        }
    } else if (Trigger.isBefore){
        if (Trigger.isInsert) {

        } else if (Trigger.isUpdate) {
            
        }
    }
}