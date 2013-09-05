public with sharing class C_TenantVacatingHandler 
{
	public static String EVENT_SUBJECT = 'Tenant vacating date';
	public static String TENANT_EMAIL_SUBJECT ='Tenant Vacate Checklist';
	public static String TENANT_SMS_SUBJECT ='Send SMS to tenant Regarding Vacating Checklist';
	public static String TENANT_VACATE_FORM_SUBJECT ='Send Notice to Vacate Form to Tenant';
	public static String OWNER_EMAIL_SUBJECT = 'Send Vacating Notification Letter to Owner';
	public static String OWNER_SMS_SUBJECT ='Send SMS to Owner Regarding Tenant Vacate';
	
	private Tenant__c tenant;
	private String ownerMobile = '';
     
     public C_TenantVacatingHandler(Tenant__c tenant)
     {
         this.tenant = tenant;
         tenant.H_Property_Address__c = C_Utility.propertyAddress(C_Utility.getProperty(tenant));
     }
     
     /**
     log notice to vacate form that send to tenant 
     in teannt activity history
     */
     public static void logFormActitivity(Tenant__c currentTenant)
     {
     	String description = TENANT_VACATE_FORM_SUBJECT 
     	                     +'\nEmail Address:' + currentTenant.Email__c
     	                     +'\nTime: ' +  Datetime.now().format('E dd/MM/yyyy hh:mm a');
     	C_Utility.logActivity(TENANT_VACATE_FORM_SUBJECT, description,currentTenant.Id);
     }
     
     /**
     log vacate check list email that send to tenant
     send sms to tenant and log the sms body in the 
     proerty activity history
     **/
     public void informTenant()
     {
     	 createVacatingEvent();
     	 //log Vacating Check list Email in property Acitivity History
     	 C_Utility.logActivity(TENANT_EMAIL_SUBJECT,tenantEmailBody(), tenant.Property__c);
     	 //send sms to tenant and log sms body in propety activity history
     	 if(tenant.Mobile_Phone__c != null)
     	{
     	 	C_SMS.sendSms(tenant.Mobile_phone__c, tenant.Name, ownerSMSBody());
         	C_Utility.logActivity(TENANT_SMS_SUBJECT,ownerSMSBody(),tenant.Property__c);
     	 } 
     	 
     }
     
     /**
     send notification of tenant vacate to owner and log 
     email body in the property activity history
     Send SMS to owner regarding tenant vacate and log 
     sms body in the property activity history
     **/
     public void informOwner()
     {
     	getOwnerDetail();
     	//send Notification of tenant vacate to owner(this done by workflow rule)
     	//log email body in the property acitvity history
     	C_Utility.logActivity(OWNER_EMAIL_SUBJECT,ownerEmailBody(),tenant.Property__c);
    
     	if(ownerMobile != '')
     	 {
     	 	C_SMS.sendSms(ownerMobile, '', ownerSMSBody());
         	C_Utility.logActivity(OWNER_SMS_SUBJECT,ownerSMSBody(),tenant.Property__c);
     	 } 
     	
     }
     
     /**
      create vacating Event 
     **/
     private void createVacatingEvent()
     {
            //check database to see whether has the vacating event been create yet 
            List<Event> events = [Select id 
                                  From Event 
                                  Where StartDateTime  > :date.today() 
                                  And  WhatId = :tenant.Property__c];
            
            //if there is not event in the date 
            //then create a vacate event
            if(events.size() == 0)
            {
                Event event = new Event();
                event.Subject = EVENT_SUBJECT;
                event.StartDateTime = tenant.Vacating_Date__c;
                event.EndDateTime = tenant.Vacating_Date__c;
                event.Description = 'Tenant ' + tenant.Name;
                event.WhatId = tenant.Property__c;
                insert event;
            }
            else //update event time 
            {
            	events[0].StartDateTime = tenant.Vacating_Date__c;
            	events[0].EndDateTime = tenant.Vacating_Date__c;
            	update events[0];
            }
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
         
         if(owners.size() >= 1 &&  owners[0].Mobile_Phone__c != null)
         {
         	ownerMobile = owners[0].Mobile_Phone__c;
         }
         
     }
     
     /**
     return tenant vacate checklist email body
     **/
     private String tenantEmailBody()
     {
     	return 'To: ' + tenant.Email__c + '\n'
   	          +'Time: ' + Datetime.now().format('E dd/MM/yyyy hh:mm a') + '\n'
   	          +'Body:\n '
   	          +'Dear Tenant \n'
   	          +'Re: ' + tenant.H_Property_Address__c
   	          + '\nWe write to confirm your vacating date to the property is on '
   	          +tenant.Vacating_Date__c.format() + '. Please kindly be reminded of the followings;\n\n'
              + 'Cleaning\n\n' +'If you have chosen to appoint your own cleaning services, you '
              + 'are required to “General Clean” the apartment and Professionally “Steam Clean” '
              + 'the apartment carpet prior to vacating. Otherwise, our appointed cleaning '
              +'services Cleaner Cleaning Hub Pty Ltd will carry out the job after you have vacated. '
              +'They can be contacted on 0449 614 471 (Mark) if you need to obtain a quote.\n\n'
              + 'You can refer to Moving out clean checklist bellowed to assist you in ensuring a '
              + 'trouble free end to your tenancy with us. However if the property is not left in a '
              + 'clean and tidy condition after you move out, Agent would arrange cleaning ASAP in '
              + 'order to make sure the property is ready immediately for the new tenant to move in '
              + 'and the associated market cost would be deducted from your bond. Such action by '
              + 'Agent would be performed in fair manner and the outstanding issues would be '
              + 'compared with the initial condition when our agreement firstly commenced.\n\n'
              + 'Utility Disconnection\n'
              +'Agent would assist the tenant to disconnect all utility service through '
              + '“Connect Now”, the utility service provider including energy, gas, telephone, '
              + 'and Internet free of charge. Please fill in attached Utility Disconnection form '
              +  'and send the form to our office after completion by email or fax. “Connect Now” '
              + 'would contact the tenant once they receive notice from us and all utilities would '
              + 'be disconnected on the vacating date. The service is free of charge. If you have '
              + 'arranged your own utility disconnection, please disregard this section.\n\n'
              +'Key Return\n'
              +'On the date of vacating, tenant should return all keys, swipe cards and remote '
              + 'to the Agent’s office no later than 12pm on the date. Tenant will be charged '
              + 'extra day rent if keys are return later than 12pm on the same date or be '
              + 'charged rent until keys are received by the agent’s office. If your '
              +'vacating date is outside business hours, please contact our office to '
              + 'confirm the keys return time.\n\n'
              +'Bond\n'
              +'Tenant will make sure all light fitting on the premises have working globes '
              +'and return to the landlord/Agent all keys provided by landlord or agent. '
              +'Tenant would also provide a copy of cleaning receipt to the Agent’s office '
              + 'when return keys if the cleaning is arranged by him/herself.\n\n'
              +'If in the event that the property has outstanding issues after property '
              +'becomes vacant and agent does not receive any communication and comments '
              +'from the tenant, in order to make sure the property is immediately ready '
              +'for new tenant to move in, Agent will immediately arrange cleaning or '
              + 'repairs for associated cost at market. Such action by Agent would be '
              + 'performed in fair manner and the outstanding issues would be compared '
              + 'with the initial condition when our agreement firstly commenced.\n\n'
              +'If you have any questions for the above or would like to inform our '
              +'office for outstanding repairs, please email us to rentals@exr.com.au '
              +'ASAP before your vacating.\n\n'
              +'Please allow 10 business days for bond processing after agent final '
              +'inspections. Agent will prepare all bond paperworks on the appointment date.\n\n'
              +'Moving out clean checklist\n\n'
              +'KITCHEN\n'
              +'•	Clean cook top/ stove hood\n'
              +'•	Clean kitchen bench\n'
              +'•	Clean and polish kitchen sink\n'
              +'•	Clean inside the oven, and inside dishwasher\n'
              +'•	Clean outside of all appliances\n'
              +'•	Clean inside & outside of all kitchen cupboards and cabinets'
              +'•	Vacuum or sweep kitchen floor'
              +'•	Mop kitchen floor and Remove cobwebs, Take out rubbish\n\n'
              +'BATHROOMS\n'
              +'•	Scrub and clean toilet\n'
              +'•	Clean washing basin, mirrors, bathtub and shower\n'
              +'•	Scrub and polish shower tiles\n'
              +'•	Clean inside bathroom cupboards and cabinets\n'
              +'•	Vacuum and sweep bathroom floors, and Polish faucet\n'
              +'•	All bathroom walls and ceiling thoroughly cleaned removing dirt and mold\n'
              +'•	Dust/ wipe air vent extractor\n'
              +'•	Remove cobwebs\n'
              +'•	Clean Blinds\n\n'
              +'LIVING AREAS/ DINING ROOM/ FAMILY ROOM/ OTHER ROOMS\n\n'
              +'•	Vacuum carpet, rugs & floor, and Mop floor (if tiles or wood)\n'
              +'•	Clean all mirrors\n'
              +'•	Dust all horizontal surfaces, and all corners (high/low)\n'
              +'•	Clean wall skirting, and built in wardrobes\n'
              +'•	Remove cobwebs\n'
	          +'•	Clean Laundry dryer filter and dust in dryer\n'
	          +'•	Clean Blinds\n\n'
	          +'BEDROOMS\n'
	          +'•	Dust all horizontal surfaces,\n'
	          +'•	Vacuum floor carpet and rugs\n'
	          +'•	Mop floor (if applicable), and Clean all mirrors\n'
	          +'•	Dust all corners (high/low)\n'
	          +'•	Clean wall skirting, and built in wardrobes\n'
	          +'•	Remove cobwebs\n'
	          +'•	Clean Blinds\n\n'
	          +'GENERAL\n'
	          +'•	Very thorough dusting throughout the house\n'
	          +'•	All lighting fixtures will be cleaned and washed removing dust and insects\n'
	          +'•   All storeroom cupboards cleaned inside and out Walls will be spot cleaned '
	          +'removing stains and marks\n'
	          +'•	Wipe down doors and doorframes throughout the house\n'
	          +'•	All balconies will be washed down\n'
	          +'•	Clean all windowsills and window tracks throughout the house, '
	          +'and Interior of windows and external windows like balcony door windows '
	          +' (clean inside and out)\n\n'
	          +'Outstanding Rent\n'
	          +'As of today, total outstanding rent owing till your vacate date on '
	          +tenant.Vacating_Date__c + ' is ' + tenant.Arrears__c + '. '
	          +'Please remit payment before your departure.\n'
	          +'If you have any enquiry, please feel to contact Excelsior Team for assistance.\n\n'
              +'Best Regards Excelsior Realty Pty Ltd\n'
              +'Excelsior Team\n'
              +'T + 61 2 9281 6777 F +61 2 9281 2283 E sales@exr.com.au';
     }
     /**
     SMS body that send to tenant regarding Vacating checklist
     **/
     private String tenantSMSBody()
     {
     	return 'Dear Tenant, '
     	       +'RE:' + tenant.H_Property_Address__c
     	       +'  I just sent Vacating Check List to your email('
     	       + tenant.Email__c + '). Please Check your email for more details.'
     	       +'If you have any enquiry, please feel to contact us '
     	       +'on 9281 6777 for assistance. '
     	       +' Best Regards Excelsior Realty ';
     }
     
     /**
     Notification of tenant vacate email body 
     **/
     private String ownerEmailBody()
     {
     	return 'To: ' + tenant.H_Owner_Email__c + '\n'
   	          +'Time: ' + Datetime.now().format('E dd/MM/yyyy hh:mm a') + '\n'
   	          +'Body:\n '
     	       +'Dear Owner,\n'
               + 'Re: ' + tenant.H_Property_Address__c
               +'\nThis is to inform your tenant at the above address has given '
               + 'our agency a notice of vacate effective on ' +  tenant.Vacating_Date__c.format()
               +'\n\nAfter our extensive market research throughout the rental market at '
               +'your local area, we are currently re-listing your property at the rate of $'
               +tenant.Market_Research_Price__c + ' per week. And we shall endeavor our best '
               + 'effort to allocate a most suitable tenant for you. Rent might be reviewed '
               +'for further assessment if there is a necessity.\n\n'
               +'If you have any particular instruction or require a further assistance, '
               +'please do not hesitate to contact us on 02-9281 6777.\n\n'
               +'Yours Faithfully,\n'
               +'Excelsior Realty Pty Ltd';
     }
     
     /**
     Noticification of tenant vacate to owner email body 
     **/
     private String ownerSMSBody()
     {
     	return 'Dear Tenant, '
     	       +'RE:' + tenant.H_Property_Address__c
     	       +' I just sent your notification of tenant vacating to your '
     	       + 'Email(' + tenant.H_Owner_Email__c + '). Please Check your email for more details.'
     	       +'If you have any particular instruction or require a further assistance, '
               +'please do not hesitate to contact us on 02-9281 6777.'
     	       +' Best Regards Excelsior Realty ';
     }
     
     public String getOwnerMobile()
     {
     	return ownerMobile;
     }
     
     @isTest(seeAllData=true) 
     static void tenantVacatingHanlderTest()
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
       Tenant__c testTenant = new Tenant__c(Name = 'Test Tenant',
       									    Property__c = testProperty.id,
       									    Mobile_Phone__c = '0405795363',
       									    Email__c = 'dev@exr.com.au',
       									    Vacating_Date__c = Date.Today().addDays(2),
       									    Market_Research_Price__c = 900,
       									    Arrears__c = 90
       									    );
       	insert testTenant;
       	
       	C_TenantVacatingHandler handler = new C_TenantVacatingHandler(testTenant);
       	
       	/**Test ownerSMSBody() **/
        system.assertEquals(true, handler.ownerSMSBody().contains('6678 Test Building Name Test Street Name Test Suburn NSW 2000'));
        
        /** Test OwnerEmailBody() **/
        system.assertEquals(true, handler.ownerEmailBody().contains('6678 Test Building Name Test Street Name Test Suburn NSW 2000'));
        
        /**Test tenantSMSBody() **/
         system.assertEquals(true,handler.tenantSMSBody().contains('6678 Test Building Name Test Street Name Test Suburn NSW 2000'));
         
        /**Test tenantEmailBody() **/
        system.assertEquals(true,handler.tenantEmailBody().contains('6678 Test Building Name Test Street Name Test Suburn NSW 2000'));
        system.assertEquals(true,handler.tenantEmailBody().contains('dev@exr.com.au'));
        
        /** Test getOwnerDetail() **/
        handler.getOwnerDetail();
        system.assertEquals('0458888888', handler.getOwnerMobile());
        system.assertEquals(true, handler.ownerSMSBody().contains('dev@owner.com'));
        system.assertEquals(true, handler.ownerEmailBody().contains('dev@owner.com'));
        
        /**Test createVacatingEvent()**/
         //test createVacatingEvent when the vacate evnet has not created yet 
        integer beforeCount = [Select count() 
        					  From Event
        					  Where StartDateTime  > :date.today() 
                              And  WhatId = :testTenant.Property__c 
                             ];//before create vacating event count 
       handler.createVacatingEvent();    
       integer afterCount = [Select count() 
        					 From Event
        					 Where StartDateTime  > :date.today() 
                             And  WhatId = :testTenant.Property__c 
                             ];//after creating vacating event count   
       system.assertEquals(1, afterCount - beforeCount); 
       
       //test createVacatingEvent when the vacate event already created 
       handler.createVacatingEvent();    
       beforeCount = afterCount;
       afterCount =  [Select count() 
					 From Event
					 Where StartDateTime  > :date.today() 
                     And  WhatId = :testTenant.Property__c 
                     ];
        system.assertEquals(0, afterCount - beforeCount); 
        
        /**Test informOwner() **/
        handler.informOwner();
        
        /**Test informTenant() **/
        handler.informTenant();
        
        /** Test logFormActitivity **/
        logFormActitivity(testTenant);
     } 
}