USE client_ccbh0

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT 1 FROM sys.views WHERE name='v_bpi_RFETransmittal' and type='v')
drop view v_bpi_RFETransmittal;
GO

GO

CREATE VIEW v_bpi_RFETransmittal AS



SELECT distinct
pro.program as [Program],
c.Organization as [Organization],
perm.permitName as [Permit Name],
perm.permitNumber as [License Number],
CONCAT(a1.addressLine1,', ',a1.City,', ', a1.state,', ',a1.Zip) as [Street Address, City, State, Zip],
perm.Risk as [Rick],
CASE WHEN perm.LicenseTransferred = 'Yes' THEN 'TR' ELSE pt.permitType END as [License Categories],
perm.issueDate as [Issue Date],
i.invoiceNumber as [Audit Number],
pay.paymentMethod as [Payment Type],
pay.CheckNumberNEW as [Check Number],
pay.receiptNumber as [Receipt Number],
CASE WHEN perm.LicenseTransferred = 'Yes' THEN 0 WHEN state.statefee IS NULL THEN 0 ELSE state.statefee END as [State Program Fee],
CASE WHEN perm.LicenseTransferred = 'Yes' THEN 0 WHEN local.localfee IS NULL THEN 0 ELSE local.localfee END as [Local Fee],
CASE WHEN perm.ChargeLateFee = 'Yes' THEN late.latefee ELSE 0 END as [Late Fee],
CASE WHEN perm.ODNRFeeRequired = 'Yes' THEN  18.00 END as [ODNR Fee],
perm.ODNRFeeRequired as [ODNR Fee Required],
perm.PoolLocation as [Pool Location]


FROM tblFees f
INNER JOIN tblCHLD_Invoices_Fees cif WITH (NOLOCK) on cif.feesID = f.feesID 
INNER JOIN tblInvoices i WITH (NOLOCK) on i.invoicesID = cif.invoicesID AND i.deleted = 0
INNER JOIN tblLKP_Payments_Fees lpf WITH (NOLOCK) on lpf.feesID = f.feesID AND lpf.deleted = 0
INNER JOIN tblPayments pay WITH (NOLOCK) on pay.paymentsID = lpf.paymentsID AND pay.deleted = 0 AND pay.isReversed = 0 AND pay.isRefunded = 0

INNER JOIN tblPermit perm WITH (NOLOCK) on perm.permitID = i.permitID AND perm.deleted = 0
INNER JOIN tblLKP_Permit_Contacts pc WITH (NOLOCK) on pc.permitID = perm.permitID AND pc.deleted = 0 AND pc.contactType LIKE '%Billing%'
LEFT JOIN tblContacts c WITH (NOLOCK) on c.contactsID = pc.contactsID AND c.deleted = 0
LEFT JOIN tblAddress a WITH (NOLOCK) on a.addressID = c.addressID AND a.deleted = 0

LEFT JOIN tblCHLD_Establishment_Permit cep WITH (NOLOCK) on cep.permitID = perm.permitid
LEFT JOIN tblCHLD_Address_Establishment cae WITH (NOLOCK) on cae.establishmentID = cep.establishmentID
LEFT JOIN tblAddress a1 WITH (NOLOCK) on a1.addressID = cae.addressID AND a1.deleted = 0

INNER JOIN tblCFG_Permit_Type pt WITH (NOLOCK) on pt.cfg_permit_typeID = perm.cfg_permit_typeID AND pt.deleted = 0
INNER JOIN tblCFG_Program pro WITH (NOLOCK) on pro.cfg_programID = perm.cfg_programID AND pro.deleted = 0


CROSS APPLY
(

SELECT SUM(lpf1.amount) as localfee

FROM tblFees f1
LEFT JOIN tblCHLD_Invoices_Fees cif1 WITH (NOLOCK) on cif1.feesID = f1.feesID 
LEFT JOIN tblInvoices i1 WITH (NOLOCK) on i1.invoicesID = cif1.invoicesID AND i1.deleted = 0
LEFT JOIN tblLKP_Payments_Fees lpf1 WITH (NOLOCK) on lpf1.feesID = f1.feesID AND lpf1.deleted = 0
LEFT JOIN tblPayments pay1 WITH (NOLOCK) on pay1.paymentsID = lpf1.paymentsID AND pay1.deleted = 0 

LEFT JOIN tblPermit perm1 WITH (NOLOCK) on perm1.permitID = i1.permitID AND perm1.deleted = 0

INNER JOIN tblFee_Schedule fs1 WITH (NOLOCK) on fs1.fee_scheduleID = f1.fee_scheduleID AND fs1.deleted = 0



WHERE fs1.FeeCategoryType = 'local'

AND pay1.isReversed = 0

AND perm1.permitID = perm.permitID
AND i1.invoicesID = i.invoicesID
AND pay.receiptNumber = pay1.receiptNumber

) as local



CROSS APPLY
(

SELECT SUM(lpf2.amount) as statefee

FROM tblFees f2
LEFT JOIN tblCHLD_Invoices_Fees cif2 WITH (NOLOCK) on cif2.feesID = f2.feesID 
LEFT JOIN tblInvoices i2 WITH (NOLOCK) on i2.invoicesID = cif2.invoicesID AND i2.deleted = 0
LEFT JOIN tblLKP_Payments_Fees lpf2 WITH (NOLOCK) on lpf2.feesID = f2.feesID AND lpf2.deleted = 0
LEFT JOIN tblPayments pay2 WITH (NOLOCK) on pay2.paymentsID = lpf2.paymentsID AND pay2.deleted = 0 

LEFT JOIN tblPermit perm2 WITH (NOLOCK) on perm2.permitID = i2.permitID AND perm2.deleted = 0

INNER JOIN tblFee_Schedule fs2 WITH (NOLOCK) on fs2.fee_scheduleID = f2.fee_scheduleID AND fs2.deleted = 0



WHERE fs2.FeeCategoryType = 'State'

AND pay2.isReversed = 0

AND perm2.permitID = perm.permitID

AND i2.invoicesID = i.invoicesID

AND pay.receiptNumber = pay2.receiptNumber

) as state



CROSS APPLY
(

SELECT SUM(fs3.Fee) as latefee

FROM tblFees f3
LEFT JOIN tblCHLD_Invoices_Fees cif3 WITH (NOLOCK) on cif3.feesID = f3.feesID 
LEFT JOIN tblInvoices i3 WITH (NOLOCK) on i3.invoicesID = cif3.invoicesID AND i3.deleted = 0
LEFT JOIN tblLKP_Payments_Fees lpf3 WITH (NOLOCK) on lpf3.feesID = f3.feesID AND lpf3.deleted = 0
LEFT JOIN tblPayments pay3 WITH (NOLOCK) on pay3.paymentsID = lpf3.paymentsID AND pay3.deleted = 0 

LEFT JOIN tblPermit perm3 WITH (NOLOCK) on perm3.permitID = i3.permitID AND perm3.deleted = 0

INNER JOIN tblFee_Schedule fs3 WITH (NOLOCK) on fs3.fee_scheduleID = f3.fee_scheduleID AND fs3.deleted = 0



WHERE fs3.FeeCategoryType = 'Late Fee'

AND pay3.isReversed = 0

AND perm3.permitID = perm.permitID

AND i3.invoicesID = i.invoicesID

AND pay.receiptNumber = pay3.receiptNumber

) as Late



WHERE perm.deleted = 0
AND f.isReversed = 0

AND perm.issuedate >= '2020-01-01'