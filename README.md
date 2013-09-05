Salesforce_Property_Management
==============================
Tenant Vacating System Design
1. When Tenant send us email notice to vacate, User can select the vacate status to send Vacate form, then
The system shall send a vacate form to tenant automatically. Log email activity on tenant activity history.
User can check what email address the vacate form was send to, and when was sent.
2. When tenant Confirmed the Vacating date, put the Vacating Date and how many arrear tenant has not
paid
3. After input those things, change the vacating status to inform tenant, then system auto send cleaning
check list to tenant email address, and also inform tenant that cleaning checklist has been sent their email
address by SMS.
3. Log Email and sms body that send to tenant the property activity history.
4. Create tenant Vacate Event
5. When the Marketing research amount is entered and the the vacating status become inform Owner, then
send email to owner regarding the tenant vacating and new advertise price. The System will also auto
send sms to owner told them the tenant Vacating detail is send to their email address, ask them to check
their email address for more details.
6. When Vacating status change to, “inform tenant”, “Inform both” , “send Vacate Form ”or inform owner. the
system will change status to completed. If user wants to inform tenant or owner again, just change the
vacating status again.
7. If user wants to inform tenant and owner at same time, then just change to vacating status to inform both
8. When the vacating date is due, then system will change this tenant status to inactive. (use time base
work flow to achieve this function)
Note:Vacate Status: 1.Send Vacate Form: Send Vacating Form to Tenant
2.Inform Tenant: Send Vacate checklist to tenant and send SMS to tenant
3.Inform Owner: Send Tenant Vacate detail to Owner and also inform them by SMS
4.Inform Both: Inform both Tenant and Owner
5. Completed:Certain task is completed.
Rent Increase System Design
1.When user select the rent period, last pay to date and new rent for this rent increase.
2. If user wants to get approval from owner first, then the user can select the rent increase status to
“Get Approval”, then system will auto send a email to owner about the this rent increase and change
change rent increase status to “Waiting”.
3. If owner does not response this email in five days then, system will auto change the rent increase
status to “Processing”. (This is done by the time base workflow)
4. If owner do not want to increase rent, then just change the rent increase to “Cancelled”.
5. If owner agree to increase the rent and they response in five days, they user need to change the rent
Increase status to “Processing”.
6.When the rent increase status is changed to “Processing” then system will auto send a rent
notification email to tenant and bcc a copy of this email to owner. Then change the rent increase
status to “Completed”
7. System will also send an SMS to tenant to inform tenant to check their email regarding the rent
increase.
8. If user does not want to get approval from owner, user just need to change the rent increase status
to “Processing”.
Notes: Rent Increase Status: Get Approval: Get Approval from owner
Waiting: Wait instruction from owner
Processing: inform tenant about rent increase
Completed: Completed this rent increase
Cancelled: Cancel this rent increase
Showing System Design
1.After we decide the showing time for each property, then we can create new showing.The user need
enter the start time and end time for this inspection and which property this showing is related to. The
advertisement address also required since we do not put all unit no in our advertisement.
2. After enter all details, if the user wants to ask tenant to open the door for inspection, then user need
to select showing status to ‘confirm time’. Then the system will auto send an email and SMS to tenant
to confirm the inspection time. The SMS body will be logged in the showing activity history.
3. After Confirm the inspection time with tenant, then user need to change the inspection time to
‘Informing’, then the system will auto send email and SMS to customer who interest in this property.
All SMS and email body will be logged in the showing activity history and all informed lead status will
changed to “Contacted‘ to indicate this lead already informed.
4. System will also create a show event in the calendar.
5. When need lead created or updated then the system will check whether is there out-coming event
for this property. If yes, then system will auto inform tenant by EMAil and SMS if they have, log all
email body and sms body in the showing activity history, and change this lead status to ‘Contacted’.
6.If the showing time is changed, the user can change the showing status to change time. The system
will auto send an email and sms to the lead, which is belong to this showing, about the change time .
The showing event that already create in the calendar will be changed. System will also log this change
in the showing activity history.
6. When the customer shows up on the showing, operator need to change this customer status to
Qualified ”. After 1 hours, then system will auto send a tenant application form to who has shown up.
7. System will auto change showing status to “Completed”, after showing end time.
8. When showing Status change to “Completed”, then change the lead status belong to this showing
which does not show up , to “open”. Which allow system to auto inform those lead to come next
inspection.
9. When create the showing event, the system will also check the lead record, if this lead is same type,
and the same bedroom,bathroom and parking. Then system will auto inform those lead about the the
showing time.
Message System Design
1.Message system is built to sent mass email or sms to owner, tenant, lead and contact.
2.User can send select two message types(Email or SMS),If email has been select then system will
email to the receipt list: If SMS has been selected,then system will send sms to all receipt. If two types
are selected, then system send email and sms to the receipts.
3. There five groups of receipt(Owners, Tenants, Contacts , sales Lead and rentals lead), user can
specify what group they want to send.
4. In order to make the email and sms working, users also need to put the email body if email message
is selected. And some applied to the SMS body.
Version 0.8 Notes
1. Add Message function to enterprise edition
Version 0.9 Notes
1. Add validation rules on Message Object
? Display error message on the message type field, when message type is empty.
? Display error message on the receipt type field, when receipt is empty
? Display error message on the email body field, when the email message type is selected, and not text
is entered in the email body field (if insert a picture without any text, this error message will also be
displayed)
? Display error message on the sms body field, when the sms message type is selected, and sms body
is not entered.
? Display error message on the From Date Time File, When From Date Time is null and To Date Time
is not null or When To DateTime is null and From Date Time in not null.
2. Add new Functions in the Message objects
? Add four fields on the message object(Building Name, Post Code, From Date Time andTo Date
Time)
? When the building Name is entered and Post Code is empty, the the system will send message to the
tenants and owners(if selected) whose property’s building name is equal to this building Name
? When the Post Code is entered and building name is empty, the send message according to
tenants’ and owners’(if selected) property’s post code
? Otherwise if both post code and building name, the send message depend on these two items.
? When From date time and to date time are entered, the system will select contacts lead within this
time duration.
3. Changed log activity related object on the Message object(log activity on each receipt not on the
message record)
Version 1.0 README
1. Fix System.ListException: List index out of bounds bug on Arrear management system.
2. Fix too much further call exception, on showing sub system.
3. Add Test case to the Apex classes and triggers. All Apex classed and triggers code coverage is 95%.
4. upload package to salesforce
5. As App exchange do not allow time trigger, there are three time trigger in the system is not upload to
package, need to re-write this time base workflow into apex code later on.
Three time base work flow are:
? Change tenant Status to inactive
? Rent increase reminder
? Change showing status to completed
Version 1.3 README
1.fix bug in the Message object, email exception.
2.Add two features in the CandC system.
? When call type is equal to repair, then system will check whether there is outstanding repair for this
property. If there is, then log this call details under this case. Otherwise create a new repair case.
? When call type is equal to bond, then system will check whether there is outstanding bond for this
property. If there is log this call details under this case.
3.Add Repair Functions
? When the case type is equal to repair and status to new, then system will auto create a task for
? rentals.
? When this repair case is equal to approval, owner email is not empty and Estimate cost is not empty,
? then send a repair request to owner and log email body under this repair case activity history.
? When tenant Email is not empty, then send an acknowledgement of repair request to tenant and log
? sms body under this repair case activity history
? When Owner's mobile is not empty, then send a repair request sms to owner's mobile
? and log sms body under this repair case activity history
? When tenant's mobile is not empty, then send a acknowledgment of repair request to tenant's mobile
and log sms body under this repair case activity history
? When the estimate cost is under $300.00 and owner is not apply within 48 hours, the system will auto
change repair status to proceed job order
? When the estimated cost is over $300.00 and owner is not apply within 48 hours, then the system will
send a task to rentals to follow up this repair case.
? When this repair status is equal to proceed job order, and creditor is not empty then send job order to
creditor by emails and sms if they had, and log details under this repair case
? System will auto change repair to wait for repair invoice after sending out the repair job order
? System will also a confirmation email to tenant if tenant has email, also sms tenant when tenant had
provided mobile number to us, and log details under this repair case activity history
Version 1.4 REAME
1. Fix bug on rent increase-invalid email address exception (due to do get owner email address before
send out email)
2. Fix bug on showing event. When create a showing event, the lead type should be the same as
showing type. Sales showing inform those who wants to buy, rentals showing inform those who wants
to lease this property.
3. Fix bug in Arrear, add tenant lookup fitter, only static tenant can be searched.
4. Add routine inspection functions
? Create new Case, and Case type is equal to Routine Inspection.
? Inform Tenant about the Inspection Time, need to enter the time on inspection time column and
change Inspection status to "Inform tenant". The System will auto send email to tenant.
? If tenant do not reply within 48 hours then the system will auto change Inspection Status to Confirmed
Time.
? When the Inspection Status is equal to "Confirmed Time", then system will auto create or update
Event in the calendar.
? 24 hours before the the inspection time, the system will auto change Inspection Status to "Reminded
Tenant".
? When Inspection Status is equal to 'Remind Tenant', then system will auto send a sms to tenant
remind tenant the inspection time.
? 5 hours after the the inspection time, then system will auto change Inspection status to "Finished
Inspection".
? When the condition inspection is finished and wants manager to review the report. Changing
Inspection Status to 'Completed Report". Then system will auto create a task to Manager. Asking Manger
to check the report.
? When manager reviewed the report and wants to sent this inspection report to owner. Just upload the
report under this case and change Inspection Status to "Send to owner", then system will auto send email
to owner with this report.
? After sending the report, system will auto change inspection status to "Completed".
? When inspection Status is "Completed", Then system will update Last Inspection Date for related
Property.
? Monthly Routine Inspection List also available in the Report section. This Report will show the
properties list which Last Inspection Date is greater than six month.
5.Add function for bond Case
? When bond status equals to “inspection” ,then system will auto create new event or update existing
event in calendar.
? When bond status equal to “Completed” and Inspection Time is not empty, then update “Last
Inspection Date” for related property.
6. Changes on C&C
? Display Priority on C&C layout
? Create new Status object to indicate progress of this C&C case.
7. Changes on Message
? Add Status on Message
? User can add attachment under this Message
? After user add attachment than change status to send, system will send email with this attachment.
? After the email is send system auto change status to completed
8. Mobile App
? Contact us page finished, user can submit an email enquiry in contact us page.
Version 1.5 README
Mobile Application
1. Properties
List both current lease and sale properties.
? There are two status in the property record- one is ‘for sales’ and anther one is for ‘for rent’
? When the property status is changed to to “For rent” or change to ‘for sales’, then the system get the
picture photo.
? Tenant this property details will appear in the mobile app.
? If the property is leased and sold out, just change property status to “None‘, then this properties will
remove from the list.
? If user wants to book a inspection, they call click booking a inspection button, then fill in they details,
they the system will auto create a new lead in salesforce and assign a task to us.
2. Services
Services page has three function-Tenant Application , Repair Request and Notice to Vacate.
2.1 Tenant Application
? Tenant can fill out their details in the web form and this web site also allow tenant to submit their
supporting document.
? After applicant Submit the tenant application form then, system will sent a acknowledgement email to
applicant and provide applicant a reference number.
2.2 Repair Request
? Tenant can submit their repair request in the mobile app. they need to enter their property address,
name, best contact number , problem details and photos.
? Tenant System will auto create new repair case in the salesforce and log this repair request details in
under this case.
? The picture tenant submit added to this repair case as an attachments.
2.3 Notice to Vacate
? Tenant can submit a notice to vacate on the mobile form app.
? Tenant need to put their property address, name, best contact name, email , vacating date and any
message they we us to pay attention.
? Then system auto create a vacating case in salesforce, and log all message details under this case.
? Tenant system will auto send notice to vacate form to tenant.
