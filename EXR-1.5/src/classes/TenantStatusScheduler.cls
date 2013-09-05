global class TenantStatusScheduler implements Schedulable  
{

   	global void execute(SchedulableContext ctx) 
   	{
   		updateTenantStatus();
   	}
   	
   	private void updateTenantStatus()
   	{
   		List<Tenant__c> tenants = [Select Tenant_Status__c
       						      From Tenant__c
       						      Where Vacating_Status__c= :C_Constant.COMPLETED
       						      And Vacating_Date__c < :Date.Today()
       						      And Market_Research_Price__c != null
       						      And Arrears__c != null];
       						      
       if(tenants.size() > 0)
       {
       		for(Tenant__c tenant: tenants)
       		{
       			tenant.Tenant_Status__c = C_Constant.Inactive;
       			update tenant;
       		}
       }
   	}	
}