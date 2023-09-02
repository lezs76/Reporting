
USE client_scadam
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS(SELECT 1 FROM sys.views WHERE name='v_bpi_Accounts_Receivable_Ageing_Report' and type='v')
drop view v_bpi_Accounts_Receivable_Ageing_Report;
GO
GO
CREATE VIEW v_bpi_Accounts_Receivable_Ageing_Report AS


SELECT 
pro.program as [Program],
fa.accountNumber as [Financial Acct #],
i.invoiceNumber as [Invoice Number],
p.permitnumber as [Permit Number],
p.permitName as [Permit Name],
i.total as [Invice Total],
i.invoiceBalance as [Invoice Balance],
CAST(i.dueDate as DATE) as [Due Date],
c.organization as [Organization],
CONCAT(a.addressline1,' ',a.city,' ',a.state,' ',a.zip) as [Address],
c.CTattentionLine as [Attention Line],
c.CTMcontactEmail as [Email],
c.CTMcontactPhone as [Primary Phone number],
lpc.contactType as [Contact Type],
fs.feeDescription as [Fee Description],
fs.fee as [Fee Amount],
CONCAT(c.firstName,' ',c.lastName) as [Contact Name],
CONCAT(u.firstname,' ',u.lastname) as [Assigned To],
CONCAT(add2.addressline1,' ',add2.city,' ',add2.state,' ',add2.zip) as [Permit Address]




FROM tblInvoices i
LEFT JOIN tblCHLD_Invoices_Fees cif WITH (NOLOCK) on cif.invoicesID = i.invoicesID
LEFT JOIN tblFees f WITH (NOLOCK) on f.feesID = cif.feesID AND f.deleted = 0
LEFT JOIN tblFee_Schedule fs WITH (NOLOCK) on fs.fee_scheduleID = f.fee_scheduleID AND f.deleted = 0
LEFT JOIN tblCHLD_Financial_Account_Invoices fai WITH (NOLOCK) on fai.invoicesID = i.invoicesID
LEFT JOIN tblFinancial_Account fa WITH (NOLOCK) on fa.financial_accountID = fai.financial_accountID AND fa.deleted = 0
LEFT JOIN tblPermit p WITH (NOLOCK) on p.permitID = i.permitID AND p.deleted = 0
LEFT JOIN tblLKP_Permit_Contacts lpc WITH (NOLOCK) on lpc.permitID = p.permitID AND lpc.deleted = 0 AND lpc.contactType LIKE '%Billing%'
LEFT JOIN tblContacts c WITH (NOLOCK) on c.contactsID = lpc.contactsID AND c.deleted = 0 AND c.CTMstatus = 'Active'
LEFT JOIN tblAddress a WITH (NOLOCK) on a.addressID = c.addressID AND a.deleted = 0
LEFT JOIN tblUsers u WITH (NOLOCK) on u.userID = p.recordAssignedToUserID AND u.deleted = 0

LEFT JOIN tblCHLD_Establishment_Permit ep WITH (NOLOCK) on ep.permitID = p.permitID
LEFT JOIN tblCHLD_Address_Establishment ae WITH (NOLOCK) on ae.establishmentID = ep.establishmentID
LEFT JOIN tblAddress add2 WITH (NOLOCK) on add2.addressID = ae.addressID AND add2.deleted = 0
LEFT JOIN tblCFG_Program pro WITH (NOLOCK) on pro.cfg_programID = p.cfg_programID and pro.deleted = 0


WHERE i.deleted = 0

AND i.invoiceBalance > 0

AND i.dueDate <= GETDATE()


