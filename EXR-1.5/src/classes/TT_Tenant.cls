/** 
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=true)  
private class TT_Tenant {

    static testMethod void tenantVacatingTest() {
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
       	
        Test.startTest();	
       	
       	/** test tenant Vacating when tenant vacating status equal Inform Tenant **/
       	testTenant.Vacating_Status__c = 'Inform Tenant';
       	update testTenant;
       	
       	/** test tenant Vacating when tenant vacating status equal Inform Owner**/
       	testTenant.Vacating_Status__c = 'Inform Owner';
       	update testTenant;
       	
        /** test tenant Vacating when tenant vacating status equal Inform Both**/
       	testTenant.Vacating_Status__c = 'Inform Both';
       	update testTenant;
       	
       	/** test tenant Vacating when tenant vacating status equal Send Vacate Form**/
       	testTenant.Vacating_Status__c = 'Send Vacate Form';
       	testTenant.Vacating_Date__c = null;
       	update testTenant; 
       	
       	Test.stopTest();	
    }
    
    static testMethod void rentIncreaseTesting()
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
       									    Rent_Increase_Status__c = 'Processing',
       	                                    Rent_Period__c = 'M1', 
		                                    Pay_to_Date__c = Date.today(),
		                                    H_Owner_Email__c = 'rentals@owner.com.au',
											New_Rent__c = 900
       									    );
       	insert testTenant;
       	
       	Test.startTest();	
       	testTenant.Rent_Increase_Status__c = 'Processing';
       	update testTenant;
       	
       	testTenant.Rent_Increase_Status__c= 'Get Approval';
       	update testTenant;
       	
       	Test.stopTest();
       	
    } 
}