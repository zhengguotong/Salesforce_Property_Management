//This trigger is danger, unless you want to  detete all tenant data,
//do not active this trigger
trigger deleteTenant on Tenant__c (after update) { 
    List<Tenant__c> tenants = [Select id from Tenant__c];
    
    integer count = 0;
    
    for(Tenant__c tenant: tenants)
    {
        if(count > 80)
        {
            return;
        }
        else
        {
            delete tenant;
            count++;
        }
    }
}