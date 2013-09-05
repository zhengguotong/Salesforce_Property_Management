public with sharing class C_ArrearsHandler 
{
	public final static String SUBJECT = 'Sent Arrear letter to tenant';
	public final static String EMAIL_SUBJECT =' Oustanding Arrears';
	
	private Arrears__c arrear;
    private Tenant__c tenant;
    private String propertyAddress = '';
    private Integer numberOfDays = 0;
    
    public C_ArrearsHandler(Arrears__c arrear)
    {
        this.arrear = arrear;
        setup();
        
    }
  
    /**
    	setup propertyAddress, tenant and number of days
    **/
    private void setup()
    {
    	//get tenant information from database
        tenant = [Select  id, name,Mobile_Phone__c, Email__c, Property__c
                  From Tenant__c
                  Where id = :arrear.Tenant__c
                  Limit 1];
        //set property Address
        propertyAddress = C_Utility.propertyAddress(C_Utility.getProperty(tenant)); 
       //callculate number of days in arrear
       //numberOfDays = arrear.Due_To__c.daysBetween(arrear.Paid_To__c) ; 
       numberOfDays = (Integer) arrear.Number_Of_Days__c; 
    }
    
    /**
       determine which letter should send to the tennant 
       if days is less than 4 then send letter 1
       if days is greater thant 4 and smaller than 14 then 
       send letter 3
    **/
    public void determineAction()
    {
    	if( numberOfDays > 0 && numberOfDays <= 4 )
    	{
    		sendArrearLetter1();
    	}
    	else if(numberOfDays > 4 && numberOfDays <= 14)
    	{
    		sendArrearLetter3();
    	}
    	else 
    	{
    		system.debug('C_ArrearsHandler:Doing Nothing As numbers of days is not between in 1 to 14');
    	}
    }
    
    /**
    send sms arrear letter1 to tenant and record history 
    on the tenant activity history
    **/
    private void sendArrearLetter1()
    {
    	 if (tenant.Mobile_Phone__c != null)
    	 {
    	 	C_SMS.sendSms(tenant.Mobile_Phone__c, tenant.name, arrearLetter1()); 
         	C_Utility.logActivity(SUBJECT,arrearLetter1(), tenant.id); 
    	 }     
    }
    
    /**
    return arrear letter 1 text
    **/
    private String arrearLetter1()
    {
    	return 'Dear Tenant, '
               + 'Re ( ' + propertyAddress +  ') , Our records show your rent has been in arrears for '
               + arrear.Number_of_Days__c  +' days , please make payment of $'
               + arrear.Amount__c + ' immediately to avoid further action from the owner.  Regards Excelsior Realty ';
    }
   
    /**
    send arrear letter 3 by sms and email, 
    Log activity in tenant activity history
    **/
    private void sendArrearLetter3()
    {    
    	 //if teant have mobile phone 
    	 //then send arrear letter 3
    	 //sms to tenant
    	 if(tenant.Mobile_Phone__c != null)
    	 {
    	 	C_SMS.sendSms(tenant.Mobile_Phone__c, tenant.name, arrearLetter3()); 
    	 }
         //if tenant has email address 
         //then also send a copy of arrear letter 3 by email
         if(tenant.Email__c != null)  
         {
         	String[] toAddress = new String[]{tenant.Email__c};
         	C_Email.sendSignleEMail(toAddress,propertyAddress + EMAIL_SUBJECT, letter3HTMLBody());
         }
         C_Utility.logActivity(SUBJECT,arrearLetter3(),tenant.id); 
    }
    
    /**
    return Arrear letter 3 html body
    **/
    private String letter3HTMLBody()
    {
    	return '<html>'
             + '<p>Dear Tenant,</p>'
             +'<p><b>Re: RENT ARREARS</br>'
             + propertyAddress + '</b></p>'
             + '<p>It has come to our attention that your rent is not being paid by the due date.'
             +' Your rent is currently paid to ' + arrear.Paid_To__c.format('d MMM yyyy') + 
             +'.You will recall that it was explained to you when you signed your Tenancy Agreement' 
             + 'that rent MUST be paid in advance.</p>' 
             +'<p>Your Residential Tenancy Agreement states that you are “to pay rent on time”.'
             +'You are therefore clearly in breach of the Agreement by failing to pay your rent on time.,</p>'
             +'<p>As Managing Agent for the above property, we have an obligation to the property '
             + 'owner to ensure that rent is paid on time.</p>'  
             +'<p>Total outstanding rent to ' +  arrear.Due_To__c.format('d MMM yyyy') + ' is $'
             + arrear.Amount__c + ' and payment is required <u>IMMEDIATELY</u>. </p>'
             + '<p><b><u>Should you continue to make rent payments in arrears, our instructions '
             + 'are quite clear and action against you will be considered.</p></b></u>'
             +'<p>Our office does appreciate that tenants can encounter financial hardship '
             + 'from time to time and for this reason we may be able to accommodate a rental '
             + 'repayment plan to pay off the arrears.</p>'
             + '<p>Your cooperation in this matter is in your best interest, and would be appreciated.</p>'
             + '</p>Please contact our office to discuss this matter further.</p>'
             +'<p>Yours faithfully,</br>'
             +'<b><u>Excelsior Realty Pty. Ltd. </b></u></br>'
             + '</br></br>.Property Management Department</p>'
             +'</br></br> <p><font color="red"> T</font>   + 61 2 9281 6777    '
             + '<font color="red">F</font>   +61 2 9281 2283   '
             + '<font color="red">E </font>  rentals@exr.com.au</p>'
             +'</html>';
    }
    
    /**
    return arrear letter 3 text
    **/
    private  String arrearLetter3()
    {
    	return 'Dear Tenant, '
    			+ 'Re ( ' + propertyAddress +  ') ,'
    			+ 'It has come to our attention that your rent is not being paid.'
    			+ 'Your Residential Tenancy Agreement states that you are “to pay rent on time” .' 
    			+ 'You are therefore clearly in breach of the Agreement by failing to pay your rent on time.'
                + 'Total outstanding rent to ' + arrear.Due_To__c.format('d MMM yyyy') 
                +  ' is $' + arrear.Amount__c +' Regards Excelsior Realty ';
    }
    
    
    public Tenant__c getTenant()
    {
    	return tenant;
    }
    
    public String getPropertyAddress()
    {
    	return propertyAddress;
    }
    
    public integer getNumberOfDays()
    {
    	return numberOfDays;
    }
    
    @isTest(seeAllData=true) 
    static void arrearLetter3Test()
    {
    	//create new test owner 
    	Account testOwner = new Account(Name = 'Test Owner'); 
        insert testOwner;
        
        //create new test property 
        Property__c testProperty = new Property__c(Name = 'Test Property',
                                                   Property_Owner__c = testOwner.Id,
                                                   Unit_Number__c = '6678',
                                                   Building_Name__c = 'Test Buiding Name',
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
       									    Email__c = 'dev@exr.com.au');
       	insert testTenant;
       									    
       Arrears__c testArrear = new Arrears__c();
       
       testArrear.Tenant__c = testTenant.id;
       testArrear.Amount__c = 6666;
       testArrear.Number_Of_Days__c = 5;
       testArrear.Paid_To__c = DateTime.now().addDays(2);
       testArrear.Due_To__c = DateTime.now().addMonths(1);
       
       C_ArrearsHandler handler = new C_ArrearsHandler(testArrear);
       
       //test arreaLetter3()
       system.assertEquals(true, handler.arrearLetter3().contains(testArrear.Due_To__c.format('d MMM yyyy')));
       
       //test arreaLetter3HTMLBody()
       system.assertEquals(true, handler.letter3HTMLBody().contains(testArrear.Due_To__c.format('d MMM yyyy'))); 
       
       handler.sendArrearLetter3();
       
       //test arrearLetter1()
       system.assertEquals(true,handler.arrearLetter1().contains(testArrear.Number_Of_Days__c+''));
       
       handler.sendArrearLetter1();
       
       //test when number of days is bigger than 4 days 
       handler.determineAction();
       
       //test setup() 
       handler.setup();
       
       system.assertEquals(testTenant.id, handler.getTenant().id);
       system.assertEquals(5, handler.getNumberOfDays());
       system.assertEquals('6678 Test Buiding Name Test Street Name Test Suburn NSW 2000', handler.getPropertyAddress());
       
       //test determinAction() when number of days is bigger than 0 and samaller than 4
       testArrear.Number_Of_Days__c = 2;
       handler = new C_ArrearsHandler(testArrear);
       
       handler.determineAction();
       
        
       //test determinAction() when number of days is not between 0 and 14
       testArrear.Number_Of_Days__c = 20;
       handler = new C_ArrearsHandler(testArrear);
       
       handler.determineAction();
    }
}