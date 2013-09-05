public class C_RepairHandler extends C_CaseHandler 
{
	public static String OWNER_EMAIL_SUBJECT ='Repair Request';
	public static String ACKNOWLEDGE_EMAIL_SUBJECT ='Acknowlegement of repair request';
	public static String JOB_ORDER_SUBJECT = 'Repair Job Order';
	public static String CONFRIMATION_EMAIL_SUBJECT = 'Comfirmation of repair request';
	
	private Contact creditor; 
	
	public C_RepairHandler(case repair)
	{
		super(repair);
		
		setCreditor();
		if(creditor != null)
		{
			repair.H_Creditor_Mobile__c = creditor.MobilePhone;
		}
	}
	
	/**
	
	**/
	private void setCreditor()
	{
	    List<Contact> creditors = [Select MobilePhone, Name, Email
	                           	   From Contact
	                               Where Id = :repair.ContactId];
	    if(creditors.size() > 0)
	    {
	    	creditor = creditors[0];
	    }
	    else 
	    {
	    	creditor = null;
	    }
	}
	
	public void handlerRepair()
	{
	    getApproval();
	    proceedJob();
	}
	
	
	/**
	When this repair case is equal to approval, owner email is not empty 
	and Estime cost is not empty, then  send a repair request to owner and
	log email body under this repair case activity history.
	
	When tenant Email is not empty, then send an acknowledgement of repair
	request to tenant and log sms body under this repair case activity history
	
	When Owner's mobile is not empty, then send a repair request sms to owner's mobile
	and log sms body under this repair case activity history
	
	When tenant's mobile is not empty, then send a ackwoledgement of repair request to 
	tenant's mobile and log sms body under this repair case activity history
	**/
	private void getApproval()
	{
		if(repair.Repair_Status__c == C_Constant.APPROVAl)
		{
			if(owner != null && repair.H_Owner_Email__c != null && repair.Estimate_Cost__c != null)
			{
				 if(C_Utility.gentAttachments(repair.Id).size() == 0)
				 {
				 	C_Email.sendSingleAttachemetEmail(new String[]{repair.H_Owner_Email__c}, 
				 	                                  propertyAddress + OWNER_EMAIL_SUBJECT , 
				 	                                  ownerEmailBody(), null);
				 }
				 else 
				 {
				 	C_Email.sendSingleAttachemetEmail(new String[]{repair.H_Owner_Email__c}, 
				 	                                  propertyAddress + OWNER_EMAIL_SUBJECT , 
				 	                                  ownerEmailBody(),
				 	                                  C_Utility.gentAttachments(repair.Id));
				 }
				 
				 C_Utility.logActivity(propertyAddress +OWNER_EMAIL_SUBJECT, 
				 								ownerEmailBody(), repair.id);
				 //update get approval date in the system
				 repair.H_Get_Approval_Date__c = DateTime.now();
					
				 //Send acknowlegement of repair request email to tenant
				 //(This is done by workflow) and log email detail under
				 // this repair activity history
				 if(repair.H_Tenant_Email__c != null)
				 {
				 	C_Email.sendPainTextEmail(new String[]{repair.H_Tenant_Email__c}, 
				 							ACKNOWLEDGE_EMAIL_SUBJECT,
				 							acknowlegementEmailBody());
				    C_Utility.logActivity(ACKNOWLEDGE_EMAIL_SUBJECT, acknowlegementEmailBody(), repair.id);
				 }
			   
			}
			
			//When owner's mobile phone is not empty, then send repair request to owner by 
			//SMS, then log activity under this repair case
			if(owner != null && owner.Mobile_Phone__c != null && repair.Estimate_Cost__c != null)
			{
				/*send repair request to owner by sms and log sms body under this 
				case activity history */
				C_SMS.sendSms(owner.Mobile_Phone__c, owner.Name, ownerSmsBody());
				C_Utility.logActivity(OWNER_EMAIL_SUBJECT, ownersmsBody(), repair.id);
				
				//send acknowledgement of repair request to tenant by sms and log sms body
				//under this case activity history
				if(tenant != null && tenant.Mobile_Phone__c != null)
				{
					C_SMS.sendSms(tenant.Mobile_Phone__c, tenant.Name, acknowlegementSMSBody());
					C_Utility.logActivity(ACKNOWLEDGE_EMAIL_SUBJECT + ' By SMS',acknowlegementSMSBody(), repair.id);
				}
			}
		}
	}
	
	/**
	when repair status is equal to proceed job order
	sent job order to creditor and inform tenant 
	about the job order status 
	**/
	private void proceedJob()
	{
		if(repair.Repair_Status__c == C_Constant.PROCEED_JOB)
		{
			Boolean isProceed = false;
		    //if creditor is not empty and creditor has email address
		    //then sent job order to creditor by email
		    //and log email body under this repair case activity history 
			if(creditor != null && creditor.Email != null)
			{
				if(C_Utility.gentAttachments(repair.Id).size() == 0)
				 {
				 	C_Email.sendSingleAttachemetEmail(new String[]{creditor.Email}, 
				 	                                  propertyAddress + JOB_ORDER_SUBJECT , 
				 	                                 jobOrderEmail(), null);
				 }
				 else 
				 {
				 	C_Email.sendSingleAttachemetEmail(new String[]{creditor.Email}, 
				 	                                  propertyAddress + JOB_ORDER_SUBJECT, 
				 	                                  jobOrderEmail(),
				 	                                  C_Utility.gentAttachments(repair.Id));
				 }
				C_Utility.logActivity(JOB_ORDER_SUBJECT, jobOrderEmail(), repair.id);
				isProceed = true;
			}
			//if creditor is not empty and creditor has mobile, then
			//send job order to reditor to sms and log sms body under 
			//this repair case activity history 
			if(creditor != null && repair.H_Creditor_Mobile__c != null)
			{
				C_SMS.sendSms(repair.H_Creditor_Mobile__c, creditor.Name, jobOrderSMS());
				C_Utility.logActivity(JOB_ORDER_SUBJECT + ' by SMS', jobOrderSMS(),repair.id);
				isProceed = true;
			}
			
			 //if isProceed is ture and tenant has email address
		    //then sent job order to creditor by email(this done by workflow)
		    //and log email body under this repair case activity history 
			if(isProceed && repair.H_Tenant_Email__c != null)
			{
				C_Utility.logActivity(CONFRIMATION_EMAIL_SUBJECT, confirmationEmailBody(), repair.id);
			}
			
			if(isProceed && repair.H_Tenant_Mobile__c != null)
			{
				C_SMS.sendSms(repair.H_Tenant_Mobile__c, repair.H_Tenant_Mobile__c, confirmationSMSBody());
				C_Utility.logActivity(CONFRIMATION_EMAIL_SUBJECT + 'By SMS', confirmationSMSBody(), repair.id);
			}
		}
	}
	
	/**
	@return email body to owner 
	**/
	private String ownerEmailBody()
	{
	 	return 'Dear Owner,\n\n '
                 +'This is to advise you that tenant of above mentioned unit has contacted '
                 + 'our office with a request for maintenance.'
                 +'\nProblem: ' + repair.Description
                 +'\nEstimated Cost: $' + repair.Estimate_Cost__c
                 +'\n\nIt is important that your property is well maintained to optimise '
                 + 'long-term capital growth and to ensure that the property attracts '
                 + 'quality tenants.' 
                 +'\n\nAs an Agent we have a legal obligation to you as the owner and '
                 +'to the tenant to ensure that the property is well maintained and '
                 +'that it provides a safe and enjoyable environment. '
                 +'\n\nWe understand you have busy schedule, if we do not receive any'
                 +' further instruction from your within 48 hours, we will carry on '
                 + 'the job order. If repairs cost exceeds the estimated cost, we will '
                 + 'contact you for further instruction.'
                 + '\n\nThank you for your cooperation in this matter.'
                 + '\n\nAssuring you of our very best service and attention at all times.'
                 +'\n\nKind Regards'
                 +'\nExcelsior Realty Pty Ltd';
	}
	
	/**
	@return repair request sms body to owner
	**/
	private String ownerSmsBody()
	{
		return 'Dear Owner, ' + '  re:( '
		       + propertyAddress + 'repair request) '
		       + 'This is to advise you that tenant of above mentioned unit has contacted '
               + 'our office with a request for maintenance.'
               +' Problem: ' + repair.Subject
               +' Estimated Cost: ' + repair.Estimate_Cost__c
               +' We understand you have busy schedule, if we do not receive any'
               +' further instruction from your within 48 hours, we will carry on '
               + 'the job order. If repairs cost exceeds the estimated cost, we will '
               + 'contact you for further instruction.'
               + 'Assuring you of our very best service and attention at all times. '
               +'Kind Regards'
               +' Excelsior Realty Pty Ltd';
	}
	
	/**
	@return acknolegement of repair request email body 
	**/
	private String acknowlegementEmailBody()
	{
		return 'Dear Tenant,\n\n'
		       +'This is to advise you we have received your repairs request and job order has been '
		       + 'sent to owner for approval today. We will reply you within 48 hours after we obtain '
		       +'instruction from owner . '
		       +'\n\nPlease feel free to contact our office if you have anything unsure. '
		       + '\n\nThank you for your cooperation in this matter.\n'
		       + 'Kind Regards\n\n'
		       + 'Excelsior Realty';        
	}
	
	/**
	@return acknowlegement of repair request sms body 
	**/
	private String acknowlegementSMSBody()
	{
		return + 'Dear Tenant,'
		       + 're:(acknowledgement of ' + propertyAddress +'repair request)'
		       +'This is to advise you we have received your repairs request and job order has been '
		       + 'sent to owner for approval today. We will reply you within 48 hours after we obtain '
		       +'instruction from owner . '
		       +'Please feel free to contact our office if you have anything unsure. '
		       + 'Kind Regards'
		       + ' Excelsior Realty';      
	}
	
	/**
	@return job order email body 
	**/
	private String jobOrderEmail()
	{
		try
		{
			return 'Property Address: '+ propertyAddress
		       + '\n\nTenant Name: ' + tenant.Name
		       + '\n\nMobile Phone:' + repair.H_Tenant_Mobile__c
		       +'\n\nContractor Use: ' + creditor.Name
		       + '\n\nDate: ' + Datetime.now().format('dd/MM/yyyy')
		       +'\n\nProblem: ' + repair.Description
		       +'\n\nBudget: ' +  repair.Estimate_Cost__c
		       +'\n\nPlease proceed this job order within the budget, '
		       + 'otherwise inform us first.\n'
		       + '\n\nKind Regards' 
               + '\n\nExcelsior Realty Pty Ltd'; 
		}
		catch (Exception e)
		{
			system.debug('ERROR: ' + e);
			return 'There is not creditor found under this case';
		}
	}
	
	/**
	@return job order sms body
	**/
	private string jobOrderSMS()
	{
		try 
		{
			return +'Property Address: '+ propertyAddress
		       + 'Tenant Name: ' + tenant.Name
		       + ' Mobile Phone:' + repair.H_Tenant_Mobile__c
		       +' Contractor Use: ' + creditor.Name
		       + ' Date: ' + Datetime.now().format('dd/MM/yyyy')
		       +' Problem: ' + repair.Subject 
		       +' Budget: ' +  repair.Estimate_Cost__c
		       + ' Kind Regards' 
               + ' Excelsior Realty Pty Ltd'; 
		}
		catch (Exception e)
		{
			system.debug('ERROR: ' + e);
			return 'There is not creditor found under this case';
		}
		
	}
	
	/**
	return confirmation of repair request email body 
	**/
	private String confirmationEmailBody()
	{
		try
		{
			return 'Subject: '+propertyAddress + ' Job Order' 
		       +'\nTenant Email: ' + repair.H_Tenant_Email__c
		       +'\nTime: ' + DateTime.now().format('E dd/MM/yyyy hh:mm a') +'\n'
		       +'Body:\n'
		       + 'Dear Tenant, ' 
		       +'\n\nThis is advise you that we have received your repair request '
		       +'and Job order has been approved by the owner and it has been sent '
		       + 'to ' + creditor.Name + ' for action today. ' 
               +'\n\nIf due to busy work schedule,  ' + creditor.Name + ' have not '
               + 'contacted you within 48 hours. Please feel free to contact them '
               + 'directly on ' +  repair.H_Creditor_Mobile__c + ' to organise access.' 
               +'\n\nPlease feel free to contact our office if you have anything unsure. ' 
               +'\n\nThank you for your cooperation in this matter.'
               +'\n\nKind Regards'
               +'\nExcelsior Realty Pty Ltd';
		}
		catch (Exception e)
		{
			system.debug('ERROR: ' + e);
			return 'There is not creditor found under this case';
		}
	}
	
	/**
	@return confirmation of repair request sms body 
	**/
	private String confirmationSMSBody()
	{
		try
		{
			return 'Dear Tenant, ' 
			   + 're:(confirmation of ' + propertyAddress +'repair request)'
		       +'This is advise you that we have received your repair request '
		       +'and Job order has been approved by the owner and it has been sent '
		       + 'to ' + creditor.Name + 'for action today. ' 
               +'If due to busy work schedule,  ' + creditor.Name + ' have not '
               + 'contacted you within 48 hours. Please feel free to contact them '
               + 'directly on ' +  repair.H_Creditor_Mobile__c + ' to organise access.' 
               +'Kind Regards'
               +' Excelsior Realty Pty Ltd';
		}
		catch (Exception e)
		{
			system.debug('ERROR: ' + e);
			return 'There is not creditor found under this case';
		}
	}
	
	
	public Contact getCreditor()
	{
		return creditor;
	}
	
	@isTest 
	public static void getterTest()
	{
		test.startTest();
		//create new test owner 
    	Account testOwner = new Account(Name = 'Test Owner',
    	                                Email__c = 'dev@owner.com',
    	                                Mobile_Phone__c  = '0458888888'); 
        insert testOwner;
        
        Contact testCreditor = new Contact(LastName = 'Test Creditor',
                                           MobilePhone = '0411223344');
        
        //create new test property 
        Property__c testProperty = new Property__c(Name = 'Test Property',
                                                   Property_Owner__c = testOwner.Id,
                                                   Unit_Number__c = '6678',
                                                   Building_Name__c = 'Test Building Name',
                                                   Street_Number__c ='Test Street Name',
                                                   Suburn__c = 'Test Suburn',
                                                   State__c = 'NSW',
                                                   Post_Code__c ='2000'
                                                   );
       insert testProperty;
       
       case testRepair = new case(Property__c = testProperty.id);
       insert testRepair;
       
       /*
       test trigger
       */
       testRepair.Type = C_Constant.REPAIR;
       testRepair.ContactId = testCreditor.id;
       update testRepair;
       
       Tenant__c testTenant = new Tenant__c(Name = 'Test Tenant',
                                            Property__c = testProperty.Id,
                                            Tenant_Status__c = C_Constant.ACTIVE,
                                            Email__c = 'dev@tenant.com.au',
                                            Mobile_Phone__c = '0412345678');
       insert testTenant;
       
       C_RepairHandler handler = new C_RepairHandler(testRepair);
       
       /** Test setCreditor **/
       handler.setCreditor();
     
       /** Test ownerEmailBody **/
       string body = handler.ownerEmailBody();
       system.assertEquals(true, body.contains('within 48 hours, we will carry on'));
       
        /*Test acknowledgementEmailBody */
       body = handler.acknowlegementEmailBody();
       system.assertEquals(true, body.contains('instruction from owner'));
       
       /*Test acknowledgementSMSBody */
       body = handler.acknowlegementSMSBody();
       system.assertEquals(true, body.contains('6678 Test Building Name Test Street Name Test Suburn NSW 2000'));
       
       /** Test jobOrderEmail */
       system.assertEquals('There is not creditor found under this case',handler.jobOrderEmail());
       
       /** Test jobOrderSMS */
       system.assertEquals('There is not creditor found under this case',handler.jobOrderSMS());
       
       /** Test confirmationEmailBody */
       system.assertEquals('There is not creditor found under this case',handler.confirmationEmailBody());
       
       /** Test confirmationSMSBody */
       system.assertEquals('There is not creditor found under this case',handler.confirmationSMSBody());
       
       test.stopTest(); 
	}
	
	@isTest(seeAllData=true) 
	public static void getApprovalTesting()
	{
		test.startTest();
		//create new test owner 
    	Account testOwner = new Account(Name = 'Test Owner',
    	                                Email__c = 'dev@owner.com',
    	                                Mobile_Phone__c  = '0458888888'); 
        insert testOwner;
        
        //create new test property 
        Property__c testProperty = new Property__c(Name = 'Test Property',
                                                   Property_Owner__c = testOwner.Id,
                                                   Unit_Number__c = '6678',
                                                   Building_Name__c = 'Test Building Name',
                                                   Street_Number__c ='Test Street Name',
                                                   Suburn__c = 'Test Suburn',
                                                   State__c = 'NSW',
                                                   Post_Code__c ='2000'
                                                   );
       insert testProperty;
       
       Tenant__c testTenant = new Tenant__c(Name = 'Test Tenant',
                                            Property__c = testProperty.Id,
                                            Tenant_Status__c = C_Constant.ACTIVE,
                                            Email__c = 'dev@tenant.com.au',
                                            Mobile_Phone__c = '0412345678');
       insert testTenant;
       
       case testRepair = new case(Property__c = testProperty.id,
                                  Type = C_Constant.REPAIR,
                                  Estimate_Cost__c = 200.00,
                                  Repair_Status__c = C_Constant.APPROVAl);
       insert testRepair;
       
       C_RepairHandler handler = new C_RepairHandler(testRepair);
       handler.getApproval();
       
       integer activityCount = [Select count() From Task
                               Where WhatId = :testRepair.id];
       system.assertEquals(4, activityCount);
       test.stopTest();     
	}
  
  @isTest(seeAllData=true) 
  static void proceedJobTest()
  {
  		test.startTest();
		//create new test owner 
    	Account testOwner = new Account(Name = 'Test Owner',
    	                                Email__c = 'dev@owner.com',
    	                                Mobile_Phone__c  = '0458888888'); 
        insert testOwner;
        
        //create new test property 
        Property__c testProperty = new Property__c(Name = 'Test Property',
                                                   Property_Owner__c = testOwner.Id,
                                                   Unit_Number__c = '6678',
                                                   Building_Name__c = 'Test Building Name',
                                                   Street_Number__c ='Test Street Name',
                                                   Suburn__c = 'Test Suburn',
                                                   State__c = 'NSW',
                                                   Post_Code__c ='2000'
                                                   );
       insert testProperty;
       
       Contact testCreditor = new Contact(LastName = 'Test Creditor',
                                          MobilePhone = '0405795363',
                                          Email = 'dev@creditor.com.au');
       insert testCreditor;
       
       Tenant__c testTenant = new Tenant__c(Name = 'Test Tenant',
                                            Property__c = testProperty.Id,
                                            Tenant_Status__c = C_Constant.ACTIVE,
                                            Email__c = 'dev@tenant.com.au',
                                            Mobile_Phone__c = '0412345678');
       insert testTenant;
       
       case testRepair = new case(Property__c = testProperty.id,
       							  ContactId = testCreditor.id,
                                  Type = C_Constant.REPAIR,
                                  Estimate_Cost__c = 200.00,
                                  Repair_Status__c = C_Constant.PROCEED_JOB);
       insert testRepair;
       
       C_RepairHandler handler = new C_RepairHandler(testRepair);
       handler.setCreditor();
       system.assertEquals('dev@creditor.com.au', handler.getCreditor().Email);
       
       handler.proceedJob();
       
       integer activityCount = [Select count() From Task
                               Where WhatId = :testRepair.id];
       system.assertEquals(4, activityCount);
       
       test.stopTest();     
  }
}