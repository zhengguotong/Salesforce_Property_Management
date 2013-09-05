public with sharing class C_RentIncreaseHandler 
{
	 public final static String SUBJECT = 'Notification of Rent Increase';
	 public final static String TENANT_SUBJECT = 'Send sms to tenant and bcc owner about the rent increase';
	 public final static String OWNER_NOT_EMAIL = 'Send email and sms to tenant about the rent increase';
	 public final static String TENANT_NOT_EMAIL ='Send email to owner and sms to tenant about the renant increase ';
	 public final static String OWNER_SUBJECT ='Get Owner Approval about the rent Increase';
	 public final static String TENANT_SMS_SUBJECT = 'Send Tenant SMS about rent increase';
	 public final static integer NUMBER_OF_DAYS = 67;
	
     private  Tenant__c tenant;
     private String propertyAddress = ''; 
    
     public C_RentIncreaseHandler(Tenant__c tenant)
     {
     	this.tenant = tenant;
     	propertyAddress = C_Utility.propertyAddress(C_Utility.getProperty(tenant));
     }
     
     
      /**
      Get owner email address and mobile number
      **/
     private void getOwnerDetail()
     {
          List<Account> owners = [Select a.Mobile_Phone__c, a.Id, a.Email__c 
                           From Account a
                           Where a.Id  in (Select Property_Owner__C 
                                           From property__c p 
                                           Where p.id = :tenant.Property__c)];
                                           
         if(owners.size() >= 1 &&  owners[0].Email__c != null)
         {
         	tenant.H_Owner_Email__c = owners[0].Email__c;
         }  
     }
     
      /**
     	send email to owner about rent increase
     **/
     public void informOwner()
     {  
     	getOwnerDetail();
     	if (tenant.H_Owner_Email__c != null)
     	{
     		 C_Email.sendSignleEMail(new String[]{tenant.H_Owner_Email__c},SUBJECT,setOwnerEmailBody());
        	 C_Utility.logActivity(OWNER_SUBJECT,ownerActivityDescription(),tenant.Property__c);
     	}
     }
     
     /**
      set Notification of rent increase to owner email body
     **/
     private String setOwnerEmailBody()
     {
     	String emailBody = '';
     	emailBody +='<p> Dear owner, </p>'
                    +'<p><b>Re: ' + propertyAddress + '</b> </p>'
                    + '<p>Acting in your best interests to maximize the performance of your investment, '
                    + 'we have reviewed the rent payable on the above property.</p>'
                    + '<p>It is proposed to increase the tenant’s rent to $'
                    + tenant.New_Rent__c +  ' per ' + getLeasePeriod() + ' from ' + getNewLeaseDate() + ' </p> '
                    + '<p>Please advise the office within 5 days should you require any change to this proposal '
                    + ' as we are required by law to give tenant 60 days notice of the proposed increased.</p> '
                    + '<p>In the absence of any instructions from you to the contrary by this date, we will proceed with '
                    + 'the rent increase and advise the tenant accordingly.</p>'
                    +'<p>If you wish to discuss further, please feel free to contact our office to discuss.</p>'
                    +'</br><p>Yours faithfully,</br>Excelsior Realty Pty. Ltd.</p>'
                    +'</br></br> <p><font color="red"> T</font>   + 61 2 9281 6777    <font color="red">F</font>   '
                    + '+61 2 9281 2283   <font color="red">E </font>  sales@exr.com.au</p>';   
     	return emailBody;
     }
     
     /**
     	log owner acitivity description 
     **/
     private String ownerActivityDescription()
     {
     	String description = '';
     	description +='To: ' + tenant.H_Owner_Email__c  + '\n\n'
     	            +'Time: ' + DateTime.now().format('E dd/MM/yyyy hh:mm a') + '\n\n'
     				+ 'Dear owner, \n\n'
                    +'Re: ' + propertyAddress + '\n\n'
                    + 'Acting in your best interests to maximize the performance of your investment, '
                    + 'we have reviewed the rent payable on the above property.\n\n'
                    + 'It is proposed to increase the tenant’s rent to $'
                    + tenant.New_Rent__c +  ' per ' + getLeasePeriod() + ' from ' + getNewLeaseDate() + '\n\n'
                    + 'Please advise the office within 5 days should you require any change to this proposal '
                    + ' as we are required by law to give tenant 60 days notice of the proposed increased.\n\n '
                    + 'In the absence of any instructions from you to the contrary by this date, we will proceed with '
                    + 'the rent increase and advise the tenant accordingly.\n\n'
                    +'If you wish to discuss further, please feel free to contact our office to discuss.\n\n'
                    +'Yours faithfully,\n Excelsior Realty Pty. Ltd.\n\n';
     	return description;
     }
     
     /**
         send notfication email and sms 
         to tenant
     **/
     public void informTenant() 
     {  
     	getOwnerDetail();
     	
     	//when teant has emil address and owner email is not empty, then 
     	//send rent increase email to tenant and cc owner and log email body 
     	//under this property activity history 
     	if(tenant.Email__c != null && tenant.H_Owner_Email__c != null)
     	{
     		C_Email.sendBccEMail(new String[]{tenant.Email__c, tenant.H_Owner_Email__c},SUBJECT,setTenantEmailBody());
        	C_Utility.logActivity(TENANT_SUBJECT , tenantActivityDescription(),tenant.Property__c);
     	}
     	
     	//when teant has emil address and owner email is  empty, then 
     	//send rent increase email to tenant  and log email body 
     	//under this property activity history 
     	if(tenant.Email__c != null && tenant.H_Owner_Email__c == null)
     	{
     		C_Email.sendSignleEMail(new String[]{tenant.Email__c},SUBJECT,setTenantEmailBody());
        	C_Utility.logActivity(OWNER_NOT_EMAIL , tenantActivityDescription(),tenant.Property__c);
     	}
     	
     	//when tenant does not have email address and owner email is not empty, then 
     	//send rent increase email to owner and log email body 
     	//under this property activity history 
     	if(tenant.Email__c == null && tenant.H_Owner_Email__c != null)
     	{
     		C_Email.sendSignleEMail(new String[]{tenant.H_Owner_Email__c},SUBJECT,setTenantEmailBody());
        	C_Utility.logActivity(TENANT_NOT_EMAIL, tenantActivityDescription(),tenant.Property__c);
     	}
        
        sendsmsNotification();
     }
     
     
     /**
     	set notification of rent increase to tenant email body
     **/
     private String setTenantEmailBody()
     {
     	String emailBody = '';
     	emailBody += '	<p>Dear Tenant,</p>'
                  + '<p><b>Re:Rent Review – ' + propertyAddress + '</b><p>'
                  + '<p>In accordance with our responsibilities as a Managing '
                  + 'Agent and instruction from the landlord, we are obligated to carry'
                  +' out a fair market rent review which reflects the market price. </p>'
                  +'<p>When carrying out a fair market rent review we take into consideration '
                  + 'the following points:</p>'
                  +'<p><ul><li>Rental prices of similar properties in the neighbouring area </li>'
                  +'<li>Counci,water, stata  rate and land tax increases</li>'
                  +'<li>CPI increases</li></ul></p>'
                  +'<p>In accessing your tenancy agreement we hereby wish to inform that your '
                  +'rent will be increased to <b>$'+ tenant.New_Rent__c + ' every ' +  getLeasePeriod() + '.</b> </p>'
                  +'<p><b>We hereby give you the prescribed notice 2 MONTHS and advise that your '
                  + 'new monthly rent will be $' + tenant.New_Rent__c  + ' per ' +  getLeasePeriod() 
                  + ' as of ' + getNewLeaseDate() + '</b></p>'
                  + '<p>Should you wish to discuss this matter in further detail, please contact our office. </p>'
                  +'<p>Yours truly,</br></br>Excelsior Realty Pty Ltd</br></br>Property Management</p>'
                  +'</p></br></br> <p><font color="red"> T</font>   + 61 2 9281 6777    '
                  +'<font color="red">F</font>   +61 2 9281 2283   <font color="red">E </font>  sales@exr.com.au</p>';
       return emailBody;
     }
     
     /**
     	log tenant activity description 
     **/
     private String tenantActivityDescription()
     {
     	String description = '';
     	description += 'BCC:Owner ' + tenant.H_Owner_Email__c + ' Tenant: ' + tenant.Email__c + '\n\n'
     	          +'Time: ' + DateTime.now().format('E dd/MM/yyyy hh:mm a') + '\n'
     	          +'Dear Tenant\n\n'
                  + 'Re:Rent Review – ' + propertyAddress + '\n\n'
                  + 'In accordance with our responsibilities as a Managing '
                  + 'Agent and instruction from the landlord, we are obligated to carry'
                  +' out a fair market rent review which reflects the market price.\n\n'
                  +'When carrying out a fair market rent review we take into consideration '
                  + 'the following points:\n'
                  +'Rental prices of similar properties in the neighbouring area\n'
                  +'1.Counci,water, stata  rate and land tax increases\n'
                  +'2.CPI increases\n'
                  +'In accessing your tenancy agreement we hereby wish to inform that your '
                  +'rent will be increased to $'+ tenant.New_Rent__c + ' every ' +  getLeasePeriod() + '\n\n'
                  +'We hereby give you the prescribed notice 2 MONTHS and advise that your '
                  + 'new monthly rent will be $' + tenant.New_Rent__c  + ' per ' +  getLeasePeriod() 
                  + ' as of ' + getNewLeaseDate() + '\n\n'
                  + 'Should you wish to discuss this matter in further detail, please contact our office. \n\n'
                  +'Yours truly,\nExcelsior Realty Pty Ltd\nProperty Management\n\n';
        return description; 
     }
     
     /**
     	send tennant notifcication email about the rent incresement
     **/
     private void sendsmsNotification()
     {   
     	 if(tenant.Mobile_Phone__c != null)
     	 {
     	 	C_SMS.sendSms(tenant.Mobile_Phone__c, tenant.Name, tenantSMSBody());
     	 	C_Utility.logActivity(TENANT_SMS_SUBJECT, tenantSMSBody(), tenant.Property__c);
     	 }
     }
     
     
     /**
        get lease period
     **/
     private  String getLeasePeriod()
     {
     	if(tenant.Rent_Period__c == 'M1')
     		return 'MONTH';
        else if (tenant.Rent_Period__c == 'W1')
            return 'WEEK';
        else
            return 'FORTNIGHT';
     }
     /**
        get the new rent start date 
        if the lease period is monthly 
        then the new rent start date would be last
        pay date pluse 3 month; if the lease period is 
        weekly then the new lease start date would be 
        the 10 weeks later form the last payment date
     **/
     private String getNewLeaseDate()
     {
     	if (tenant.Rent_Period__c == 'M1')
     	{
     		 DateTime  payTodate = tenant.Pay_to_Date__c;
             Date payDate = date.newinstance(payTodate.year(), payTodate.month(), payTodate.day());
             if(Date.today().daysBetween(payDate) > NUMBER_OF_DAYS)
             	return tenant.Pay_to_Date__c.format('dd MMM yyyy');
             else if (Date.today().daysBetween(payDate.addMonths(1))> NUMBER_OF_DAYS)
             	 return tenant.Pay_to_Date__c.addMonths(1).format('dd MMM yyyy');
     		 else if(Date.today().daysBetween(payDate.addMonths(2)) > NUMBER_OF_DAYS)
     		       return tenant.Pay_to_Date__c.addMonths(2).format('dd MMM yyyy');
     		 else if (Date.today().daysBetween(payDate.addMonths(3)) > NUMBER_OF_DAYS)
     		 	   return tenant.Pay_to_Date__c.addMonths(3).format('dd MMM yyyy');
     	     else 
     	     	   return tenant.Pay_to_Date__c.addMonths(4).format('dd MMM yyyy');
     	}
     	else 
     		return tenant.Pay_to_Date__c.addDays(70).format('dd MMM yyyy');
     }
    
    /**
    return sms body that send to tenant regarding rent increase
    **/ 
    private String tenantSMSBody ()
    {
    	return 'Dear tenant, '
    	        +'Re:(' +propertyAddress + ' rent increase) '
    	        +'In accessing your tenancy agreement we hereby wish to inform that your '
                  +'rent will be increased to $'+ tenant.New_Rent__c + ' every ' +  getLeasePeriod()
                  +' We hereby give you the prescribed notice 2 MONTHS and advise that your '
                  + 'new monthly rent will be $' + tenant.New_Rent__c  + ' per ' +  C_Utility.NVL(getLeasePeriod())
                  + ' as of ' + getNewLeaseDate()
                  + ' Should you wish to discuss this matter in further detail, please contact our office. '
    	        +'Best regards '
    	        +'Excelsior Realty';
    }
    
    
    static testMethod void tenantSMSBodyTest()
    {
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
       
       //create test tenant
       Tenant__c testTenant = new Tenant__c( Name = 'Test Tenant',
       									      Rent_Period__c = 'M1',
       									      Mobile_Phone__c = '0411121314',
       									      Email__c = 'dev@exr.com.au',
       									      Pay_To_Date__c = Date.Today(),
       									      Property__c = testProperty.Id);
       									      
       	insert testTenant;
       	
       	C_RentIncreaseHandler handler = new C_RentIncreaseHandler(testTenant);
       	system.assertEquals(true, handler.tenantSMSBody().contains('6678 Test Building Name Test Street Name '
                                                   +'Test Suburn NSW 2000'));
    }
    
    static testMethod void getLeasePeriodTest()
    {
    	 Tenant__c testTenant = new Tenant__c( Name = 'Test Tenant',
       									      Rent_Period__c = 'M1');
       	 insert testTenant;
       	 
       	 //Test monthly rent period 
       	 C_RentIncreaseHandler handler = new C_RentIncreaseHandler(testTenant);
       	 system.assertEquals('MONTH',handler.getLeasePeriod());
       	 
       	 //Test weekly rent period 
       	 testTenant.Rent_Period__c = 'W1';
       	 update testTenant;
       	 handler = new C_RentIncreaseHandler(testTenant);
       	 system.assertEquals('WEEK',handler.getLeasePeriod());
       	 
       	 //Test fortnight rent period 
       	 testTenant.Rent_Period__c = 'W2';
       	 update testTenant;
       	 handler = new C_RentIncreaseHandler(testTenant);
       	 system.assertEquals('FORTNIGHT',handler.getLeasePeriod());
       	 
    }
    
    static testMethod void getNewLeaseDateTest()
    {
    	DateTime payToDate = Date.today().addDays(NUMBER_OF_DAYS + 3);
    	
    	Tenant__c testTenant = new Tenant__c( Name = 'Test Tenant',
       									      Rent_Period__c = 'M1',
       									      Pay_to_Date__c = payToDate);
         
       	 insert testTenant;
       	  
       	  //Test when lease period is monthly and the days between today and payTodate 
       	  //is bingger than 67  days 
       	  C_RentIncreaseHandler handler = new C_RentIncreaseHandler(testTenant);
       	  system.assertEquals(payToDate.format('dd MMM yyyy'), handler.getNewLeaseDate());
       	  
       	  //Test when lease period is monthly and the day between today and payTodate 
       	  //that add 1 month is bingger than 67  days 
       	  payToDate = payToDate.addMonths(-1);
       	  testTenant.Pay_to_Date__c = payTodate;
       	  update testTenant;
       	  handler = new C_RentIncreaseHandler(testTenant);
       	  system.assertEquals(payToDate.addMonths(1).format('dd MMM yyyy'), handler.getNewLeaseDate());
       	  
       	    //Test when lease period is monthly and the day between today and payTodate 
       	  //that add 2 months is bingger than 67  days 
       	  payToDate = payToDate.addMonths(-1);
       	  testTenant.Pay_to_Date__c = payTodate;
       	  update testTenant;
       	  handler = new C_RentIncreaseHandler(testTenant);
       	  system.assertEquals(payToDate.addMonths(2).format('dd MMM yyyy'), handler.getNewLeaseDate());
       	  
       	    //Test when lease period is monthly and the day between today and payTodate 
       	  //that add 3 months is bingger than 67  days 
       	  payToDate = payToDate.addMonths(-1);
       	  testTenant.Pay_to_Date__c = payTodate;
       	  update testTenant;
       	  handler = new C_RentIncreaseHandler(testTenant);
       	  system.assertEquals(payToDate.addMonths(3).format('dd MMM yyyy'), handler.getNewLeaseDate());
       	  
       	  
       	   //Test when lease period is monthly and the day between today and payTodate 
       	  //that add 4 month is bingger than 67 days 
       	  payToDate = payToDate.addMonths(-1);
       	  testTenant.Pay_to_Date__c = payTodate;
       	  update testTenant;
       	  handler = new C_RentIncreaseHandler(testTenant);
       	  system.assertEquals(payToDate.addMonths(4).format('dd MMM yyyy'), handler.getNewLeaseDate());
       	  
       	  //Test When lease period is weely or fortnight
       	  payToDate = Date.today().addDays(3);
       	  testTenant.Pay_to_Date__c = payTodate;
       	  testTenant.Rent_Period__c = 'W1';
       	  update testTenant;
       	  handler = new C_RentIncreaseHandler(testTenant);
       	  system.assertEquals(payToDate.addDays(70).format('dd MMM yyyy'), handler.getNewLeaseDate());  
    }
    
    @isTest(seeAllData=true) 
    static void sendsmsNotificationTest()
    {
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
       
       //create test tenant
       Tenant__c testTenant = new Tenant__c( Name = 'Test Tenant',
       									      Rent_Period__c = 'M1',
       									      Mobile_Phone__c = '0411121314',
       									      Email__c = 'dev@exr.com.au',
       									      Pay_To_Date__c = Date.Today(),
       									      Property__c = testProperty.Id);
       									      
       	insert testTenant;
       	 
       	 Integer beforeCount = [Select count() From Task
       	                        Where WhatId = :testProperty.Id];
       	                        
       	 C_RentIncreaseHandler handler = new C_RentIncreaseHandler(testTenant);
       	 handler.sendsmsNotification();		
       	 
       	 Integer afterCount = [Select count() From Task
       	                        Where WhatId = :testProperty.Id];		
       	 system.assertEquals(1, afterCount - beforeCount);				      
    }
    
    static testMethod void textMethodTest()
    {
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
       
       //create test tenant
       Tenant__c testTenant = new Tenant__c( Name = 'Test Tenant',
       									      Rent_Period__c = 'M1',
       									      Mobile_Phone__c = '0411121314',
       									      Email__c = 'dev@exr.com.au',
       									      Pay_To_Date__c = Date.Today(),
       									      Property__c = testProperty.Id);
       									      
       	insert testTenant;
       	
       	C_RentIncreaseHandler handler = new C_RentIncreaseHandler(testTenant);
       	
       	//Test tenantAcitivtyDescription
       	system.assertEquals(true,handler.tenantActivityDescription().contains('dev@exr.com.au'));
        
        //Test setTenantEmailBody()
        system.assertEquals(true,handler.setTenantEmailBody().contains('6678 Test Building Name Test Street Name Test Suburn NSW 2000'));
        
        //Test ownerActivityDescription()
        system.assertEquals(true,handler.ownerActivityDescription().contains('6678 Test Building Name Test Street Name Test Suburn NSW 2000'));
        
        //Test setOwnerEmailBody()
         system.assertEquals(true,handler.setOwnerEmailBody().contains('6678 Test Building Name Test Street Name Test Suburn NSW 2000'));
    }
    
    @isTest(seeAllData=true)
    static void informTenantTest() 
    {
        //create new test owner 
    	Account testOwner = new Account(Name = 'Test Owner',
    	                                Email__c = 'dev@owner.com.com',
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
       
       //create test tenant
       Tenant__c testTenant = new Tenant__c( Name = 'Test Tenant',
       									      Rent_Period__c = 'M1',
       									      Mobile_Phone__c = '0411121314',
       									      Email__c = 'dev@exr.com.au',
       									      Pay_To_Date__c = Date.Today(),
       									      Property__c = testProperty.Id);
       									      
       	insert testTenant;
       	 
       	 //Test InformTenant								      
       	 Integer beforeCount = [Select count() From Task
       	                        Where WhatId = :testProperty.Id];
       	                        
       	 C_RentIncreaseHandler handler = new C_RentIncreaseHandler(testTenant);
       	 handler.getOwnerDetail();
       	 handler.informTenant() ;		
       	 
       	 Integer afterCount = [Select count() From Task
       	                        Where WhatId = :testProperty.Id];
       	                     		
       	 system.assertEquals(2, afterCount - beforeCount);	
       	 
       	 //Test informOwner 	
       	 beforeCount = [Select count() From Task
       	                        Where WhatId = :testProperty.Id];
       	                        
       	 handler = new C_RentIncreaseHandler(testTenant);
       	 handler.informOwner() ;		
       	 
         afterCount = [Select count() From Task
       	                        Where WhatId = :testProperty.Id];
       	                     		
       	 system.assertEquals(1, afterCount - beforeCount);	
       	 
       	 //test informtenant when owner do not have email address 
       	 testOwner.Email__c = null;
       	 update testOwner;
       	 
       	 handler.informTenant();
       	 
       	 //test informTenant when tenant does not have email address 
       	 testTenant.Email__c = null;
       	 update testTenant;
       	 
       	 testOwner.Email__c = 'dev@exr.com.au';
       	 update testOwner;
       	 
       	 handler.informTenant();		
    }
}