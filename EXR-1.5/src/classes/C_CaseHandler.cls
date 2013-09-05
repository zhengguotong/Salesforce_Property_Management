public virtual class C_CaseHandler
{
	public static final integer DURATION = 15; 
	protected Case repair = new Case();
	protected String propertyAddress;
	protected Account owner;
	protected Tenant__c tenant;
	
	public C_CaseHandler(Case repair)
	{
		this.repair = repair;
		propertyAddress = C_Utility.propertyAddress(getPropertyAddress());
		setup();
	}
	
	/**
	set propertyAddress, owner email address and tenant 
	email address if this repair case these fileds are empty
	**/
	private void setup()
	{
		repair.H_Property_Address__c = propertyAddress;
		
		setOwner();
		if(owner != null)
		{
			repair.H_Owner_Email__c = owner.Email__c;
		}
		
		setTenant();
		if(tenant != null)
		{
			repair.H_Tenant_Email__c = tenant.Email__c;
			repair.H_Tenant_Mobile__c = tenant.Mobile_Phone__c;
	
			repair.H_Tenant_Name__c = tenant.Name;
		}
		
	}
	
	/**
	set owner according to this repair property Id
	**/
	private void setOwner()
	{
		List<Account> owners = [Select Email__c, Mobile_Phone__c,Name
		                        From Account a
		                        Where a.Id  in (Select Property_Owner__C 
                                                From property__c p 
                                                Where p.id = :repair.Property__c)
                               ];
        
        if(owners.size() > 0)
             owner = owners[0];
        else 
            owner = null;                              
	}
	
	/**
	set tenant according to this repair 
	case property address
	**/
	private  void setTenant()
	{
		List<Tenant__c> tenants= [Select Email__c, Mobile_Phone__c , Name 
		                          From Tenant__c
		                          Where Tenant_Status__c = :C_Constant.ACTIVE
		                          And Property__c = :repair.Property__c];
		                          
		if(tenants.size() > 0)
		{
			tenant = tenants[0];
		}
		else 
		{
			tenant = null;
		}	
	}
	
     /** get event list that is related to his case  **/
	public list<Event> getEvents() 
	{
		return [Select StartDateTime, EndDateTime,  Id From Event Where WhatId = :repair.id];
	}
	
	/** create inspection for this inspection case **/
	protected void createEvent(String subject)
	{
		Event event = new Event();
		event.Subject = subject;
		event.StartDateTime = repair.Inspection_Time__c;
		event.EndDateTime = repair.Inspection_Time__c.addMinutes(DURATION);
		event.WhatId = repair.Id;
		
		insert event; 
	}
	
	/** update event startDateTime and endDateTime **/
	protected void updateEvent(Event event)
	{
		event.StartDateTime = repair.Inspection_Time__c;
		event.EndDateTime = repair.Inspection_Time__c.addMinutes(DURATION);
		
		update event;
	}
	
	/**
    update property's last inspection time which is related to this case 
	**/
	protected void upateLastInspectionTime()
	{
		if(repair.Property__c != null)
		{
			Property__c property = [Select Last_Inspection_Date__c 
			                        From Property__c
			                        Where Id = :repair.Property__c
			                        limit 1];
			property.Last_Inspection_Date__c = repair.Inspection_Time__c;
			update property;
		}
	}
	
	/**
	Get property__c object accroding to this 
	repair property__c id 
	**/
	private List<Property__c> getPropertyAddress()
	{
		return [Select Property_Owner__c, Unit_Number__c, Building_Name__c, Street_Number__c,
		               Suburn__c, State__c, Post_Code__c     
		        From Property__c
		        Where Id = :repair.Property__c];
	}
	
	/**
	@return repair case 
	**/
	public case getRepair()
	{
		return repair;
	}
	
	/**
	@return owner of the property related to this 
	        repair case
	**/
	public Account getOwner()
	{
		return owner;
	}
	
	/**
	@return current tenant of the property related to this 
	        repair case
	**/
	public Tenant__c getTenant()
	{
		return tenant;
	}
	
	@isTest 
	public static void createEventTest()
	{
		Case testCase = new Case();
		testCase.Subject = 'Test';
		testCase.Inspection_Time__c = Datetime.now();
		insert testCase;
		
		C_CaseHandler handler = new C_CaseHandler(testCase);
		
		handler.createEvent('Testing');
		
		system.assertEquals(1, [Select count() from Event]);
	}
	
	@isTest 
	public static void getEventsTest() 
	{
		Case testCase = new Case();
		testCase.Subject = 'Test';
		testCase.Inspection_Time__c = Datetime.now();
		insert testCase;
		
		C_CaseHandler handler = new C_CaseHandler(testCase);
		
		system.assertEquals(0, handler.getEvents().size());
	}
	
	@isTest 
	public static void testMehtods()
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
       
       case testCase = new case(Property__c = testProperty.id);
       insert testCase;
       
      
       C_CaseHandler handler = new C_CaseHandler(testCase);
       List<Property__c> actualProperty = handler.getPropertyAddress();
       
       /** Test getPropertyAddress() **/
       system.assertEquals(1, actualProperty.size());
       system.assertEquals(testProperty.Id, actualProperty[0].Id);
       
       /**Test setOwner **/
       handler.setOwner();
       system.assertEquals('dev@owner.com', handler.getOwner().Email__c);
       system.assertEquals('0458888888', handler.getOwner().Mobile_phone__c);
       
       /** Test setTenant **/
       handler.setOwner();
       system.assertEquals('dev@tenant.com.au', handler.getTenant().Email__c);
       system.assertEquals('0412345678', handler.getTenant().Mobile_Phone__c);
       
       /** Test setup() **/
       handler.setup();
       system.assertEquals('6678 Test Building Name Test Street Name Test Suburn NSW 2000', handler.getRepair().H_Property_Address__c);
       system.assertEquals('dev@owner.com', handler.getRepair().H_Owner_Email__c);
       system.assertEquals('dev@tenant.com.au', handler.getRepair().H_Tenant_Email__c);
       system.assertEquals('0412345678', handler.getRepair().H_Tenant_Mobile__c);
       system.assertEquals('Test Tenant', handler.getRepair().H_Tenant_Name__c);
       system.assertEquals(null, handler.getRepair().H_Creditor_Mobile__c);
	}
    
    @isTest 
    public static void updateEventTest()
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
       
       DateTime now = DateTime.now().addDays(2);
       
       Case testCase = new Case(Property__c = testProperty.Id,
                                Inspection_Time__c = now);
       insert testCase;
       
       Event testEvent = new Event();
	   testEvent.Subject = 'Testing';
	   testEvent.StartDateTime = now;
	   testEvent.EndDateTime = now.addMinutes(10);
	   insert testEvent;
       
       C_CaseHandler handler = new C_CaseHandler(testCase);
       handler.updateEvent(testEvent);
	   test.stopTest();
		
       Event actual = [Select StartDateTime 
                       From Event 
                       Where Id = :testEvent.Id];
	            
	   system.assertNotEquals(NULL, actual);
	   system.assertEquals(actual.StartDateTime, now); 
    }
    
	@isTest 
	public static void updateLastInspectionTimeTest()
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
       
       DateTime now = DateTime.now().addDays(2);
       
       Case testCase = new Case(Property__c = testProperty.Id,
                                Inspection_Time__c = now);
       insert testCase;
       
       C_CaseHandler handler = new C_CaseHandler(testCase);
       handler.upateLastInspectionTime();
       
       test.stopTest();
       
       Property__c actual = [Select Last_Inspection_Date__c 
                             From Property__c
                             Where Id = :testProperty.Id 
                             limit 1];
       system.assertNotEquals(null, actual);
       system.assertEquals(actual.Last_Inspection_Date__c, now);                     
	}
}