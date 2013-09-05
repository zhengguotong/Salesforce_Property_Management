public with sharing class C_MessageHandler 
{
	public final static String EMAIL = 'Email';
	public final static String SMS ='SMS';
	//Receipt Group 
	public final static String OWNER = 'Owners';
	public final static String TENANT = 'Tenants';
	public final static String CONTACT = 'Contacts';
	public final static String SALES_LEAD = 'Sales Leads';
	public final static String LEASE_LEAD = 'Lease Leads';
	//message status
	public final static String NOT_STARTED = 'Not Started';
	public final static String SEND = 'Send';

    private Message__c message;
    
    public C_MessageHandler(Message__c message)
    {
    	this.message = message;
    }
    
    /**
       sent mass email and sms according to 
       user option 
    **/
    public void processMessage()
    {   
    	//if email message method is selected then send
    	//emails to the selected receipt groups
    	if( message.Status__c == SEND &&  message.Message_Type__c.contains(EMAIL))
    	{
    		 processEmail();
    	}
    	 
    	//if sms message method is selected then send 
    	//sms to the selected receipt groups  
    	if( message.Status__c == SEND && message.Message_Type__c.contains(SMS))
    	{
    		 processSMS();
    	}
    }   
    
    /**
       send mass email to selected 
       receipt groups
    **/
    private void processEmail()
    {
    	if(message.Email_Body__c != null)
    	{
    		//if the receipt include owner,
    		//then send mass email to all
    		//owners in the salesfore 
    		if(message.Receipt__c.contains(OWNER))
    		{   
    			List<String[]> ownerEmails = getOwnerEmails(); 
    			sendEmail(ownerEmails);
    		}
    		
    		//if the receipt include tenant,
    		//then send mass email to all
    		//tenants in the salesforce 
    		if(message.Receipt__c.contains(TENANT))
    		{   
    			List<String[]> tenantEmails = getTenantEmails(); 
    			sendEmail(tenantEmails);
    		}
    		
    		//if the receipt include tenant,
    		//then send mass email to all
    		//tenants in the salesfore 
    		if(message.Receipt__c.contains(CONTACT))
    		{   
    			List<String[]> contactEmails = getContactEmails(); 
    			sendEmail(contactEmails);
    		}
    		
    		//if the receipt include sales lead,
    		//then send mass email to all
    		//sales leads in the salesfore 
    		if(message.Receipt__c.contains(SALES_LEAD))
    		{   
    			List<String[]> salesEmails = getSalesEmails(); 
    			sendEmail(salesEmails);
    		}
    		
    		//if the receipt include leads lead,
    		//then send mass email to all
    		//sales leads in the salesfore 
    		if(message.Receipt__c.contains(LEASE_LEAD))
    		{   
    			List<String[]> leaseEmails = getleaseEmails(); 
    			sendEmail(leaseEmails);
    		}
    		  
    	}
    }
    
  
    private void sendEmail(List<String[]> toAddress)
    {
    	//get list of attachement under this message
		 List<Attachment> attachments = [Select Name, Body 
		 									From Attachment 
		 									Where ParentId =: message.id
		 	                              ];
		  
		  //when there is attachment under this case then attachment 
		  //this email with these attachments, otherwise just send 
		  //normal mass email 
          if (attachments != null && attachments.size() > 0)
          {
         	 Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
    	 	 efa.setFileName(attachments[0].Name);
         	 efa.setBody(attachments[0].Body); 
         	 C_Email.sendBccMassEmail(toAddress, message.Name, message.Email_Body__c, efa);
          }
          else 
          {
         	 C_Email.sendBccMassEmail(toAddress, message.Name, message.Email_Body__c,null);
          }
    	
    	   C_Utility.logActivity(message.Name, getDescription(toAddress), message.id);
    }
    
   
    
    /**
    Get acitvity history discription
    **/
    private String getDescription(List<String[]> toAddress)
    {
    	String description ='Subject: ' + message.Name
    	       +'\nDate:' + DateTime.now()
    	       +'\nTotal Message Send: ' + toAddress.size() 
    	       +'\nReceipt: ';
    	 
    	for(String[] address: toAddress)
    	{
    		description += address[0] + '\t';
    	}   
    	  
    	return description;
    }
    
 
    
    /**
    Get all owner emails which notemail marketing 
    is false
    **/
    private List<String[]> getOwnerEmails()
    {
    	List<String[]> ownerEmails = new List<String[]>();
    	
    	if(message.Building_Name__c == null && message.Post_Code__c == null)
        {
        	for(Account account: [Select Email__c, Id From Account 
    	                            Where Email__c != null 
    	                            And   Email_Marketing__c = true])
	    	{
	    		ownerEmails.add(new String[]{account.Email__c});
	    	}
        }
        else if(message.Building_Name__c != null && message.Post_Code__c == null)
        {
        	for(Account account: [Select a.Email__c, a.Id From Account a
    	                            Where a.Email__c != null 
    	                            And   a.Id In (Select p.Property_Owner__c 
    	                            			   From Property__c p
    	                            			   Where p.Building_Name__c = :message.Building_Name__c)])
	    	{
	    		ownerEmails.add(new String[]{account.Email__c});
	    	}
        }
        else if(message.Building_Name__c == null && message.Post_Code__c != null)
        {
        	for(Account account: [Select a.Email__c, a.Id From Account a
    	                            Where a.Email__c != null 
    	                            And   a.Id In (Select p.Property_Owner__c 
    	                            			   From Property__c p
    	                            			   Where p.Post_Code__c = :message.Post_Code__c)])
	    	{
	    		ownerEmails.add(new String[]{account.Email__c});
	    	}
        }
        else
        {
        	for(Account account: [Select a.Email__c, a.Id From Account a
    	                            Where a.Email__c != null 
    	                            And   a.Id In (Select p.Property_Owner__c 
    	                            			   From Property__c p
    	                            			   Where p.Post_Code__c = :message.Post_Code__c
    	                            			   And p.Building_Name__c = :message.Building_Name__c)])
	    	{
	    		ownerEmails.add(new String[]{account.Email__c});
	    	}
        }
    	return ownerEmails;
    }
    
     /**
       Get all tenant email which NotEmailMaketing
       is false
    **/
    private List<String[]> getTenantEmails()
    {
    	List<String[]> tenantEmails = new List<String[]>();
    	
    	//When building name and post code field is empty, 
    	//then add all tenant who email is not empty , status is active 
    	//and allow email marketing to the list
    	if (message.Building_Name__c == null && message.Post_Code__c == null)
    	{
    		for(Tenant__c tenants : [Select Email__c, Id From Tenant__c 
    	                        	 Where Email__c != null
    	                             And Tenant_Status__c = :C_CONSTANT.ACTIVE
    	                             And   Email_Marketing__c = true])
	    	{
	    		tenantEmails.add(new String[]{tenants.Email__c});
	    	}
	    	
    	}
    	//When building name is not empty and the post code is empty, 
    	//then add tenant whose property's building name is equal to 
    	//building name to the list
    	else if (message.Building_Name__c != null && message.Post_Code__c == null)
    	{
    		for(Tenant__c tenants : [Select t.Email__c, t.Id 
									 From Tenant__c t
									 Where Email__c != null 
									 And  Email_Marketing__c = true 
									 And Tenant_Status__c = :C_CONSTANT.ACTIVE
									 And t.Property__c IN (Select p.id 
                                     					   From Property__c p
				   										   Where p.Building_Name__c = :message.Building_Name__c)])
	    	{
	    		tenantEmails.add(new String[]{tenants.Email__c});
	    	}
    	}
    	//When post code is not empty and building name is empty
    	//add tenant to list according to its property post code
    	else if(message.Post_Code__c != null && message.Building_Name__c == null)
    	{
    		for(Tenant__c tenants : [Select t.Email__c , t.id
									 From Tenant__c t
									 Where Email__c != null 
									 And Tenant_Status__c = :C_CONSTANT.ACTIVE
									 And t.Property__c IN (Select p.id 
                                     					   From Property__c p
				   										   Where p.Post_Code__c = :message.Post_Code__c)])
	    	{
	    		tenantEmails.add(new String[]{tenants.Email__c});
	    	}
    	}
    	//otherwise add tenant to the list according to its property 
    	//building name and post code
    	else
    	{
    		for(Tenant__c tenants : [Select t.Email__c, t.id 
									 From Tenant__c t
									 Where Email__c != null 
									 And Tenant_Status__c = :C_CONSTANT.ACTIVE
									 And t.Property__c IN (Select p.id 
                                     					   From Property__c p
				   										   Where p.Post_Code__c = :message.Post_Code__c
				   										   And p.Building_Name__c = :message.Building_Name__c)])
	    	{
	    		tenantEmails.add(new String[]{tenants.Email__c});
	    	}
    	}
   
    	return tenantEmails;
    }
    
     /**
     get all contact emails where NOTEMAIL Marketing is 
     false
    **/
    private List<String[]> getContactEmails()
    {
    	List<String[]> contactEmails = new List<String[]>();
    	
    	if (message.From_Date_Time__c == null && message.To_Date_Time__c == null)
    	{
    		for(Contact contacts: [Select Email, Id From Contact
    	                        Where  Email != null 
    	                        And    Email_Marketing__c = true])
	    	{
	    		contactEmails.add(new String[]{contacts.Email});
	    	}
    	}
    	//when from date time and to date time is not enpty
    	//then select contact within this time range
    	else
    	{
    		for(Contact contacts : [Select Email From Contact
    	                            Where  Email != null 
    	                            And    Email_Marketing__c = true
    	                            And    CreatedDate > :message.From_Date_Time__c
    	                            And    CreatedDate < :message.To_Date_Time__c
    	                        ])
	    	{
	    		contactEmails.add(new String[]{contacts.Email});
	    	}
    	}
    	
    	return contactEmails;
    }
    
     /**
     Get all lead email where lead type is Buying and 
     NotMassMarketing is false
    **/
    private List<String[]> getSalesEmails()
    {
    	List<String[]> salesEmails = new List<String[]>();
    	
    	if(message.From_Date_Time__c == null && message.To_Date_Time__c == null)
    	{
    		for(Lead sales : [Select Email 
    		                  From Lead
    	                      Where Email != null 
    	                      And Type__c = :C_Constant.BUYING
    	                      And Email_Marketing__c = true
    	                    ])
	    	{
	    		salesEmails.add(new String[]{sales.Email}); 
	    	}
    	}
    	//when the from date time and to date time field is not empty
    	//Then select lead according to this time range
    	else 
    	{
    		for(Lead sales : [Select Email From Lead
    	                  Where Email != null 
    	                  And Type__c = :C_Constant.BUYING
    	                  And Email_Marketing__c = true
    	                  And    CreatedDate > :message.From_Date_Time__c
    	                  And    CreatedDate < :message.To_Date_Time__c
    	                  ])
	    	{
	    		salesEmails.add(new String[]{sales.Email}); 
	    	}
    	}
    	
    	return salesEmails;
    }
    
    /**
     Get all lead email where lead type is Buying and 
     NotMassMarketing is false
    **/
    private List<String[]> getLeaseEmails()
    {
    	List<String[]> leaseEmails = new List<String[]>();
    	
    	if (message.From_Date_Time__c == null && message.To_Date_Time__c == null)
    	{
    		for(Lead lease : [Select Email From Lead
    	                  Where Email != null 
    	                  And Type__c = :C_Constant.RENTING
    	                  And  Email_Marketing__c = true])
	    	{
	    		leaseEmails.add(new String[]{lease.Email});
	    	}
    	}
    	//when the from date time to date time is not null, then 
    	//select lead according to this time range
    	else 
    	{
    		for(Lead lease : [Select Email From Lead
    	                  Where Email != null 
    	                  And Type__c = :C_Constant.RENTING
    	                  And  Email_Marketing__c = true
    	                  And    CreatedDate > :message.From_Date_Time__c
    	                  And    CreatedDate < :message.To_Date_Time__c
    	                  ])
	    	{
	    		leaseEmails.add(new String[]{lease.Email});
	    	}
    	}
    	
    	return leaseEmails;
    }
    
    
    private void processSMS()
    {
    	if(message.SMS_Body__c != null)
    	{
    		 if(message.Receipt__c.contains(OWNER))
	    	{
	    		List<String[]> ownerMobileNumbers = getOwnerMobileNumbers();
	    		C_SMS.sentBulkSMS(ownerMobileNumbers, message.SMS_Body__c);
	    		C_Utility.logActivity(message.Name, getDescription(ownerMobileNumbers),message.id);
	    	}
	    	
	    	 if(message.Receipt__c.contains(TENANT))
	    	{
	    		List<String[]> tenantMobileNumbers = getTenantMobileNumbers();
	    		C_SMS.sentBulkSMS(tenantMobileNumbers, message.SMS_Body__c);
	    		C_Utility.logActivity(message.Name, getDescription(tenantMobileNumbers),message.id);
	    	}
	    	
	    	if(message.Receipt__c.contains(CONTACT))
	    	{
	    		List<String[]> contactMobileNumbers = getContactMobileNumbers();
	    		C_SMS.sentBulkSMS(contactMobileNumbers, message.SMS_Body__c);
	    		C_Utility.logActivity(message.Name, getDescription(contactMobileNumbers),message.id);
	    	}
	    	
	    	if(message.Receipt__c.contains(SALES_LEAD))
	    	{
	    		List<String[]> salesMobileNumbers = getSalesMobileNumbers();
	    		C_SMS.sentBulkSMS(salesMobileNumbers, message.SMS_Body__c);
	    		C_Utility.logActivity(message.Name, getDescription(salesMobileNumbers),message.id);
	    	}
	    	
	    	if(message.Receipt__c.contains(LEASE_LEAD))
	    	{
	    		List<String[]> leaseMobileNumbers = getLeaseMobileNumbers();
	    		C_SMS.sentBulkSMS(leaseMobileNumbers, message.SMS_Body__c);
	    		C_Utility.logActivity(message.Name, getDescription(leaseMobileNumbers),message.id);
	    	}
    	}
    }
    
    /**
    Get all owner mobile
    **/
    private List<String[]> getOwnerMobileNumbers()
    {
    	List<String[]> ownerMobileNumbers = new List<String[]>();
    	
    	if(message.Building_Name__c == null && message.Post_Code__c == null)
    	{
    		for(Account account : [Select Mobile_Phone__c, Id 
    								From   Account 
    	                            Where  Mobile_Phone__c != null 
    	                            And    Email_Marketing__c = true])
	    	{
	    		ownerMobileNumbers.add(new String[]{account.Mobile_Phone__c});
	    	}
    	}
    	else if(message.Building_Name__c != null && message.Post_Code__c == null)
        {
        	for(Account account: [Select a.Mobile_Phone__c, a.Id From Account a
    	                            Where a.Mobile_Phone__c != null 
    	                            And   a.Id In (Select p.Property_Owner__c 
    	                            			   From Property__c p
    	                            			   Where p.Building_Name__c = :message.Building_Name__c)])
	    	{
	    		ownerMobileNumbers.add(new String[]{account.Mobile_Phone__c});
	    	}
        }
        else if(message.Building_Name__c == null && message.Post_Code__c != null)
        {
        	for(Account account: [Select a.Mobile_Phone__c, a.Id From Account a
    	                            Where a.Mobile_Phone__c != null 
    	                            And   a.Id In (Select p.Property_Owner__c 
    	                            			   From Property__c p
    	                            			   Where p.Post_Code__c = :message.Post_Code__c)])
	    	{
	    		ownerMobileNumbers.add(new String[]{account.Mobile_Phone__c});
	    	}
        }
        else
        {
        	for(Account account: [Select a.Mobile_Phone__c, a.Id From Account a
    	                            Where a.Mobile_Phone__c != null 
    	                            And   a.Id In (Select p.Property_Owner__c 
    	                            			   From Property__c p
    	                            			   Where p.Post_Code__c = :message.Post_Code__c
    	                            			   And p.Building_Name__c = :message.Building_Name__c)])
	    	{
	    		ownerMobileNumbers.add(new String[]{account.Mobile_Phone__c});
	    	}
        }
    	return ownerMobileNumbers;
    }
    
    /**
     Get all tenant mobile
    **/
    private List<String[]> getTenantMobileNumbers()
    {
    	List<String[]> tenantMobileNumbers = new List<String[]>();
    	
    	//When building name and post code field is empty, 
    	//then add all tenant who email is not empty , status is active 
    	//and allow email marketing to the list
    	if (message.Building_Name__c == null && message.Post_Code__c == null)
    	{
    		for(Tenant__c tenants : [Select Mobile_Phone__c, Id From Tenant__c 
    	                        	 Where Mobile_Phone__c != null
    	                             And Tenant_Status__c = :C_CONSTANT.ACTIVE
    	                             And   Email_Marketing__c = true])
	    	{
	    		tenantMobileNumbers.add(new String[]{tenants.Mobile_Phone__c});
	    	}
	    	
    	}
    	//When building name is not empty and the post code is empty, 
    	//then add tenant whose property's building name is equal to 
    	//building name to the list
    	else if (message.Building_Name__c != null && message.Post_Code__c == null)
    	{
    		for(Tenant__c tenants : [Select t.Mobile_Phone__c, t.Id 
									 From Tenant__c t
									 Where Mobile_Phone__c != null 
									 And  Email_Marketing__c = true 
									 And Tenant_Status__c = :C_CONSTANT.ACTIVE
									 And t.Property__c IN (Select p.id 
                                     					   From Property__c p
				   										   Where p.Building_Name__c = :message.Building_Name__c)])
	    	{
	    		tenantMobileNumbers.add(new String[]{tenants.Mobile_Phone__c});
	    	}
    	}
    	//When post code is not empty and building name is empty
    	//add tenant to list according to its property post code
    	else if(message.Post_Code__c != null && message.Building_Name__c == null)
    	{
    		for(Tenant__c tenants : [Select t.Mobile_Phone__c, t.id
									 From Tenant__c t
									 Where Mobile_Phone__c != null 
									 And Tenant_Status__c = :C_CONSTANT.ACTIVE
									 And t.Property__c IN (Select p.id 
                                     					   From Property__c p
				   										   Where p.Post_Code__c = :message.Post_Code__c)])
	    	{
	    		tenantMobileNumbers.add(new String[]{tenants.Mobile_Phone__c});
	    	}
    	}
    	//otherwise add tenant to the list according to its property 
    	//building name and post code
    	else
    	{
    		for(Tenant__c tenants : [Select t.Mobile_Phone__c, t.id 
									 From Tenant__c t
									 Where Mobile_Phone__c != null 
									 And Tenant_Status__c = :C_CONSTANT.ACTIVE
									 And t.Property__c IN (Select p.id 
                                     					   From Property__c p
				   										   Where p.Post_Code__c = :message.Post_Code__c
				   										   And p.Building_Name__c = :message.Building_Name__c)])
	    	{
	    		tenantMobileNumbers.add(new String[]{tenants.Mobile_Phone__c});
	    	}
    	}
    	
    	return tenantMobileNumbers;
    }
    
    /**
    Get all Contact mobile
    **/
    private List<String[]> getContactMobileNumbers()
    {
    	List<String[]> contactMobileNumbers = new List<String[]>();
    	
    	if(message.From_Date_Time__c == null && message.To_Date_Time__c == null)
    	{
    		for(Contact contacts : [Select MobilePhone From Contact
    	                           Where MobilePhone != null 
    	                           And   Email_Marketing__c = true])
	    	{
	    		contactMobileNumbers.add(new String[]{contacts.MobilePhone});
	    	}
    	}
    	//when the from date time and to time fileds are empty
    	//then select contact acccording to this time range 
    	else 
    	{
    		for(Contact contacts : [Select MobilePhone From Contact
    	                           Where MobilePhone != null 
    	                           And   Email_Marketing__c = true
    	                           And CreatedDate > :message.From_Date_Time__c
    	                           And CreatedDate < :message.To_Date_Time__c])
	    	{
	    		contactMobileNumbers.add(new String[]{contacts.MobilePhone});
	    	}
    	}
    	
    	
    	return contactMobileNumbers;
    }
    
    /**
     get all lead mobile phone where lead type is
     equal to buying and NotMassMarketing true 
    **/
    private List<String[]> getSalesMobileNumbers()
    {
    	List<String[]> salesMobileNumbers = new List<String[]>();
    	
    	if(message.From_Date_Time__c == null && message.To_Date_Time__c == null)
    	{
    		for(Lead sales : [Select MobilePhone From Lead
    	                  Where MobilePhone != null 
    	                  And Type__C = :C_Constant.BUYING
    	                  And  Email_Marketing__c = true])
	    	{
	    		salesMobileNumbers.add(new String[]{sales.MobilePhone});
	    	}
    	}
    	//when from date time and to date time fields are not empty
    	//select leads within this time range 
    	else 
    	{
    		for(Lead sales : [Select MobilePhone From Lead
    	                  Where MobilePhone != null 
    	                  And Type__C = :C_Constant.BUYING
    	                  And  Email_Marketing__c = true
    	                  And CreatedDate > : message.From_Date_Time__c
    	                  And CreatedDate < :message.To_Date_Time__c])
	    	{
	    		salesMobileNumbers.add(new String[]{sales.MobilePhone});
	    	}
    	}
    	
    	
    	return salesMobileNumbers;
    }
    
     private List<String[]> getLeaseMobileNumbers()
    {
    	List<String[]> leaseMobileNumbers = new List<String[]>();
    	
    	if(message.From_Date_Time__c == null && message.To_Date_Time__c == null)
    	{
    		for(Lead lease : [Select MobilePhone From Lead
    	                  Where MobilePhone != null 
    	                  And Type__c = :C_Constant.RENTING
    	                  And  Email_Marketing__c = true])
	    	{
	    		leaseMobileNumbers.add(new String[]{lease.MobilePhone});
	    	}
    	}
    	//when the from date time and to date time fields are not empty 
    	//get lease mobile number within this time duration 
    	else 
    	{
    		for(Lead lease : [Select MobilePhone From Lead
    	                  Where MobilePhone != null 
    	                  And Type__c = :C_Constant.RENTING
    	                  And  Email_Marketing__c = true
    	                  And CreatedDate > : message.From_Date_Time__c
    	                  And CreatedDate < :message.To_Date_Time__c])
	    	{
	    		leaseMobileNumbers.add(new String[]{lease.MobilePhone});
	    	}
    	}
    	
    	return leaseMobileNumbers;
    }
    
    /** Unit Testing **/
    @isTest 
    static void getLeaseTest()
    {   
    	//create test Message__c record 
    	Message__c testMessage = new Message__c();
    	
    	/** create test lead objects **/
    	//create three lead object which meet the requirement 
    	Lead testLead1 = new Lead(LastName = 'Test1',
    	                          Type__c = 'Renting',
    	                          Company = 'Test1',
    	                          Email_Marketing__c = true,
    	                          MobilePhone = '0411111111',
    	                          Email = 'dev@exr.com.au'
    	                          );
        insert testLead1;
        
        Lead testLead5 = new Lead(LastName = 'Test5',
    	                          Type__c = 'Renting',
    	                          Company = 'Test5',
    	                          Email_Marketing__c = true,
    	                          MobilePhone = '0411111115',
    	                          Email = 'dev@exr.com.au'
    	                          );
        insert testLead5;
        
        Lead testLead6 = new Lead(LastName = 'Test6',
    	                          Type__c = 'Renting',
    	                          Company = 'Test6',
    	                          Email_Marketing__c = true,
    	                          MobilePhone = '0411111116',
    	                          Email = 'dev@exr.com.au'
    	                          );
        insert testLead6;
       
        
        //create lead which lead type is different
        Lead testLead2 = new Lead(LastName = 'Test2',
    	                          Type__c = 'Buying',
    	                          Company = 'Test3',
    	                          Email_Marketing__c = true,
    	                          MobilePhone = '0411111112',
    	                          Email = 'dev@exr.com.au'
    	                          );
        insert testLead2;
        //create lead which does not allow email marketing 
        Lead testLead3 = new Lead(LastName = 'Test3',
    	                          Type__c = 'Renting',
    	                          Company = 'Test3',
    	                          Email_Marketing__c = false,
    	                          MobilePhone = '0411111113',
    	                          Email = 'dev@exr.com.au'
    	                          );
        insert testLead3;
        
        //create lead which does not have mobile phone
        Lead testLead4 = new Lead(LastName = 'Test4',
    	                          Type__c = 'Renting',
    	                          Company = 'Test4',
    	                          Email_Marketing__c = true
    	                          );
        insert testLead4;
        
        /**Test when message from_date_time and to_date_time is null **/
        C_MessageHandler handler = new C_MessageHandler(testMessage);
        List<String[]> leaseMobileNumbers =  handler.getLeaseMobileNumbers();
        system.assertEquals(3, leaseMobileNumbers.Size());
        
        List<String[]> testEmails = handler.getLeaseEmails();
        system.assertEquals(3, testEmails.Size());
        
        /**Test when message from_date_time and to_date_time is not null **/
        testMessage.From_Date_Time__c = DateTime.now().addDays(-10);
        testMessage.To_Date_Time__c = DateTime.now().addDays(10);
        
        handler = new C_MessageHandler(testMessage);
        leaseMobileNumbers =  handler.getLeaseMobileNumbers();
        system.assertEquals(3, leaseMobileNumbers.Size());
        
        testEmails = handler.getLeaseEmails();
        system.assertEquals(3, testEmails.Size()); 
    }
    
     @isTest 
    static void getSalesMobileNumbersTest()
    {   
    	//create test Message__c record 
    	Message__c testMessage = new Message__c();
    	
    	/** create test lead objects **/
    	//create three lead object which meet the requirement 
    	Lead testLead1 = new Lead(LastName = 'Test1',
    	                          Type__c = 'Buying',
    	                          Company = 'Test1',
    	                          Email_Marketing__c = true,
    	                          MobilePhone = '0411111111',
    	                          Email = 'dev@exr.com.au'
    	                          );
        insert testLead1;
        
        Lead testLead5 = new Lead(LastName = 'Test5',
    	                          Type__c = 'Buying',
    	                          Company = 'Test5',
    	                          Email_Marketing__c = true,
    	                          MobilePhone = '0411111115',
    	                          Email = 'dev@exr.com.au'
    	                          );
        insert testLead5;
        
        Lead testLead6 = new Lead(LastName = 'Test6',
    	                          Type__c = 'Buying',
    	                          Company = 'Test6',
    	                          Email_Marketing__c = true,
    	                          MobilePhone = '0411111116',
    	                          Email = 'dev@exr.com.au'
    	                          );
        insert testLead6;
       
        
        //create lead which lead type is different
        Lead testLead2 = new Lead(LastName = 'Test2',
    	                          Type__c = 'Renting',
    	                          Company = 'Test3',
    	                          Email_Marketing__c = true,
    	                          MobilePhone = '0411111112',
    	                          Email = 'dev@exr.com.au'
    	                          );
        insert testLead2;
        //create lead which does not allow email marketing 
        Lead testLead3 = new Lead(LastName = 'Test3',
    	                          Type__c = 'Buying',
    	                          Company = 'Test3',
    	                          Email_Marketing__c = false,
    	                          MobilePhone = '0411111113',
    	                          Email = 'dev@exr.com.au'
    	                          );
        insert testLead3;
        
        //create lead which does not have mobile phone
        Lead testLead4 = new Lead(LastName = 'Test4',
    	                          Type__c = 'buying',
    	                          Company = 'Test4',
    	                          Email_Marketing__c = true
    	                          );
        insert testLead4;
        
        /**Test when message from_date_time and to_date_time is null **/
        C_MessageHandler handler = new C_MessageHandler(testMessage);
        List<String[]> salesMobileNumbers =  handler.getSalesMobileNumbers();
        system.assertEquals(3, salesMobileNumbers.Size());
        
        List<String[]> salesEmails = handler.getSalesEmails();
        system.assertEquals(3, salesEmails.Size());
        
        /**Test when message from_date_time and to_date_time is not null **/
        testMessage.From_Date_Time__c = DateTime.now().addDays(-10);
        testMessage.To_Date_Time__c = DateTime.now().addDays(10);
        
        handler = new C_MessageHandler(testMessage);
        salesMobileNumbers =  handler.getSalesMobileNumbers();
        system.assertEquals(3, salesMobileNumbers.Size());
        
        salesEmails = handler.getSalesEmails();
        system.assertEquals(3, salesEmails.Size());
    }
    
    @isTest 
    static void getContactMobileNumbersTest()
    {
    	//Create three contact object which meet the requirement 
    	Contact testContact1= New Contact(LastName = 'Test1',
    	                                  MobilePhone = '0411111111',
    	                                  Email = 'dev@exr.com.au',
    	                                  Email_Marketing__c = true);
    	insert testContact1;
    	
    	Contact testContact2= New Contact(LastName = 'Test2',
    	                                  MobilePhone = '0411111112',
    	                                  Email = 'dev@exr.com.au',
    	                                  Email_Marketing__c = true);
        insert testContact2;
        
        Contact testContact3 = New Contact(LastName = 'Test3',
    	                                   MobilePhone = '0411111113',
    	                                   Email = 'dev@exr.com.au',
    	                                   Email_Marketing__c = true);
        insert testContact3;
        
        //create a contact object which do not allow email marketing 
        Contact testContact4 = New Contact(LastName = 'Test4',
    	                                   MobilePhone = '0411111114',
    	                                   Email = 'dev@exr.com.au',
    	                                   Email_Marketing__c = false);
        insert testContact4;
        
        //create a contact object which mobile phone is null
        Contact testContact5 = New Contact(LastName = 'Test4',
                                           Email = 'dev@exr.com.au',
    	                                   Email_Marketing__c = false);
        insert testContact5;
        
        Message__c testMessage = new Message__c();
        
        /**Test when message from_date_time and to_date_time is null **/
        C_MessageHandler handler = new C_MessageHandler(testMessage);
        List<String[]> contactMobileNumbers =  handler.getContactMobileNumbers();
        system.assertEquals(3, contactMobileNumbers.Size());
        
        List<String[]> testEmails = handler.getContactEmails();
        system.assertEquals(3,testEmails.Size());
        
        /**Test when message from_date_time and to_date_time is not null **/
        testMessage.From_Date_Time__c = DateTime.now().addDays(-10);
        testMessage.To_Date_Time__c = DateTime.now().addDays(10);
        
        handler = new C_MessageHandler(testMessage);
        contactMobileNumbers =  handler.getContactMobileNumbers();
        system.assertEquals(3, contactMobileNumbers.Size()); 
        
        testEmails = handler.getContactEmails();
        system.assertEquals(3, testEmails.Size());  
    }
    
    @isTest 
    static void getTenantMobileNumbersTest()
    {
    	//create tenant object which building name and post code are met requirment
    	Property__c testProperty1 = new Property__c(Name = 'Test1',
    	                                            Building_Name__c = 'Testing',
    	                                            Post_Code__c = '1688'
    	                                            );
    	insert testProperty1;
    	
        Tenant__c testTenant1 = new Tenant__c(Name = 'Testing1',
                                             Property__c = testProperty1.Id,
                                             Tenant_Status__c = 'Active',
                                             Email_Marketing__c = true,
                                             Mobile_Phone__c = '0411111111',
                                             Email__C = 'dev@exr.com.au');
        insert testTenant1;
        
        //create tenant object which building name is different 
        Property__c testProperty2 = new Property__c(Name = 'Test2',
    	                                            Post_Code__c = '1688',
    	                                            Building_Name__c = 'Testing1'
    	                                            );
    	insert testProperty2;
    	
    	Tenant__c testTenant2 = new Tenant__c(Name = 'Testing1',
                                             Property__c = testProperty2.Id,
                                             Tenant_Status__c = 'Active',
                                             Email__C = 'dev@exr.com.au',
                                             Email_Marketing__c = true,
                                             Mobile_Phone__c = '0411111112');
        insert testTenant2;
    	
        Message__c testMessage = new Message__c();
        
        //Test when message post code and building name are empty 
        C_MessageHandler handler = new C_MessageHandler(testMessage);
        List<String[]> testMobiles = handler.getTenantMobileNumbers();
        system.assertEquals(2, testMobiles.Size());
        
        List<String[]> testEmails = handler.getTenantEmails();
        system.assertEquals(2,testEmails.Size());
        
        //Test when message post code is null and building name is not null
    	testMessage.Building_Name__c = 'Testing';
    	handler = new C_MessageHandler(testMessage);
        testMobiles = handler.getTenantMobileNumbers();
        system.assertEquals(1, testMobiles.Size());
        
        testEmails = handler.getTenantEmails();
        system.assertEquals(1,testEmails.Size());
        
        //Test when message post code in not null and building name is null 
        testMessage.Building_Name__c = null;
        testMessage.Post_Code__c = '1688';
    	handler = new C_MessageHandler(testMessage);
        testMobiles = handler.getTenantMobileNumbers();
        system.assertEquals(2, testMobiles.Size());
        
        testEmails = handler.getTenantEmails();
        system.assertEquals(2,testEmails.Size());
        
        //Test when message post code in not null and building name is  not null 
        testMessage.Building_Name__c = 'Testing';
        testMessage.Post_Code__c = '1688';
    	handler = new C_MessageHandler(testMessage);
        testMobiles = handler.getTenantMobileNumbers();
        system.assertEquals(1, testMobiles.Size());
        
        testEmails = handler.getTenantEmails();
        system.assertEquals(1,testEmails.Size());
    }
    
    @isTest 
    static void getOwnerMobileNumbersTest()
    {
    	//create tenant object which building name and post code are met requirment	
        Account testOwner1 = new Account(Name = 'Testing1',
                                        Email_Marketing__c = true,
                                        Email__c = 'dev@exr.com.au',
                                        Mobile_Phone__c = '0411111111');
        insert testOwner1;
        
        Property__c testProperty1 = new Property__c(Name = 'Test1',
    	                                            Building_Name__c = 'Testing',
    	                                            Post_Code__c = '1688', 
    	                                            Property_Owner__c  = testOwner1.id
    	                                            );
    	insert testProperty1;
        
        Account testOwner2 = new Account(Name = 'Testing2',
                                         Email_Marketing__c = true,
                                         Email__c = 'dev@exr.com.au',
                                         Mobile_Phone__c = '0411111112');
        insert testOwner2;
        
        //create tenant object which building name is different 
        Property__c testProperty2 = new Property__c(Name = 'Test2',
    	                                            Post_Code__c = '1688',
    	                                            Building_Name__c = 'Testing1',
    	                                            Property_Owner__c  = testOwner2.id
    	                                            );
    	insert testProperty2;
    	
    	
        Message__c testMessage = new Message__c();
        
        //Test when message post code and building name are empty 
        C_MessageHandler handler = new C_MessageHandler(testMessage);
        List<String[]> testMobiles = handler.getOwnerMobileNumbers();
        system.assertEquals(2, testMobiles.Size());
        
        List<String[]> testEmails = handler.getOwnerEmails();
        system.assertEquals(2,testEmails.Size());
        
        //Test when message post code is null and building name is not null
    	testMessage.Building_Name__c = 'Testing';
    	handler = new C_MessageHandler(testMessage);
        testMobiles = handler.getOwnerMobileNumbers();
        system.assertEquals(1, testMobiles.Size());
        
        testEmails = handler.getOwnerEmails();
        system.assertEquals(1,testEmails.Size());
        
        //Test when message post code in not null and building name is null 
        testMessage.Building_Name__c = null;
        testMessage.Post_Code__c = '1688';
    	handler = new C_MessageHandler(testMessage);
        testMobiles = handler.getOwnerMobileNumbers();
        system.assertEquals(2, testMobiles.Size());
        
        testEmails = handler.getOwnerEmails();
        system.assertEquals(2,testEmails.Size());
        
        //Test when message post code in not null and building name is  not null 
        testMessage.Building_Name__c = 'Testing';
        testMessage.Post_Code__c = '1688';
        testMessage.SMS_Body__c = 'Test';
    	handler = new C_MessageHandler(testMessage);
        testMobiles = handler.getOwnerMobileNumbers();
        system.assertEquals(1, testMobiles.Size());
        
        testEmails = handler.getOwnerEmails();
        system.assertEquals(1,testEmails.Size());
        
        //Test Get Description 
        String testDescription = handler.getDescription(testEmails);
        system.assertEquals(true, testDescription.contains('dev@exr.com.au'));
        
    }
    
    @isTest(seeAllData=true) 
    static void messagingTest()
    {
    	Message__c testMessage = new Message__c(Name= 'Testing',
    	                                        Status__c = 'Send',
    	                                        Receipt__c='Owners;Tenants;Sales Leads;Lease Leads;',
    	                                        Message_Type__c = 'Email;SMS',
    	                                        Email_Body__c = 'Email Body Testing',
    	                                        SMS_Body__c = 'SMS Body Tesing'
    	                                        );
       insert testMessage; 
       
       Blob testBlob = Blob.valueof('Test paf');
    	
    	Attachment attachment = new Attachment();
    	attachment.Name = 'Test.pdf';
    	attachment.Body = testBlob;
    	attachment.ParentId = testMessage.Id;
    	insert attachment;
    	
       C_MessageHandler handler = new C_MessageHandler(testMessage);
       handler.processSMS();
       
       /**Test sendEmail() **/
        String[] testEmail = new String[]{'dev@exr.com.au'};
       List<String[]> testEmails = new List<String[]>();
       testEmails.add(testEmail);
       testEmails.add(testEmail);
       handler.sendEmail(testEmails);   
       
       /** Test processEmail() && processMessage() **/
       handler.processEmail();  
       handler.processMessage();   
       
       testMessage.Receipt__c='Contacts';
       update testMessage;
       handler.processMessage();   
    }
}