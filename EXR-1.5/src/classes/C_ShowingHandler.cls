public virtual  class C_ShowingHandler 
{
	public static String SMS_SUBJECT = 'Inform customer showing time by SMS';
	public static String EMAIL_SUBJECT = 'Inform customer showing time by Email';
	protected Showing__c showing; 
    protected String propertyAddress;
    protected Property__c property;
    
    public C_ShowingHandler (Showing__c showing)
    {
    	this.showing = showing;
    	setProperty();
    }
    
    public C_ShowingHandler()
    {
    	 
    } 
    
    /**
    set property object and propetyAddress 
    **/
    protected void setProperty()
    {
    	property = [Select Id, Location__c, BedRoom__c,Bathroom__c,Parking__c,
                           Weekly_Rentals__c, Furniture__c, Sale_Price__c,
                           Unit_Number__c,Building_Name__c,Street_Number__c,
    	                   Suburn__c,State__c,Post_Code__c
    			    From Property__c 
    			    Where id = :showing.Property__c
    			   ];
    	propertyAddress = C_Utility.propertyAddress(property);
    }
    
    
    
    /**
         get single showing email 
    **/
    protected  Messaging.SingleEmailMessage getEmail(String[] toAddresses)
    {
    	Messaging.SingleEmailMessage mail = 
                            new Messaging.SingleEmailMessage();
                            
       mail.setToAddresses(toAddresses);
       mail.setCcAddresses(C_Constant.RENTALS_EMAIL);
       mail.setSubject(propertyAddress + ' open inspection');
       mail.setHtmlBody(getEmailBody());
       
       return mail;
    }
    
    /**
    get showing email body  
    **/
    private String getEmailBody()
    {
    	String htmlBody = '<html>Dear Customers,<br><br>' 
                        + propertyAddress  + '<br>'
		                +' will be open for inspection on <br>'
		                + showing.Start_Date_Time__c.format('E dd/MM/yyyy hh:mm a')
		                + '<br> Please refer to www.exr.com.au for more details.'
		                +  '<br><br>Looking forward to seeing you.'
		                + '<br><br>Excelsior Realty Pty Ltd'
		                + '<br>Tel: 02-9281 6777'
		                + '</html>';
        return htmlBody;
   }
   
   /**
   	 get Activity history description 
   **/
   private String getDescription(String toAddress)
   {
   		String description = 'To: ' + toAddress + '\n'
   	                        +'Time: ' + Datetime.now().format('E dd/MM/yyyy hh:mm a') + '\n'
   	                        +'Body:\n '
   	                        +'Dear Customers,\n\n' 
                            + propertyAddress  + '\n'
		                    + ' will be open for inspection on \n'
		                    + showing.Start_Date_Time__c.format('E dd/MM/yyyy hh:mm a')
		                    + '\n Please refer to www.exr.com.au for more details.'
		                    +  '\n\nLooking forward to seeing you.'
		                    + '\n\nExcelsior Realty Pty Ltd'
		                    + '\nTel: 02-9281 6777';
	    return description;
   }
   
   protected void sendSMS(Lead superlead)
   {
   	   if(superlead.MobilePhone != null )
   	   {
   	   	  C_SMS.sendSms(superlead.MobilePhone, superlead.Name, getSmsBody());
   	   	  C_Utility.logActivity(SMS_SUBJECT,activityDescription(superlead.MobilePhone), showing.id);
   	   }
   }
   
   protected String activityDescription(String toAddress)
   {
   	   return 'Receipt:' + toAddress + '\n'
   	           + getSmsBody();
   }
   /**
   set sms body, inform custmer about the inspection time
   **/
   protected String getSmsBody()
   {
   	  String smsBody = '';
   	  smsBody += 'Dear Customers,  ' 
            	+ propertyAddress  +' '
                + ' will be open for inspection on '
                + showing.Start_Date_Time__c.format('E dd/MM/yyyy hh:mm a')
                + ' Please refer to www.exr.com.au for more details. '
                +  ' Looking forward to seeing you.'
                + ' Excelsior Realty Pty Ltd '
  	            + ' Tel: 02-9281 6777 ';
	  return smsBody; 
   }
 
   public Showing__c getShowing()
   {
   	  return showing;
   }
   
   public String getProperyAddress()
   {
   	  return propertyAddress;
   }
   
   public Property__c getProperty()
   {
   	  return property;
   }
   
   @isTest 
   static void getEmailTest()
   {
   		 //create new property object 
   		 Property__c testProperty = new Property__c(Location__c = 'Western Suburb',
   		 										    BedRoom__c = '5',
   		 										    Bathroom__c= '5',
   		 										    Parking__c = '3',
                                                    Weekly_Rentals__c = 900,
                                                    Furniture__c = 'Unfurinished',
                                                    Sale_Price__c = 2000000.00,
                                                    Unit_Number__c = '98',
                                                    Building_Name__c = 'Testing Building Name',
                                                    Street_Number__c = '98',
                                                    Suburn__c = 'Testing Suburn',
                                                    State__c = 'Test State',
                                                    Post_Code__c = '5168');
        insert testProperty;
        
        //create new showing object 
        Showing__c testShowing = new Showing__c();
        testShowing.Start_Date_Time__c = DateTime.now().addDays(1);
        testShowing.End_Date_Time__c = DateTime.now().addDays(2);
        testShowing.Name = 'Testing';
        testShowing.Property__c = testProperty.id;
        testShowing.Status__c ='Informing';
        
        C_ShowingHandler handler = new C_ShowingHandler(testShowing);
        
        //test getEmail method
        String[] toAddresses = new String[]{'dev@exr.com.au'}; 
        
        Messaging.SingleEmailMessage mail = handler.getEmail(toAddresses);
        
        system.assertEquals(toAddresses, mail.getToAddresses());
   }
   
   @isTest 
   static void getterMethodsTest()
   {
   		 //create new property object 
   		 Property__c testProperty = new Property__c(Location__c = 'Western Suburb',
   		 										    BedRoom__c = '5',
   		 										    Bathroom__c= '5',
   		 										    Parking__c = '3',
                                                    Weekly_Rentals__c = 900,
                                                    Furniture__c = 'Unfurinished',
                                                    Sale_Price__c = 2000000.00,
                                                    Unit_Number__c = '98',
                                                    Building_Name__c = 'Testing Building Name',
                                                    Street_Number__c = '98',
                                                    Suburn__c = 'Testing Suburn',
                                                    State__c = 'Test State',
                                                    Post_Code__c = '5168');
        insert testProperty;
        
        //create new showing object 
        Showing__c testShowing = new Showing__c();
        testShowing.Start_Date_Time__c = DateTime.now().addDays(1);
        testShowing.End_Date_Time__c = DateTime.now().addDays(2);
        testShowing.Name = 'Testing';
        testShowing.Property__c = testProperty.id;
        testShowing.Status__c ='Informing';
        insert testShowing;
       
        C_ShowingHandler handler = new C_ShowingHandler(testShowing);
        
       //Test getEmail Method 
        String actual = handler.getEmailBody();
        System.assertEquals(true, actual.contains('98 Testing Building Name 98 Testing Suburn Test State 5168'));
        
        //Test getDescription Method
        actual = handler.getDescription('Testing');
        System.assertEquals(true, actual.contains('98 Testing Building Name 98 Testing Suburn Test State 5168'));
        
        //test activityDescription
        actual = handler.activityDescription('dev@exr.com.au');
        System.assertEquals(true, actual.contains('dev@exr.com.au'));
        
        //test getSmsBody
        actual = handler.getSmsBody();
        System.assertEquals(true, actual.contains('98 Testing Building Name 98 Testing Suburn Test State 5168'));
        
        //test setProperty
        handler.setProperty();
        System.assertEquals(testProperty.Id, handler.getProperty().Id);
        System.assertEquals('98 Testing Building Name 98 Testing Suburn Test State 5168', handler.getProperyAddress());
   }
   
   
   @isTest(seeAllData=true)  
   static void getDescriptionTest()
   {
   		 //create new property object 
   		 Property__c testProperty = new Property__c(Location__c = 'Western Suburb',
   		 										    BedRoom__c = '5',
   		 										    Bathroom__c= '5',
   		 										    Parking__c = '3',
                                                    Weekly_Rentals__c = 900,
                                                    Furniture__c = 'Unfurinished',
                                                    Sale_Price__c = 2000000.00,
                                                    Unit_Number__c = '98',
                                                    Building_Name__c = 'Testing Building Name',
                                                    Street_Number__c = '98',
                                                    Suburn__c = 'Testing Suburn',
                                                    State__c = 'Test State',
                                                    Post_Code__c = '5168');
        insert testProperty;
        
        //create new showing object 
        Showing__c testShowing = new Showing__c();
        testShowing.Start_Date_Time__c = DateTime.now().addDays(1);
        testShowing.End_Date_Time__c = DateTime.now().addDays(2);
        testShowing.Name = 'Testing';
        testShowing.Property__c = testProperty.id;
        testShowing.Status__c ='Informing';
        insert testShowing;
        
        Lead testLead = new Lead(LastName = 'Testing',
        						Company = 'Testing', 
        						MobilePhone = '0405795363',
        						Email = 'dev@exr.com.au'
        						);
        insert testLead;
        
        C_ShowingHandler handler = new C_ShowingHandler(testShowing);
        handler.sendSMS(testlead);
   }
}