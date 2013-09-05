trigger T_BU_Scheduler on Tenant__c (after insert)    
{
	for (Tenant__c tenant: trigger.new)
	{
		/*String jobId = System.schedule('Update Tenant Status',
        '0 0 9 ? * MON', 
         new TenantStatusScheduler());*/
		
	}
}