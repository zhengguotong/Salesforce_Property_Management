trigger T_Tenant on Tenant__c (before update) 
{
	for(Tenant__c tenant: Trigger.new)
	{   
		  /**Tenant Vacate **/
		 //if the tenant arrear__c and Vacating Date is null 
		 //then proceed vacating processs
		if(  tenant.Vacating_Date__c != null) 
		{
			C_TenantVacatingHandler vacate= new C_TenantVacatingHandler(tenant);
			
			//when vacating status is equal to 'Inform Tenant'
			//then send vacate checklist to tenant(this done through 
			// work flow),  create vacate event in calendar if 
			//not create yer and inform tenant by sms
			if(tenant.Arrears__c != null && tenant.Vacating_Status__c == C_Constant.INFORM_TENANT)
			{
				vacate.informTenant();
			}else if(tenant.Market_Research_Price__c != null 
			   && tenant.Vacating_Status__c == C_Constant.INFORM_OWNER)
			{
				vacate.informOwner();
			}else if(tenant.Arrears__c != null && tenant.Market_Research_Price__c != null 
			   && tenant.Vacating_Status__c == C_Constant.INFORM_BOTH)
		    {
		    	vacate.informTenant();
		    	vacate.informOwner();
		    }
		    else if(tenant.Market_Research_Price__c != null 
			   && tenant.Vacating_Status__c == C_Constant.COMPLETED
			   && tenant.Vacating_Date__c < Date.today())
			{
				
			}
		}
		else if(tenant.Vacating_Status__c == C_Constant.SEND_VACATE_FORM)
		{
			C_TenantVacatingHandler.logFormActitivity(tenant);
		}
		 
		 /**rent increase**/
		//if rent increase check box is ticked, rent_period is selected
		//pay to date is entered and new rent is enter 
		if(tenant.Rent_Increase_Status__c != null && tenant.Rent_Period__c != null 
		     &&  tenant.Pay_to_Date__c != null && tenant.New_Rent__c != null)
		{   
			 C_RentIncreaseHandler rentIncrease = new C_RentIncreaseHandler(tenant);
		    //if the rent increase status is procossing, then send 
		    //notification email and sms to tenant and bcc owner 
		    //change status to completed 
		    //and clear the get approval date text field
			if(tenant.Rent_Increase_Status__c == C_Constant.PROCESSING)
			{
				 
				rentIncrease.informTenant(); 
				tenant.Rent_Increase_Status__c = C_Constant.COMPLETED;
				tenant.Get_Approval_Date__c = null;
			}
			//if the rent increase status is 'get approval' 
			//then send rent increase approval letter to owner
			//change status to waiting 
			//and record the get approval date to today
			else if(tenant.Rent_Increase_Status__c == C_Constant.GET_APPROVAL)
			{
				rentIncrease.informOwner();
			    tenant.Rent_Increase_Status__c = C_Constant.WAITING;
			    tenant.Get_Approval_Date__c = DateTime.now();
			}
		}
	}
}