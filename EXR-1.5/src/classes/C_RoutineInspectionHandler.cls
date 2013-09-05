public class C_RoutineInspectionHandler extends C_CaseHandler  
{  
	public static final String INFROMED_TIME_SUBJECT  = 'Informed Tenant about Routine Inspection Time';
	public static final String REMINED_TIME_SUBJECT ='Reminded Tenant about inpsection Time';
	public static final String EVENT_SUBJECT = ' Agent Routine Inspection';
	public static final String OWNER_EMAIL_SUBJECT = 'Comprehensive periodic inspection report ';
	
	public C_RoutineInspectionHandler(Case repair)
	{
		super(repair);
	}
	
	
	public void handleInspection()  
	{
		infromedTime();
		remindedTime();
		confirmedTime();
		sendToOwner();
		completedInspection();
	}
	
	/**
	when inspection status is equal to informed time, inspection time is not 
	null and tenant email is not null, then sent  notic enmail to tenannt(this
	is done by workflow) and log activity history under this case history
	**/
	private void infromedTime()
	{
		if(repair.Inspection_Status__c == C_Constant.INFORMED_TIME && 
		  repair.Inspection_Time__c != null && repair.H_Tenant_Email__c != null)
		{
			C_Utility.logActivity(INFROMED_TIME_SUBJECT, informedTimeEmailBody(), repair.Id);
		}
		
	}
	
	/**
	@return Agent routine inspection notice email body
	**/
	private String informedTimeEmailBody()
	{
		return 'Dear Tenant, \n\n'
		       +'This is to inform you that we would like to carry out a '
		       + 'condition inspection for your property recently. Agency '
		       +' is responsible to make sure  that  properties we managed '
		       +'are under good condition and to arrange inspection every '
		       +' six months.\n\n'
		       +'Condition inspection also benefits tenant. Our agent will '
		       +'arrange repairs after inspection whereas tenant  has '
		       +'obligation to report those urgent repairs to our agent during '
		       +'the inspection.\n\n'
		       +'We woud like to carry out this inspection on '
		       + repair.Inspection_Time__c + '\n\n'
		       +'Please make sure you are available during this time. If you '
		       +'want to arranged another time, please reply this email within '
		       +'48 hours. Otherwise fees will be applied.\n\n'
		       +'Please feel free to contact our office if you have anything '
		       +'unsure.\n\n'
		       + 'Thank you for your cooperation in this matter.'
		       +'Kind Regards\n'
               +'Excelsior Realty Pty Ltd';
	}
	
	/**
	When inspection status is equal to reminded time, Inspection time is not null 
	and mobile phone number is not null, then send sms to tenant remind about 
	the inspection time and log sms body under this case
	**/
	private void remindedTime()
	{
		if(repair.Inspection_Status__c == C_Constant.REMINDED_TENANT
		&& repair.Inspection_Time__c != null && repair.H_Tenant_Mobile__c != null)
		{
			C_SMS.sendSms(repair.H_Tenant_Mobile__c,REMINED_TIME_SUBJECT, remindedTimeSMS());
			C_Utility.logActivity(REMINED_TIME_SUBJECT, remindedTimeSMS(), repair.id);
		}
	}
	
	
	private String remindedTimeSMS()
	{
		return 'Dear Tenant, '
		       + 'Re:(' + repair.H_Property_Address__c +  ' Agent Routine Inspection) '
		       + 'Just to remind you that we will carry out an agent routine Inspection on ' 
		       + repair.Inspection_Time__c.format('E dd/MM/yyyy hh:mm a') + '. If you are unavailable during this time,'
		       + 'please let us know immediately. Otherwise fees may be applied. '
		       + 'Kind Regards Excelsior Realty';
	}
	
	/**
	 When this case is routine inspection, inpection_Status__c is equal to 
	 confirmed time and inspection time is not equal to null, then create a new 
	 event if there is not event relate to this case, otherwise update this 
	 event start date time
	**/
	private void confirmedTime()
	{
		if(repair.Inspection_Status__c == C_Constant.CONFRIMED_TIME
		    && repair.Inspection_Time__c != null)
		{
			if(getEvents() == null || getEvents().size() == 0)
			{
				createEvent(C_Utility.NVL(repair.H_Property_Address__c) + EVENT_SUBJECT);
			}
			else 
			{
				updateEvent(getEvents()[0]);
			}
		}
	}
	
	private void sendToOwner()
	{
		 if(repair.Inspection_Status__c == C_Constant.SEND_TO_OWNER 
		    && repair.H_Owner_Email__c != null)
		 { 
		 	//get list of attachement under this case
		 	List<Attachment> attachments = [Select Name, Body
		 									From Attachment 
		 									Where ParentId =: repair.Id
		 	                               ];
	         
	          //when user upload the conidtion report under this case
	          //then attached this report and send to owner
	         if (attachments != null && attachments.size() > 0)
	         {
	         	Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
	    	 	efa.setFileName(attachments[0].Name);
	         	efa.setBody(attachments[0].Body); 
	   
				C_Email.sendAttachmentEmail(new String[]{repair.H_Owner_Email__c}, 
				    OWNER_EMAIL_SUBJECT +repair.H_Property_Address__c,ownerEmail(),efa);
				
				C_Utility.logActivity(OWNER_EMAIL_SUBJECT +repair.H_Property_Address__c,
				   ownerActivityHistory(attachments[0].Name), repair.Id);
				   
				repair.Inspection_Status__c = C_Constant.COMPLETED;
	         }
		 }
		 
	}
	
	private String ownerActivityHistory(String fileName)
	{
		return  'Subject: '+ OWNER_EMAIL_SUBJECT +repair.H_Property_Address__c 
		       +'\nOwner Email: ' + repair.H_Owner_Email__c
		       +'\nTime: ' + DateTime.now().format('E dd/MM/yyyy hh:mm a') +'\n'
		       +'Attachment: ' +fileName
		       +'\nBody:\n'
		       +ownerEmail();
	}
	
	
	private String ownerEmail()
	{
		return 'Dear Owner,\n\n' 
		       + 'This is to advise you that we have done the Periodic Inspection '
		       +'for ' + repair.H_Property_Address__c + 'recently, please find '
		       +'the attachment for your reference.\n\n '
		       +'This report is for your information and thank you for your '
		       + 'attention.\n\n'
		       + 'Please feel free to contact our team if you require further '
		       +'assistance. \n\n'
		       +'Assuring you of our very best service and attention at all times.\n\n' 
		       +'Kind Regards\n'
		       +'Excelsior Realty Pty Ltd\n\n\n'
		       + 'Shop 18,\n'
		       + 'Sussex Centre,\n'
		       + '401 Sussex St\n'
		       + 'Sydney NSW 2000\n'
		       + 'T +612 9281 6777 | F +612 9281 2283\n'
		       + 'rentals@exr.com.au | www.exr.com.au\n';
	}
	
	
	private void completedInspection()
	{
		if(repair.Inspection_Status__c == C_Constant.COMPLETED
		   && repair.Inspection_Time__c != null)
		{
			upateLastInspectionTime();
		}
	}
	
	@isTest 
	public static void informedTimeTest()
	{
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
       
       case testCase = new case(Property__c = testProperty.id,
                                Inspection_Status__c = C_Constant.INFORMED_TIME,
                                Inspection_Time__c = DateTime.now(),
                                H_Tenant_Email__c = 'dev@exr.com.au');
       insert testCase;
       
       	C_RoutineInspectionHandler handler = new C_RoutineInspectionHandler(testCase);
		
		/**Test informedTimeEmailBody **/
		system.assertEquals(true,handler.informedTimeEmailBody().contains(testCase.Inspection_Time__c+''));
		
		/** Test informedTime **/
		handler.infromedTime();
	
		integer taskCount = [Select count() 
		                      From Task
		                      Where WhatId = :testCase.id];
		system.assertEquals(1, taskCount);
		
		/**Test completedInspection **/
		testCase.Inspection_Status__c = C_Constant.COMPLETED;
		update testCase;
		
		handler = new C_RoutineInspectionHandler(testCase);
		handler.completedInspection();
	}
	
	@isTest(seeAllData=true) 
	public static void remindedTenantTest()
	{
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
       
       case testCase = new case(Property__c = testProperty.id,
                                Inspection_Status__c = C_Constant.REMINDED_TENANT,
                                Inspection_Time__c = DateTime.now(),
                                H_Tenant_Mobile__c = '0412345678');
       insert testCase;
       
       	C_RoutineInspectionHandler handler = new C_RoutineInspectionHandler(testCase);
		
       /**Test remindedTimeSMS  **/
		system.assertEquals(true,handler.remindedTimeSMS().contains(testCase.Inspection_Time__c.format('E dd/MM/yyyy hh:mm a')));
		
		/** Test remindedTime **/
		handler.remindedTime();
	
		integer taskCount = [Select count() 
		                      From Task
		                      Where WhatId = :testCase.id];
		system.assertEquals(1, taskCount);
       
	}
	
	@isTest 
	public static void confirmedTimeTest()
	{
		Case testCase = new Case();
		testCase.Type =  C_Constant.ROUTINE_INSPECTION;
		testCase.Inspection_Status__c = C_Constant.CONFRIMED_TIME;
		testCase.Inspection_Time__c = Datetime.now();
		insert testCase;
		//Test when there is not event related to this case 
		C_RoutineInspectionHandler handler = new C_RoutineInspectionHandler(testCase);
		handler.confirmedTime();
		system.assertEquals(1, handler.getEvents().size());
		
		//update inspection time and test whether the 
		//event related to this case is updated
		DateTime now = Datetime.now().addDays(2);
		testCase.Inspection_Time__c = now;
		update testCase;
		
		handler.confirmedTime();
		
		List<Event> event = [Select Id, StartDateTime From event Where WhatId = :testCase.id];
		
		system.assertEquals(1, handler.getEvents().size());
		system.assertEquals(now,event[0].StartDateTime);
		
		handler.handleInspection();
	}
	
	@isTest(seeAllData=true)
	public static void sentToOwnerTest()
	{
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
       
		Case testCase = new Case(Property__c = testProperty.id,
								 Subject = 'Test',
							     Inspection_Status__c = C_Constant.SEND_TO_OWNER,
							     H_Owner_Email__c = 'dev@exr.com',
							     H_Property_Address__c = 'Testing Address');
    	insert testCase;
    	
    	Blob testBlob = Blob.valueof('Test paf');
    	
    	Attachment attachment = new Attachment();
    	attachment.Name = 'Test.pdf';
    	attachment.Body = testBlob;
    	attachment.ParentId = testCase.Id;
    	insert attachment;
    	
    	C_RoutineInspectionHandler handler = new C_RoutineInspectionHandler(testCase);
    	/** Test sendToOwner() **/
        handler.sendToOwner();
		integer taskCount = [Select count() 
		                      From Task
		                      Where WhatId = :testCase.id];
		system.assertEquals(1, taskCount);
		system.assertEquals(C_Constant.COMPLETED, testCase.Inspection_Status__c);
		
		/**Test ownerActivityHistory **/
		system.assertEquals(true, handler.ownerActivityHistory(attachment.Name).contains('Test.pdf'));
		system.assertEquals(true,handler.ownerEmail().contains('6678 Test Building Name Test Street Name Test Suburn NSW 2000'));
	}
	
}