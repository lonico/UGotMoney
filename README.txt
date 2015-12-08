My wife has a small private practice.  Though she keeps an excel spreadsheet for her accounting, she'd appreciate something more mobile and simpler for quick data entry.

The main screen provides a quick way to record a transaction with a few selectable fields:
-) payment date (defaults to today's date)
-) client name (required)
-) amount paid (required)
-) payment type (required)
-) ICD-10 (optional)
-) service date (defaults to payment date)
-) Notes (optional)

The field values are prepopulated and are selected using name pickers.  No typing is required, except for the notes field which is free format.
Once the values are entered, the Save button will store the data using IOS CoreData.

In order to use the app, the user will first need to set up some clients, some fees and some payment types (and optionally ICD-10 values).
This is achieved using the "Edit" button.  An accessory button is shown for the editable values.  For fees (amout paid), a number is expected, for payment type a simple string is expected (eg cash, check, credit card, square, ...), for clients, firstname and lastname are required.  The client information is stored using IOS CoreData.  The fee and payment types are stored locally using NSUserDefaults.

For ICD-10, a lookup is performed using an internet database (aqua.io).  If the code is known, it can be looked up directly,  The app stores locally the codes and descriptions using NSUserDefaults.  A search function is also available, it enables partial searches on the code and/or description.  The app can fetch and show most information about an ICD-10 code.  (The International Classification of Diseases (ICD) is the standard diagnostic tool for epidemiology, health management and clinical purposes: http://www.who.int/classifications/icd/en/ ).
(For instance, use F33.1 for look-up, or F33 for a search.)

Once data is entered, it can be visualized in two ways:
1) a list of all transactions (organize icon) sorted by payment date.  A summary for each transaction is presented in a table.  If a transaction is selected, a detail view is presented.
2) a list of clients (bookmark icon) sorted by most recently added client.  Selecting a client will show a table with a list of transactions for this client, sorted by payment date.  A summary for each transaction is presented in a table.  If a transaction is selected, a detail view is presented.

The transaction data can be exported to iCloud Drive.  This can be used to import the data in Numbers, or attach it to an email in iCloud Drive.  For privacy, the client names are not exported, only a numeric id that is also visible in the client list (bookmark icon in main screen).  The transactions can be exported either as a whole (from the transaction list), or for one client (from the transactions list for this client).

Housekeeping: the values for fees and payment types can be reordered (eg moving the most used ones to the top). And they can be deleted.  This will not impact already recorded transactions.
Clients can be deleted, but this will not actually delete the client record: the record is marked as inactive, and the client name will not appear as a choice when creating a new transaction.  The records for this client will still show in the transaction list.  The client still shows in the client list (bookmark) but is greyed out.  This enables access to this client's existing transactions.  If a client is added with the same name, the existing record is reused and marked as active (a client coming back a period of inactivity).

When exporting to iCloud Drive, .csv files are created under the UGotMoney folder.  Either as transaction.csv for all transactions or transactions_<id>.csv for a client transaction.  The id value can be seen in the client view.

Key features:
1) quickly enter transactions with no typing (except for notes)
2) values are predefined by the end users (with add, reorder and delete actions)
3) access to Internet ICD10 database to lookup and search codes
4) review existing transactions (all or for a client)
5) export data to iCloud drive


Building the app:
The code is in GitHub.  For simplicity I included the credentials to access the ICD-10 APIs (aqua.io).
You need the correct entitlements for iCloud Drive, but they should be part of the project.

Running the app:
Upon starting the app, you need to create a few values for clients, payment types and fees.  That's enough to create a few transactions.  Use the "edit" button, and the accessory buttons.
To create ICDs, use the + button from the ICD-10 table.  A default empty value is provided.  There is a limit of 100 free queries per day.  Some valid values are f33, f33.4, f33.42, F43.21.
In order to use iCloud Drive, it needs to be enabled on the iPhone or simulator.  Files can be exported through the action button in the transaction lists.


