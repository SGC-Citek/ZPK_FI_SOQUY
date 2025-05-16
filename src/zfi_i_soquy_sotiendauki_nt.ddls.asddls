@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Tính số tiền đầu kì ngoại tệ'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFI_I_SOQUY_SOTIENDAUKI_NT
with parameters
@Environment.systemField:#SYSTEM_DATE
                FromDate: vdm_v_key_date
as select distinct from I_OperationalAcctgDocItem as tinhTien
{
    key tinhTien.CompanyCode,
    key tinhTien.GLAccount,
    
   @Semantics.amount.currencyCode: 'TransactionCurrency'
   sum(tinhTien.AmountInTransactionCurrency
        ) as SumAmountInTransactionCurrency,
   tinhTien.TransactionCurrency as TransactionCurrency
}where(tinhTien.PostingDate < $parameters.FromDate and tinhTien.TransactionCurrency <> 'VND') group by CompanyCode, GLAccount ,TransactionCurrency
