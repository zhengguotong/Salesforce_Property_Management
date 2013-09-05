public with sharing class C_Constant
{
	public final static String[] RENTALS_EMAIL = new String[]{'rentals@exr.com.au', 'dev@exr.com.au'};
    public final static String[] MANAGER_EMAIL = new String[]{'awu@exr.com.au'};
    public final static String RENTALS = 'rentals@exr.com.au';
    public final static String SMS_SENDER_ID = '0423789382';
    
    /** Tenant Status **/
    public final static String ACTIVE = 'Active';
    public final static String Inactive = 'Inactive';
    
    //Rent Increase Status
    public final static String GET_APPROVAL = 'Get Approval';
    public final static String PROCESSING = 'Processing';
    public final static String COMPLETED = 'Completed';
    public final static String WAITING = 'Waiting';
   
    //call category 
    public final static String RENTING ='Renting';
    public final static String BUYING = 'Buying';
    public final static String MANAGEMENT = 'Management';
    public final static String SALE = 'Sales';
    public final static String OWNER ='Owner';
    public final static String TENANT ='Tenant';
    public final static String OTHER ='Other';
    
    //Prority 
    public final static String HIGH = 'High';
    public final static String MEDIUM = 'Medium';
    public final static String LOW = 'Low';
    
    //lead Type 
    public final static String PHONE = 'Phone';
    public final static String EMAIL = 'Email';
    
    //lead Status 
    public final static String OPEN = 'Open';
    public final static String CONTACTED= 'Contacted';
    public final static String QUALIFIED = 'Qualified';
    public final static String UNQUALIFIED ='Unqualified';
    
    //Showing Status 
    public final static String INFORMING = 'Informing';
    public final static String CHANGE_TIME = 'Change Time';
    public final static String CANCELLED = 'Cancelled';
    public final static String RE_OPEN_LEAD = 'Re-Open Lead';
    public final static String CALL = 'Call';
    
    //Vacating Status 
    public final static String INFORM_TENANT = 'Inform Tenant';
    public final static String INFORM_OWNER = 'Inform Owner';
    public final static String INFORM_BOTH = 'Inform Both';
    public final static String SEND_VACATE_FORM = 'Send Vacate Form'; 
    
    //showing Type
    public final static String SHOWING_RENTALS = 'Rentals';
    public final static String SHOWING_SAlES = 'SALES';
    
    //weekly renatal rage
    public final static String WR_FIVE = '$400.00 - $500.00';
    public final static String WR_SIX = '$500.00 - $600.00';
    public final static String WR_SEVEN = '$600.00 - $700.00';
    public final static String WR_EGHIT = '$700.00 - $800.00';
    public final static String WR_NINE = '$800.00 - $900.00';
    public final static String WR_TEN = '$900.00 - $1,000.00';
    public final static String WR_TEN_PlUS = '$1,000.00+';   
    
    /** Repair Case Status **/
    public final static String REPAIR = 'Repair'; 
    public final static String NEWCASE = 'New';
    public final static String APPROVAl = 'Get Owner Approval';
    public final static String PROCEED_JOB = 'Proceed Job order';
    
    
    /** Routine Inspection Status **/
    public final static String ARRANGED_TIME = 'Arranged Time';
    public final static String ROUTINE_INSPECTION = 'Routine Inspection';
    public final static String CONFRIMED_TIME = 'Confirmed Time';
    public final static String INFORMED_TIME = 'Informed Time';
    public final static String REMINDED_TENANT = 'Reminded Tenant';
    public final static String SEND_TO_OWNER = 'Send to Owner'; 
    
    /** Bond Case Status **/
    public final static String INSPECTION = 'Inspection';
    public final static String BOND = 'Bond';
    
    /** Case Type **/
    public final static String APPLICATION = 'Application';
    public final static String VACATING = 'Vacating';
    public final static String PROBLEM = 'Problem';
    
    public final static String NOT_STARTED = 'Not Started';
    
    public final static String FOR_RENT =  'For Rent';
    public final static string FOR_SALE = 'For Sale';
}