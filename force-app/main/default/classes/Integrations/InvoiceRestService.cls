@RestResource(UrlMapping='/Invoices/*')
global with sharing class InvoiceRestService {

    @HttpPost
    global static void doCreateInvoice() {
        String jsonPayload = RestContext.request.requestBody.toString();

        Task task = new Task();

        task.ActivityDate = System.today();
        task.Subject = 'invoice was returned';
        task.Description = jsonPayload;

        insert task;
    }
}