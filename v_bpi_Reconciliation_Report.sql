USE client_scarap

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT 1 FROM sys.views WHERE name='v_bpi_Reconciliation_Report' and type='v')
drop view v_bpi_Reconciliation_Report;
GO

GO

CREATE VIEW v_bpi_Reconciliation_Report AS

WITH accouting as 
(

SELECT
'Invoice' as [Transaction Type],
CAST (i.invoiceDate as Date) as filterdate,
NULL AS [Payment Date],
CAST (i.invoiceDate as Date) as [Invoice Date],
fs.GLAccountNo2 as [GL Account 2],
fs.GLAccountNo [GL Account No],
CASE WHEN feeAmount is null THEN null ELSE f.feeAmount END as [Fee Amount Credit],
i.invoiceNumber as [Invoice Number],
'' as [Payment Method],
'' as [Receipt Number],
fa.accountNumber as [Account Number],
fs.feeCategory as [Fee Category],
null as [Payment Entered By],
fs.feeCategory as [Cost Center Description],
fs.feeDescription as [Fee Description],
null as [Location],
null as [Refund Reason],
null as [Reversal Reason],
null as [Transaction Date - HS Pay],
null as [Transaction Status - HS Pay],
null as [Transaction ID]

 

FROM tblInvoices i
INNER JOIN tblCHLD_Invoices_Fees clf WITH (NOLOCK) on clf.invoicesID = i.invoicesID
INNER JOIN tblFees f WITH (NOLOCK) on f.feesID = clf.feesID AND f.deleted = 0
INNER JOIN tblFee_Schedule fs WITH (NOLOCK) on fs.fee_scheduleID = f.fee_scheduleID AND fs.deleted = 0
LEFT JOIN tblCHLD_Financial_Account_Invoices fai WITH (NOLOCK) on fai.invoicesID = i.invoicesID
LEFT JOIN tblFinancial_Account fa WITH (NOLOCK) on fa.financial_accountID = fai.financial_accountID

WHERE i.deleted = 0



UNION ALL

SELECT
'Fee Reversed' as [Transaction Type],
CAST (fr1.reverseDate as Date) as filterdate,
NULL AS [Payment Date],
CAST (fr1.reverseDate as Date) as invoiceDate,
fs1.GLAccountNo2 as [GL Account 2],
fs1.GLAccountNo [GL Account No],
CASE WHEN feeAmount is null THEN null  WHEN f1.isReversed = 1 THEN CONCAT('-',f1.feeAmount) ELSE f1.feeAmount END as [Fee Amount Credit],
i1.invoiceNumber,
'' as paymentMethod,
'' as receiptNumber,
fa1.accountNumber as [Account Number],
fs1.feeCategory as [Fee Category],
null as [Payment Entered By],
fs1.feeCategory as [Cost Center],
fs1.feeDescription as [Fee Description],
null as [Location],
null as [Refund Reason],
f1.reversalReason as [Reversal Reason],
null as [Transaction Date - HS Pay],
null as [Transaction Status - HS Pay],
null as [Transaction ID]


 

FROM tblInvoices i1
INNER JOIN tblCHLD_Invoices_Fees clf1 WITH (NOLOCK) on clf1.invoicesID = i1.invoicesID
INNER JOIN tblFees f1 WITH (NOLOCK) on f1.feesID = clf1.feesID AND f1.deleted = 0 
INNER JOIN tblFee_Schedule fs1 WITH (NOLOCK) on fs1.fee_scheduleID = f1.fee_scheduleID AND fs1.deleted = 0
INNER JOIN tblFees_Reverses fr1 WITH (NOLOCK) on fr1.feesID = f1.feesID
LEFT JOIN tblCHLD_Financial_Account_Invoices fai1 WITH (NOLOCK) on fai1.invoicesID = i1.invoicesID
LEFT JOIN tblFinancial_Account fa1 WITH (NOLOCK) on fa1.financial_accountID = fai1.financial_accountID

WHERE i1.deleted = 0

AND f1.isReversed = 1


UNION ALL

SELECT
'Payments' as [Transaction Type],
CAST (p2.paymentDate as Date) as filterdate,
CAST (p2.paymentDate as Date) as paymentDate,
null as invoiceDate,
fs2.GLAccountNo2 as [GL Account 2],
fs2.GLAccountNo [GL Account No],
pf2.amount,
i2.invoiceNumber,
p2.paymentMethod,
p2.receiptNumber,
fa2.accountNumber as [Account Number],
fs2.feeCategory as [Fee Category],
CONCAT(u.firstName,' ',u.lastName) as [Payment Entered By],
fs2.feeCategory as [Cost Center],
fs2.feeDescription as [Fee Description],
p2.Location as [Location],
null as [Refund Reason],
null as [Reversal Reason],
CAST(p2.TransactionDate as Date) as [Transaction Date - HS Pay],
p2.TransactionStatus as [Transaction Status - HS Pay],
p2.TransactionID as [Transaction ID]


from tblPayments p2 WITH(NOLOCK) 
INNER join tblLKP_Payments_Fees pf2 WITH(NOLOCK)on p2.paymentsID = pf2.paymentsID
INNER JOIN tblFees f2 WITH (NOLOCK) on f2.feesID = pf2.feesID AND f2.deleted = 0
INNER JOIN tblFee_Schedule fs2 WITH (NOLOCK) on fs2.fee_scheduleID = f2.fee_scheduleID AND fs2.deleted = 0
INNER JOIN tblCHLD_Invoices_Fees clf2 WITH (NOLOCK) on clf2.feesID = f2.feesID
INNER JOIN tblInvoices i2 WITH (NOLOCK) on i2.invoicesID = clf2.invoicesID
LEFT JOIN tblusers u WITH (NOLOCK) on u.userID = p2.userID AND u.deleted = 0
LEFT JOIN tblCHLD_Financial_Account_Payments fap2 WITH (NOLOCK) on fap2.paymentsID = p2.paymentsID 
LEFT JOIN tblFinancial_Account fa2 WITH (NOLOCK) on fa2.financial_accountID = fap2.financial_accountID and fa2.deleted = 0


WHERE p2.deleted = 0


UNION ALL

SELECT
'Payment Reversal' as [Transaction Type],
CAST (pr3.reverseDate as Date) as filterdate,
CAST (pr3.reverseDate as Date) as paymentDate,
null as invoiceDate,
fs3.GLAccountNo2 as [GL Account 2],
fs3.GLAccountNo [GL Account No],
CASE WHEN p3.isReversed = 1 THEN CONCAT('-',pf3.amount) ELSE pf3.amount END as amount,
i3.invoiceNumber,
p3.paymentMethod,
p3.receiptNumber,
fa3.accountNumber as [Account Number],
fs3.feeCategory as [Fee Category], 
null as [Payment Entered By],
fs3.feeCategory as [Cost Center],
fs3.feeDescription as [Fee Description],
null as [Location],
null as [Refund Reason],
pr3.comment as [Reversal Reason],
null as [Transaction Date - HS Pay],
null as [Transaction Status - HS Pay],
null as [Transaction ID]


from tblPayments p3 WITH(NOLOCK) 
LEFT join tblLKP_Payments_Fees pf3 WITH(NOLOCK) on p3.paymentsID = pf3.paymentsID
LEFT JOIN tblFees f3 WITH (NOLOCK) on f3.feesID = pf3.feesID AND f3.deleted = 0
LEFT JOIN tblFee_Schedule fs3 WITH (NOLOCK) on fs3.fee_scheduleID = f3.fee_scheduleID AND fs3.deleted = 0
LEFT JOIN tblCHLD_Invoices_Fees clf3 WITH (NOLOCK) on clf3.feesID = f3.feesID
LEFT JOIN tblInvoices i3 WITH (NOLOCK) on i3.invoicesID = clf3.invoicesID
LEFT JOIN tblPayments_Reverses pr3 WITH (NOLOCK) on pr3.paymentsID = pf3.paymentsID AND pr3.deleted = 0
LEFT JOIN tblCHLD_Financial_Account_Payments fap3 WITH (NOLOCK) on fap3.paymentsID = p3.paymentsID 
LEFT JOIN tblFinancial_Account fa3 WITH (NOLOCK) on fa3.financial_accountID = fap3.financial_accountID and fa3.deleted = 0

WHERE p3.deleted = 0 

AND p3.isReversed = 1

AND i3.invoiceNumber IS NOT NULL

UNION ALL

SELECT
'Payment Refund' as [Transaction Type],
CAST (pr4.refundDate as Date) as filterdate,
CAST (pr4.refundDate as Date) as paymentDate,
null as invoiceDate,
fs4.GLAccountNo2 as [GL Account 2],
fs4.GLAccountNo [GL Account No],
CASE WHEN p4.isRefunded = 1 THEN CONCAT('-',pf4.amount) ELSE pf4.amount END as amount,
i4.invoiceNumber,
p4.paymentMethod,
p4.receiptNumber,
fa4.accountNumber as [Account Number],
fs4.feeCategory as [Fee Category],
null as [Payment Entered By],
fs4.feeCategory as [Cost Center],
fs4.feeDescription as [Fee Description],
null as [Location],
pr4.comment as [Refund Reason],
null as [Reversal Reason],
null as [Transaction Date - HS Pay],
null as [Transaction Status - HS Pay],
null as [Transaction ID]


from tblPayments p4 WITH(NOLOCK) 
LEFT join tblLKP_Payments_Fees pf4 WITH(NOLOCK) on p4.paymentsID = pf4.paymentsID
LEFT JOIN tblFees f4 WITH (NOLOCK) on f4.feesID = pf4.feesID AND f4.deleted = 0
LEFT JOIN tblFee_Schedule fs4 WITH (NOLOCK) on fs4.fee_scheduleID = f4.fee_scheduleID AND fs4.deleted = 0
LEFT JOIN tblCHLD_Invoices_Fees clf4 WITH (NOLOCK) on clf4.feesID = f4.feesID
LEFT JOIN tblInvoices i4 WITH (NOLOCK) on i4.invoicesID = clf4.invoicesID
LEFT JOIN tblPayments_Refunds pr4 WITH (NOLOCK) on pr4.paymentsID = pf4.paymentsID AND pr4.deleted = 0
LEFT JOIN tblCHLD_Financial_Account_Payments fap4 WITH (NOLOCK) on fap4.paymentsID = p4.paymentsID 
LEFT JOIN tblFinancial_Account fa4 WITH (NOLOCK) on fa4.financial_accountID = fap4.financial_accountID and fa4.deleted = 0


WHERE p4.deleted = 0 

AND p4.isRefunded = 1

AND i4.invoiceNumber IS NOT NULL



)

SELECT 



[Transaction Type],
filterdate,
[Payment Date],
[Invoice Date],
[GL Account 2],
[GL Account No],
[Fee Amount Credit],
[Invoice Number],
[Payment Method],
[Receipt Number],
[Account Number],
[Fee Category],
[Payment Entered By],
[Cost Center Description],
[Fee Description],
[Location],
[Refund Reason],
[Reversal Reason],
[Transaction Date - HS Pay],
[Transaction Status - HS Pay],
[Transaction ID],
CASE WHEN [Payment Method] IN ('Credit Card', 'ACH') THEN [Fee Amount Credit] * 0.0349 END as [Processing Fee]






FROM accouting


