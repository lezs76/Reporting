/*
This view is used for EH Financial Report. The client wanted to change the name of the report but I kept the view as the original name


*/



USE client_scadam
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS(SELECT 1 FROM sys.views WHERE name='v_bpi_Accounting' and type='v')
drop view v_bpi_Accounting;
GO
GO
CREATE VIEW v_bpi_Accounting AS

WITH accouting as 
(

SELECT
'Invoice' as [Transaction Type],
CAST(i.invoiceDate as date) as filterdate,
CAST (i.invoiceDate as Date) as invoiceDate,
fs.GLAccountNo2 as [Accrual And Payment GL Debit],
fs.GLAccountNo [Accrual And Payment GL Credit],
CASE WHEN feeAmount is null THEN 0  
--WHEN f.isReversed = 1 THEN CONCAT('-',f.feeAmount) 
ELSE f.feeAmount
END as [Fee Amount Credit],
i.invoiceNumber,
null as Paymentdate,
'' as paymentMethod,
'' as receiptNumber,
CAST(f.feesID as varchar(73)) as uniqueid

 

FROM tblInvoices i
INNER JOIN tblCHLD_Invoices_Fees clf WITH (NOLOCK) on clf.invoicesID = i.invoicesID
INNER JOIN tblFees f WITH (NOLOCK) on f.feesID = clf.feesID AND f.deleted = 0 --AND f.isReversed = 0
INNER JOIN tblFee_Schedule fs WITH (NOLOCK) on fs.fee_scheduleID = f.fee_scheduleID AND fs.deleted = 0
WHERE i.deleted = 0



UNION ALL

SELECT
'Fee Reversed' as [Transaction Type],
CAST(fr1.reverseDate as date) as filterdate,
CAST (fr1.reverseDate as Date) as invoiceDate,
fs1.GLAccountNo2 as [Accrual And Payment GL Debit],
fs1.GLAccountNo [Accrual And Payment GL Credit],
CASE WHEN feeAmount is null THEN 0  
WHEN f1.isReversed = 1 THEN CONCAT('-',f1.feeAmount) 
ELSE f1.feeAmount
END as [Fee Amount Credit],
i1.invoiceNumber,
null as Paymentdate,
'' as paymentMethod,
'' as receiptNumber,
CAST(fr1.reversesID as varchar(73))


 

FROM tblInvoices i1
INNER JOIN tblCHLD_Invoices_Fees clf1 WITH (NOLOCK) on clf1.invoicesID = i1.invoicesID
INNER JOIN tblFees f1 WITH (NOLOCK) on f1.feesID = clf1.feesID AND f1.deleted = 0 
INNER JOIN tblFee_Schedule fs1 WITH (NOLOCK) on fs1.fee_scheduleID = f1.fee_scheduleID AND fs1.deleted = 0
INNER JOIN tblFees_Reverses fr1 WITH (NOLOCK) on fr1.feesID = f1.feesID

WHERE i1.deleted = 0

AND f1.isReversed = 1


UNION ALL

SELECT
'Payments' as [Transaction Type],
CAST(p2.paymentDate as DATE) as filterdate,
null as invoiceDate,
p2.glAccountPM2,
p2.glAccountPM,
--CASE WHEN p2.isReversed = 1 THEN CONCAT('-',pf2.amount) ELSE pf2.amount END as amount,

pf2.amount,
i2.invoiceNumber,
CAST (p2.paymentDate as Date) as paymentDate,
p2.paymentMethod,
p2.receiptNumber,
CAST(pf2.lkpID as varchar(73))


from tblPayments p2 WITH(NOLOCK) 
INNER join tblLKP_Payments_Fees pf2 WITH(NOLOCK)on p2.paymentsID = pf2.paymentsID
INNER JOIN tblFees f2 WITH (NOLOCK) on f2.feesID = pf2.feesID AND f2.deleted = 0
INNER JOIN tblFee_Schedule fs2 WITH (NOLOCK) on fs2.fee_scheduleID = f2.fee_scheduleID AND fs2.deleted = 0
INNER JOIN tblCHLD_Invoices_Fees clf2 WITH (NOLOCK) on clf2.feesID = f2.feesID
INNER JOIN tblInvoices i2 WITH (NOLOCK) on i2.invoicesID = clf2.invoicesID
WHERE p2.deleted = 0


UNION ALL

SELECT
'Payment Reversal' as [Transaction Type],
CAST(pr3.reverseDate as DATE) as filterdate,
null as invoiceDate,
p3.glAccountPM2,
p3.glAccountPM,
CASE WHEN p3.isReversed = 1 THEN CONCAT('-',pf3.amount) 
ELSE pf3.amount 
END as amount,
i3.invoiceNumber,
CAST (pr3.reverseDate as Date) as paymentDate,
p3.paymentMethod,
p3.receiptNumber,
CAST(CONCAT(pr3.reversesID,'-',pf3.lkpID) as varchar(73))


from tblPayments p3 WITH(NOLOCK) 
LEFT join tblLKP_Payments_Fees pf3 WITH(NOLOCK) on p3.paymentsID = pf3.paymentsID
LEFT JOIN tblFees f3 WITH (NOLOCK) on f3.feesID = pf3.feesID AND f3.deleted = 0
LEFT JOIN tblFee_Schedule fs3 WITH (NOLOCK) on fs3.fee_scheduleID = f3.fee_scheduleID AND fs3.deleted = 0
LEFT JOIN tblCHLD_Invoices_Fees clf3 WITH (NOLOCK) on clf3.feesID = f3.feesID
LEFT JOIN tblInvoices i3 WITH (NOLOCK) on i3.invoicesID = clf3.invoicesID
INNER JOIN tblPayments_Reverses pr3 WITH (NOLOCK) on pr3.paymentsID = pf3.paymentsID AND pr3.deleted = 0

WHERE p3.deleted = 0 

AND p3.isReversed = 1

AND i3.invoiceNumber IS NOT NULL

UNION ALL

SELECT
'Payment Refund' as [Transaction Type],
CAST(pr4.refundDate as DATE) as filterdate,
null as invoiceDate,
p4.glAccountPM2,
p4.glAccountPM,
CASE WHEN p4.isRefunded = 1 THEN CONCAT('-',pf4.amount) 
ELSE pf4.amount 
END as amount,
i4.invoiceNumber,
CAST (pr4.refundDate as Date) as paymentDate,
p4.paymentMethod,
p4.receiptNumber,
CAST(CONCAT(pr4.refundsID,'-',pf4.lkpID) as varchar(73))


from tblPayments p4 WITH(NOLOCK) 
LEFT join tblLKP_Payments_Fees pf4 WITH(NOLOCK) on p4.paymentsID = pf4.paymentsID
LEFT JOIN tblFees f4 WITH (NOLOCK) on f4.feesID = pf4.feesID AND f4.deleted = 0
LEFT JOIN tblFee_Schedule fs4 WITH (NOLOCK) on fs4.fee_scheduleID = f4.fee_scheduleID AND fs4.deleted = 0
LEFT JOIN tblCHLD_Invoices_Fees clf4 WITH (NOLOCK) on clf4.feesID = f4.feesID
LEFT JOIN tblInvoices i4 WITH (NOLOCK) on i4.invoicesID = clf4.invoicesID
LEFT JOIN tblPayments_Refunds pr4 WITH (NOLOCK) on pr4.paymentsID = pf4.paymentsID AND pr4.deleted = 0

WHERE p4.deleted = 0 

AND p4.isRefunded = 1

AND i4.invoiceNumber IS NOT NULL



)

SELECT 



[Transaction Type],
filterdate,
invoiceDate,
[Accrual And Payment GL Debit],
[Accrual And Payment GL Credit],
[Fee Amount Credit],
invoiceNumber,
Paymentdate,
paymentMethod,
receiptNumber,
uniqueid

FROM accouting



